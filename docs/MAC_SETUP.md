# Run Hnahsin on a Mac

## Fast path

1. ZIP file extract rawh.
2. Terminal hawng la project folder-ah kal rawh.
3. Heng command hi run rawh:

```bash
chmod +x run_mac.command
./run_mac.command
```

Double-click pawh a theih, mahse first run-ah Terminal hmang chuan error hmuh a
awlsam zâwk.

## What the launcher checks

- macOS platform
- Flutter SDK and common Apple Silicon/Intel Homebrew paths
- Xcode Command Line Tools
- Full Xcode selection/license readiness
- CocoaPods availability for Flutter plugins
- Flutter doctor diagnostics
- Phase 0 content/document integrity
- Missing Android/iOS/macOS/web host generation
- Dart formatting, `flutter pub get`, `flutter analyze`, `flutter test`
- macOS debug build in both `check` and normal run modes

Log file chu project folder-a `hnahsin_run.log` a ni.

## Useful modes

```bash
# Flutter/Xcode diagnostic only
./run_mac.command doctor

# Generate/format/analyze/test/build, app launch lo
./run_mac.command check

# Create a diagnostic report only
./run_mac.command report

# Full debug build and launch
./run_mac.command
```

## Flutter not found

Homebrew i nei chuan:

```bash
brew install --cask flutter
flutter doctor -v
```

Terminal khar/hawn nawn hnuah `flutter --version` tih a chhân tûr a ni. Apple
Silicon Homebrew `/opt/homebrew/bin` leh Intel Homebrew `/usr/local/bin` chu
launcher-in a zawng nghâl.

Official installation guide:
https://docs.flutter.dev/get-started/install

## Xcode problem

App Store aṭangin Xcode install/hawn hmasa la components leh license accept rawh.
Command Line Tools missing chuan:

```bash
xcode-select --install
sudo xcodebuild -license accept
```

`sudo` command chu Apple license accept tûra i duh leh i hriat chiang hunah
chauh run rawh.

## “Permission denied” or macOS blocked the file

```bash
chmod +x run_mac.command
./run_mac.command
```

If Finder quarantine blocks an app/script, System Settings → Privacy & Security
ah macOS message en rawh. Security warning chu file source i rin ngam chauh open
tûr; Gatekeeper disable pumpui suh.

## If the run still fails

Run:

```bash
./run_mac.command check
```

Then send these two things:

1. Terminal-a `ERROR:` line hnuhnung ber
2. `hnahsin_diagnostics.txt`

Diagnostic report-in home-folder path chu `~`-ah a thlak a; mahse computer name
i lantir duh loh chuan thawn hmaa en phawt rawh. API key, environment variable
leh full process listing a collect lo.

## Phase 4C staging app

Normal Mac/backend checks pass leh staging packs publish zawhah:

```bash
export STAGING_BASE_URL="https://your-railway-staging-origin"
./run_staging.command smoke
./run_staging.command app
```

`app`-in production content gate a enable; reviewed remote catalog tling lo
chuan draft Mizo content lantir lovin fail-closed a ni ang.
