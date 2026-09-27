#!/usr/bin/env python3
"""Dependency-free guards for the Phase 1C Mac verification contract."""

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def fail(message: str) -> None:
    raise SystemExit(f"ERROR: {message}")


def require_text(path: Path, contracts: tuple[str, ...]) -> None:
    if not path.is_file():
        fail(f"Required Phase 1C file is missing: {path.relative_to(ROOT)}")
    text = path.read_text(encoding="utf-8")
    for contract in contracts:
        if contract not in text:
            fail(f"{path.relative_to(ROOT)} is missing contract: {contract}")


def main() -> None:
    require_text(
        ROOT / "run_mac.command",
        (
            "xcodebuild -version",
            "command -v pod",
            "--project-name thumal_quest",
            "dart format --output=none lib test",
            "flutter analyze",
            "flutter test",
            "flutter build macos --debug",
            "collect_mac_diagnostics.sh",
            "PHASE 1C MAC CHECK PASSED",
        ),
    )
    require_text(
        ROOT / "scripts/collect_mac_diagnostics.sh",
        ("Flutter doctor", "Flutter devices", "Platform hosts", "redact"),
    )
    require_text(
        ROOT / ".github/workflows/flutter-ci.yml",
        ("Validate Phase 1C Mac gate", "iOS simulator build", "flutter build ios --simulator --debug"),
    )
    require_text(
        ROOT / "docs/PHASE_1C_IMPLEMENTATION.md",
        ("TECHNICAL GATE PASSED", "./run_mac.command check", "thumal_quest_diagnostics.txt"),
    )
    require_text(
        ROOT / "docs/MAC_QA_CHECKLIST.md",
        ("Automated gate", "Accessibility gate", "Thirty-minute stability gate"),
    )
    require_text(
        ROOT / "test/game_runtime_test.dart",
        ("int? idleXp;", "addTearDown(runtime.dispose)", "expect(idleXp, 0)"),
    )
    require_text(
        ROOT / "test/widget_test.dart",
        (
            "setSurfaceSize(const Size(430, 932))",
            "controller.profile.onboardingCompleted",
            "premium cards provide a visible Material surface for list tiles",
        ),
    )
    require_text(
        ROOT / "lib/src/widgets.dart",
        ("child: Material(", "clipBehavior: Clip.antiAlias", "child: card"),
    )

    print("Phase 1C Mac bootstrap, diagnostics and native smoke gates: PASS")


if __name__ == "__main__":
    main()
