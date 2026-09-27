#!/bin/bash

set -u

project_dir="$(cd "$(dirname "$0")/.." && pwd)"
log_file="${1:-$project_dir/thumal_quest_run.log}"
output_file="${2:-$project_dir/thumal_quest_diagnostics.txt}"
temporary_file="${output_file}.tmp"

redact() {
  if [ -n "${HOME:-}" ]; then
    sed "s|${HOME}|~|g"
  else
    cat
  fi
}

run_optional() {
  label="$1"
  shift
  echo "[$label]"
  "$@" 2>&1 || true
  echo ""
}

{
  echo "Thumal Quest — Mac Diagnostic Report"
  echo "Generated (UTC): $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  echo "Project version: $(sed -n 's/^version: //p' "$project_dir/pubspec.yaml" 2>/dev/null | head -n 1)"
  echo ""
  run_optional "System" uname -a
  if command -v sw_vers >/dev/null 2>&1; then run_optional "macOS" sw_vers; fi
  if [ "$(uname -s)" = "Darwin" ] && command -v sysctl >/dev/null 2>&1; then
    run_optional "CPU" sysctl -n machdep.cpu.brand_string
  fi
  if command -v flutter >/dev/null 2>&1; then
    run_optional "Flutter version" flutter --version
    run_optional "Flutter doctor" flutter doctor -v
    run_optional "Flutter devices" flutter devices
  else
    echo "[Flutter]"
    echo "NOT FOUND"
    echo ""
  fi
  if command -v dart >/dev/null 2>&1; then run_optional "Dart" dart --version; fi
  if command -v xcodebuild >/dev/null 2>&1; then run_optional "Xcode" xcodebuild -version; fi
  if command -v xcode-select >/dev/null 2>&1; then run_optional "Xcode path" xcode-select -p; fi
  if command -v pod >/dev/null 2>&1; then run_optional "CocoaPods" pod --version; fi
  echo "[Platform hosts]"
  for platform in android ios macos web; do
    if [ -d "$project_dir/$platform" ]; then
      echo "$platform: present"
    else
      echo "$platform: missing"
    fi
  done
  echo ""
  echo "[Disk]"
  df -h "$project_dir" 2>&1 || true
  echo ""
  echo "[Last launcher output]"
  if [ -f "$log_file" ]; then
    tail -n 160 "$log_file"
  else
    echo "No launcher log found."
  fi
} | redact > "$temporary_file"

mv "$temporary_file" "$output_file"
echo "$output_file"
