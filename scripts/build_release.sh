#!/bin/bash
# Builds the App Store (.ipa) and Play Store (.aab) releases with the
# published content, so a store build never ships with only the starter words.
#
#   scripts/build_release.sh          # both
#   scripts/build_release.sh ios      # App Store only
#   scripts/build_release.sh android  # Play Store only

set -euo pipefail

cd "$(dirname "$0")/.."

content_url="${HNAHSIN_API_BASE_URL:-https://thadomaloma.github.io/hnahsin-content}"
define="--dart-define=HNAHSIN_API_BASE_URL=$content_url"
target="${1:-all}"

echo "Content: $content_url"

if [ "$target" = "all" ] || [ "$target" = "ios" ]; then
  flutter build ipa --release "$define"
fi

if [ "$target" = "all" ] || [ "$target" = "android" ]; then
  flutter build appbundle --release "$define"
fi
