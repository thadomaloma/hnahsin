#!/bin/bash
# Builds the game for Editorial Studio's "Game test" link into
# backend/public/game-test (git-ignored, development only), so the link works
# without a separate `flutter run` web server. Rebuilds only when the app's
# code or assets changed since the last build. Usage:
#   scripts/build_game_test.sh [studio-url]   (default http://localhost:3000)

set -Eeuo pipefail

project_dir="$(cd "$(dirname "$0")/.." && pwd)"
out_dir="$project_dir/backend/public/game-test"
stamp="$out_dir/.built"
studio_url="${1:-http://localhost:3000}"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Game test: Flutter hmuh a ni lo, build kan skip e (Studio erawh a kal tho ang)."
  exit 0
fi

cd "$project_dir"
if [ -f "$stamp" ] && [ -z "$(find lib web assets pubspec.yaml -newer "$stamp" -print -quit)" ]; then
  echo "Game test: build a thar tawh ($out_dir)."
  exit 0
fi

echo "Game test: game web build siam mek (minute khat vel a rei thei)..."
flutter build web \
  --base-href /game-test/ \
  --dart-define=THUMAL_QUEST_API_BASE_URL="$studio_url" \
  --dart-define=THUMAL_QUEST_EDITOR_TOOLS=true \
  -o "$out_dir"
touch "$stamp"
echo "Game test: a zo e — $studio_url/game-test/"
