#!/usr/bin/env python3
"""Dependency-free guards for Phase 1B reliability and game completion."""

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def fail(message: str) -> None:
    raise SystemExit(f"ERROR: {message}")


def main() -> None:
    runtime_path = ROOT / "lib/features/games/application/game_runtime.dart"
    runtime_test = ROOT / "test/game_runtime_test.dart"
    launcher_test = ROOT / "test/game_launcher_test.dart"
    report = ROOT / "docs/PHASE_1B_IMPLEMENTATION.md"
    if not all(path.is_file() for path in (runtime_path, runtime_test, launcher_test, report)):
        fail("Game runtime, tests or Phase 1B report are missing")

    runtime = runtime_path.read_text(encoding="utf-8")
    games = (ROOT / "lib/src/games.dart").read_text(encoding="utf-8")
    widgets = (ROOT / "lib/src/widgets.dart").read_text(encoding="utf-8")

    for contract in (
        "with WidgetsBindingObserver",
        "didChangeAppLifecycleState",
        "Timer.periodic",
        "_remainingSeconds",
        "_hintRevealed",
        "session.pause()",
        "session.resume()",
    ):
        if contract not in runtime:
            fail(f"Reliability contract missing: {contract}")

    if games.count("runtime.initialize(") != 6:
        fail("All six games must initialize the shared reliability runtime")
    if games.count("onTimedOut: _timedOut") != 6:
        fail("All six games must define timed completion")
    if "GameMode.timed" not in games or "90-second challenge" not in games:
        fail("Timed mode is not available in the game launcher")
    if "GameResumeBanner" not in games or "secondsRemaining" not in widgets:
        fail("Resume/timer accessibility UI is missing")

    print("Phase 1B autosave, resume, hints, timed mode and six adapters: PASS")


if __name__ == "__main__":
    main()
