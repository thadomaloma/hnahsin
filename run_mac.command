#!/bin/bash

set -Eeuo pipefail

project_dir="$(cd "$(dirname "$0")" && pwd)"
cd "$project_dir"

log_file="$project_dir/thumal_quest_run.log"
diagnostic_file="$project_dir/thumal_quest_diagnostics.txt"
run_mode="${1:-run}"
interactive="true"
if [ ! -t 0 ]; then interactive="false"; fi

# Finder-launched Terminal windows do not always inherit Homebrew paths.
for candidate_path in /opt/homebrew/bin /usr/local/bin; do
  if [ -d "$candidate_path" ]; then
    PATH="$candidate_path:$PATH"
  fi
done
export PATH

mkdir -p "$project_dir"
exec > >(tee "$log_file") 2>&1

pause_before_exit() {
  if [ "$interactive" = "true" ]; then
    read -r -p "Enter hmet la khar rawh..." || true
  fi
}

write_diagnostics() {
  if [ -x "$project_dir/scripts/collect_mac_diagnostics.sh" ]; then
    "$project_dir/scripts/collect_mac_diagnostics.sh" "$log_file" "$diagnostic_file" >/dev/null 2>&1 || true
  fi
}

fail_with_help() {
  message="$1"
  echo ""
  echo "ERROR: $message"
  write_diagnostics
  echo "Log file: $log_file"
  echo "Diagnostic file: $diagnostic_file"
  pause_before_exit
  exit 1
}

on_error() {
  status=$?
  trap - ERR
  echo ""
  echo "ERROR: Setup/build a hlawhchham (exit $status)."
  write_diagnostics
  echo "A chunga error leh diagnostic file hi support atan hmang rawh:"
  echo "  $diagnostic_file"
  pause_before_exit
  exit "$status"
}
trap on_error ERR

echo ""
echo "Hnahsin — Phase 4C Mac verification"
echo "========================================="
echo "Project: $project_dir"
echo "Mode: $run_mode"

case "$run_mode" in
  run|check|doctor|report|learner-report|journey-report|culture-report|engagement-report|review-report|pilot-report|mac-report|phase3-report) ;;
  *) fail_with_help "Mode hriat loh: $run_mode (run, check, doctor, report leh gate report modes chauh hmang rawh)." ;;
esac

if [ "$run_mode" = "report" ]; then
  write_diagnostics
  echo "Diagnostic report siam a ni: $diagnostic_file"
  pause_before_exit
  exit 0
fi

if [ "$run_mode" = "learner-report" ]; then
  python3 scripts/learner_validation_gate.py
  pause_before_exit
  exit 0
fi

if [ "$run_mode" = "journey-report" ]; then
  python3 scripts/journey_release_gate.py
  pause_before_exit
  exit 0
fi

if [ "$run_mode" = "culture-report" ]; then
  python3 scripts/culture_release_gate.py
  pause_before_exit
  exit 0
fi

if [ "$run_mode" = "engagement-report" ]; then
  python3 scripts/engagement_validation_gate.py
  pause_before_exit
  exit 0
fi

if [ "$run_mode" = "review-report" ]; then
  python3 scripts/phase3_review_workflow.py
  pause_before_exit
  exit 0
fi

if [ "$run_mode" = "pilot-report" ]; then
  python3 scripts/pilot_readiness_gate.py
  pause_before_exit
  exit 0
fi

if [ "$run_mode" = "mac-report" ]; then
  python3 scripts/mac_verification_gate.py
  pause_before_exit
  exit 0
fi

if [ "$run_mode" = "phase3-report" ]; then
  python3 scripts/phase3_exit_gate.py
  pause_before_exit
  exit 0
fi

if [ "$(uname -s)" != "Darwin" ]; then
  fail_with_help "run_mac.command hi macOS atan chauh a ni."
fi

if ! command -v flutter >/dev/null 2>&1; then
  for candidate_flutter in \
    "$HOME/development/flutter/bin/flutter" \
    "$HOME/flutter/bin/flutter" \
    "/opt/homebrew/bin/flutter" \
    "/usr/local/bin/flutter"; do
    if [ -x "$candidate_flutter" ]; then
      PATH="$(dirname "$candidate_flutter"):$PATH"
      export PATH
      break
    fi
  done
fi

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK ka hmu lo."
  if command -v brew >/dev/null 2>&1; then
    echo "Terminal-ah hei hi run rawh:"
    echo "  brew install --cask flutter"
  else
    echo "Homebrew emaw official Flutter SDK install hmasa rawh:"
    echo "  https://docs.flutter.dev/get-started/install/macos"
  fi
  echo "Install zawhah Terminal thar hawng la: flutter doctor -v"
  fail_with_help "Flutter command is unavailable."
fi

