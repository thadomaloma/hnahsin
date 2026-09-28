#!/bin/bash
# Start the Editorial Studio backend (localhost:3000) and the Flutter web app
# (localhost:5050) together. Ctrl+C (or q in Flutter) stops both.

set -Euo pipefail

project_dir="$(cd "$(dirname "$0")" && pwd)"
cd "$project_dir"

backend_port=3000
web_port=5050
backend_log="$project_dir/thumal_quest_backend.log"
backend_pid=""

for candidate_path in /opt/homebrew/bin /usr/local/bin; do
  case ":$PATH:" in *":$candidate_path:"*) ;; *) [ -d "$candidate_path" ] && PATH="$PATH:$candidate_path" ;; esac
done
export PATH

stop_all() {
  trap - EXIT INT TERM
  echo ""
  echo "Server-te tihtawp mek..."
  if [ -n "$backend_pid" ]; then kill "$backend_pid" 2>/dev/null || true; fi
  lsof -ti ":$backend_port" -ti ":$web_port" 2>/dev/null | xargs kill 2>/dev/null || true
  rm -f "$project_dir/backend/tmp/pids/server.pid"
  echo "A tawp vek tawh."
}

for port in "$backend_port" "$web_port"; do
  if lsof -ti ":$port" >/dev/null 2>&1; then
    echo "ERROR: Port $port hi hman mek a ni. Tihtawp nan: lsof -ti :$port | xargs kill"
    exit 1
  fi
done

command -v flutter >/dev/null 2>&1 || { echo "ERROR: Flutter hmuh a ni lo."; exit 1; }

rm -f "$project_dir/backend/tmp/pids/server.pid"
trap stop_all EXIT INT TERM

echo "Backend tan mek (log: $backend_log)..."
"$project_dir/run_backend.command" >/dev/null 2>&1 &
backend_pid=$!

for _ in $(seq 1 60); do
  if curl -s -o /dev/null "http://localhost:$backend_port/up"; then break; fi
  if ! kill -0 "$backend_pid" 2>/dev/null; then
    echo "ERROR: Backend a tan thei lo. $backend_log en rawh."
    exit 1
  fi
  sleep 1
done
curl -s -o /dev/null "http://localhost:$backend_port/up" || { echo "ERROR: Backend a inpeih lo. $backend_log en rawh."; exit 1; }

echo "Backend: http://localhost:$backend_port"
echo "App:     http://localhost:$web_port  (a build zawh hunah)"
echo "Tihtawp nan Ctrl+C hmet rawh."
echo ""

# EDITOR_TOOLS adds "Studio-ah fix rawh" links in games; player builds never set it.
flutter run -d web-server --web-port "$web_port" \
  --dart-define=THUMAL_QUEST_API_BASE_URL="http://localhost:$backend_port" \
  --dart-define=THUMAL_QUEST_EDITOR_TOOLS=true
