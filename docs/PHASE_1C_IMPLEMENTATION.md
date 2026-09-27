# Phase 1C — Mac Verification & Stabilization

**Build:** 0.5.4+10  
**Date:** 13 September 2026  
**Status:** **TECHNICAL GATE PASSED — HUMAN QA REMAINS**

## Outcome

Thumal Quest now has one reproducible Mac verification path that diagnoses the
toolchain, generates missing Flutter host projects, runs source and unit checks,
and proves that the macOS debug application can compile before launch. A failed
run automatically creates a privacy-reduced diagnostic report for support.

Mac analyzer feedback from the first owner run was applied in build 0.5.2+8:
one redundant Flutter import and six missing const-context optimizations were
corrected. The reported seven analyzer findings are therefore addressed.

The next owner run exposed two test-harness failures. Build 0.5.3+9 moves the
timed-result assertion outside `WidgetTester.pump`'s guarded callback, guarantees
runtime cleanup through `addTearDown`, and makes the premium-home test use an
explicit phone-size viewport with bounded pumps. These changes stabilize the
tests without weakening their product assertions.

Build 0.5.4+10 fixes the exact Flutter framework assertion found by the focused
home test. `PremiumCard` now places a clipped transparent `Material` surface
inside its decoration, so `ListTile`/`SwitchListTile` backgrounds and ink
splashes paint above the card instead of behind it. A regression widget test
covers this shared component contract.

## Delivered

| Capability | Implementation |
|---|---|
| Full Xcode preflight | Detects incomplete Command Line Tools selection and unaccepted setup/license |
| CocoaPods preflight | Stops early with a clear install command before plugin build failure |
| Host repair | Generates missing Android, iOS, macOS and web hosts without fetching packages mid-step |
| Source parse gate | Runs the Dart formatter parser without rewriting project files |
| Core verification | Runs all four project validators, analyzer and Flutter tests |
| Native smoke build | `check` now includes a macOS debug build, not only analysis/tests |
| Failure evidence | Automatically writes `thumal_quest_diagnostics.txt` with tool versions and recent log |
| Privacy reduction | The diagnostic collector replaces the user's home path with `~` |
| CI matrix | Analyze/test plus macOS, Android and iOS Simulator debug builds |

## Authoritative Mac command

Extract the package, open Terminal inside the project, then run:

```bash
chmod +x run_mac.command scripts/collect_mac_diagnostics.sh
./run_mac.command check
```

Passing output ends with:

```text
PHASE 1C MAC CHECK PASSED
```

Then launch the app:

```bash
./run_mac.command
```

## If it fails

The launcher creates this support-safe report automatically:

```text
thumal_quest_diagnostics.txt
```

It can also be regenerated without starting a build:

```bash
./run_mac.command report
```

Send that report for the next repair pass. Review it before sharing if the Mac
contains a personally identifying machine name; environment variables, API keys
and full process listings are deliberately not collected.

## Gate status

Implemented and locally verifiable here:

- Phase 0, Phase 1, Phase 1B and Phase 1C dependency-free validators
- Bash syntax for launcher and diagnostic collector
- Required CI native-build jobs and commands
- Packaging/integrity checks

Confirmed on the product owner's Mac:

- Flutter package resolution
- Dart formatting and Flutter analyzer
- Flutter unit/widget tests
- macOS debug build

Still required:

- iOS Simulator and Android debug smoke evidence
- VoiceOver, 200% text scaling and 30-minute six-game exploratory test

The reproducible Mac technical gate has passed. Mizo content review remains a
separate publication gate.

The product owner confirmed on 13 September 2026 that the authoritative Mac
check passed after the analyzer, async test and Material-surface fixes. Manual
accessibility, extended stability and Mizo content review remain separate gates.