flutter_version_line="$(flutter --version 2>/dev/null | sed -n '1p')"
echo "Flutter: $flutter_version_line"
echo "macOS: $(sw_vers -productVersion) ($(uname -m))"

if ! command -v xcodebuild >/dev/null 2>&1; then
  fail_with_help "Full Xcode install hmasa rawh; Command Line Tools chauh a tawk lo."
fi

if ! xcodebuild -version >/dev/null 2>&1; then
  echo "Xcode App Store atangin install/hawn la, component leh licence accept rawh."
  echo "Xcode install sa a nih chuan:"
  echo "  sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
  echo "  sudo xcodebuild -runFirstLaunch"
  fail_with_help "Xcode developer directory/license is not ready."
fi

if ! xcrun --find clang >/dev/null 2>&1; then
  fail_with_help "Xcode toolchain is incomplete. Open Xcode once and install its components."
fi

xcode_version_line="$(xcodebuild -version | tr '\n' ' ' | sed 's/[[:space:]]*$//')"

if ! command -v pod >/dev/null 2>&1; then
  echo "CocoaPods ka hmu lo. Flutter plugin build nan a ngai."
  if command -v brew >/dev/null 2>&1; then
    echo "  brew install cocoapods"
  else
    echo "  sudo gem install cocoapods"
  fi
  fail_with_help "CocoaPods is unavailable."
fi

echo ""
echo "Flutter doctor (diagnostic)"
flutter doctor -v || true

if [ "$run_mode" = "doctor" ]; then
  write_diagnostics
  echo ""
  echo "Doctor mode zawh ta. Diagnostic file: $diagnostic_file"
  pause_before_exit
  exit 0
fi

echo ""
echo "Project artifacts verify mek..."
if command -v python3 >/dev/null 2>&1; then
  python3 scripts/validate_phase0.py
  python3 scripts/validate_phase1.py
  python3 scripts/validate_phase1b.py
  python3 scripts/validate_phase1c.py
  python3 scripts/validate_phase2a.py
  python3 scripts/validate_phase2b.py
  python3 scripts/validate_phase2c.py
  python3 scripts/validate_phase3a.py
  python3 scripts/validate_phase3b.py
  python3 scripts/validate_phase3c.py
  python3 scripts/validate_phase4a.py
  python3 scripts/validate_phase4b.py
  python3 scripts/validate_phase4c.py
else
  echo "WARNING: python3 a awm lo; dependency-free artifact validators skip a ni."
fi

flutter config --enable-macos-desktop >/dev/null

needs_hosts="false"
if [ ! -f "macos/Runner.xcodeproj/project.pbxproj" ]; then needs_hosts="true"; fi
if [ ! -f "ios/Runner.xcodeproj/project.pbxproj" ]; then needs_hosts="true"; fi
if [ ! -f "android/app/build.gradle.kts" ] && [ ! -f "android/app/build.gradle" ]; then needs_hosts="true"; fi

if [ "$needs_hosts" = "true" ]; then
  echo ""
  echo "Flutter Android/iOS/macOS/web host files siam mek..."
  flutter create \
    --platforms=android,ios,macos,web \
    --org com.hnahsin \
    --project-name thumal_quest \
    --no-pub \
    .
fi

echo ""
echo "Packages download mek..."
flutter pub get

echo ""
echo "Dart source parse/formatter verify mek..."
dart format --output=none lib test

echo ""
echo "Static analysis run mek..."
flutter analyze

echo ""
echo "Tests run mek..."
flutter test

echo ""
echo "macOS debug build verify mek..."
flutter build macos --debug

python3 scripts/write_mac_verification.py \
  --macos "$(sw_vers -productVersion)" \
  --arch "$(uname -m)" \
  --flutter "$flutter_version_line" \
  --xcode "$xcode_version_line"
python3 scripts/mac_verification_gate.py --strict

if [ "$run_mode" = "check" ]; then
  write_diagnostics
  echo ""
  echo "PHASE 1C MAC CHECK PASSED"
  echo "PHASE 2B MAC CHECK PASSED"
  echo "PHASE 2C TECHNICAL CHECK PASSED"
  echo "PHASE 3A TECHNICAL CHECK PASSED"
  echo "PHASE 3B TECHNICAL CHECK PASSED"
  echo "PHASE 3C TECHNICAL CHECK PASSED"
  echo "PHASE 4A APP CONTRACT CHECK PASSED"
  echo "PHASE 4B CONTENT DELIVERY CHECK PASSED"
  echo "PHASE 4C STAGING CONTRACT CHECK PASSED"
  echo "Format, analyze, tests leh macOS debug build an pass vek."
  echo "App hawn tur chuan: ./run_mac.command"
  pause_before_exit
  exit 0
fi

echo ""
echo "Hnahsin macOS app hawn mek..."
flutter run -d macos
