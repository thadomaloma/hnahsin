#!/bin/bash

set -Eeuo pipefail

project_dir="$(cd "$(dirname "$0")" && pwd)"
cd "$project_dir"
mode="${1:-report}"

case "$mode" in
  report)
    python3 scripts/phase4c_staging_gate.py
    ;;
  smoke)
    : "${STAGING_BASE_URL:?Set STAGING_BASE_URL to the HTTPS Railway staging origin}"
    python3 scripts/staging_sync_smoke.py \
      --base-url "$STAGING_BASE_URL" \
      --output validation/phase4c/live_smoke.json
    ;;
  strict)
    : "${STAGING_BASE_URL:?Set STAGING_BASE_URL to the HTTPS Railway staging origin}"
    python3 scripts/staging_sync_smoke.py \
      --base-url "$STAGING_BASE_URL" \
      --output validation/phase4c/live_smoke.json
    python3 scripts/phase4c_staging_gate.py --strict
    ;;
  app)
    : "${STAGING_BASE_URL:?Set STAGING_BASE_URL to the HTTPS Railway staging origin}"
    command -v flutter >/dev/null 2>&1 || {
      echo "ERROR: Flutter SDK is required."
      exit 1
    }
    flutter run -d macos \
      --dart-define=THUMAL_QUEST_PRODUCTION=true \
      --dart-define="THUMAL_QUEST_API_BASE_URL=$STAGING_BASE_URL"
    ;;
  *)
    echo "Usage: ./run_staging.command [report|smoke|strict|app]"
    exit 2
    ;;
esac
