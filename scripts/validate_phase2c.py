#!/usr/bin/env python3
"""Dependency-free Phase 2C production and validation contract checks."""

from __future__ import annotations

import csv
from pathlib import Path

from learner_validation_gate import EXPECTED_FIELDS, evaluate as evaluate_learners


ROOT = Path(__file__).resolve().parents[1]


def fail(message: str) -> None:
    raise SystemExit(f"ERROR: {message}")


def require(path: Path, contracts: tuple[str, ...]) -> str:
    if not path.is_file():
        fail(f"Required Phase 2C file is missing: {path.relative_to(ROOT)}")
    text = path.read_text(encoding="utf-8")
    for contract in contracts:
        if contract not in text:
            fail(f"{path.relative_to(ROOT)} is missing contract: {contract}")
    return text


def main() -> None:
    # The audio production half of Phase 2C was retired with the removal of
    # audio on 2026-09-27; learner-evidence tooling remains.
    sessions_path = ROOT / "validation/phase2c/learner_sessions.csv"
    with sessions_path.open(newline="", encoding="utf-8-sig") as stream:
        if tuple(csv.DictReader(stream).fieldnames or ()) != EXPECTED_FIELDS:
            fail("Learner evidence CSV header is invalid")
    learner_errors, _, _ = evaluate_learners(sessions_path)
    if learner_errors:
        fail("Learner validation structure is invalid: " + "; ".join(learner_errors))

    require(
        ROOT / "scripts/learner_validation_gate.py",
        ("need 10 sessions", "safe exit must be 100%", "VoiceOver evidence"),
    )
    require(
        ROOT / "docs/PHASE_2C_FIELD_PLAYBOOK.md",
        ("No fabricated evidence", "early_5_7", "--strict"),
    )
    for retired in (
        ROOT / "content/audio",
        ROOT / "assets/audio",
        ROOT / "scripts/audio_release_gate.py",
    ):
        if retired.exists():
            fail(f"Audio was removed; {retired.relative_to(ROOT)} should not exist")

    print("Phase 2C learner-evidence tooling (audio retired): PASS")


if __name__ == "__main__":
    main()
