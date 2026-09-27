#!/usr/bin/env python3
"""Dependency-free Phase 3C release-closure contract checks."""

from __future__ import annotations

import csv
import json
from pathlib import Path

from mac_verification_gate import validate as validate_mac
from phase3_review_workflow import EXPECTED_FIELDS, validate as validate_reviews
from pilot_readiness_gate import validate as validate_pilot


ROOT = Path(__file__).resolve().parents[1]


def fail(message: str) -> None:
    raise SystemExit(f"ERROR: {message}")


def require(path: Path, contracts: tuple[str, ...]) -> str:
    if not path.is_file():
        fail(f"Required Phase 3C file is missing: {path.relative_to(ROOT)}")
    text = path.read_text(encoding="utf-8")
    for contract in contracts:
        if contract not in text:
            fail(f"{path.relative_to(ROOT)} is missing contract: {contract}")
    return text


def main() -> None:
    review_path = ROOT / "validation/phase3c/review_decisions.csv"
    with review_path.open(newline="", encoding="utf-8-sig") as stream:
        if tuple(csv.DictReader(stream).fieldnames or ()) != EXPECTED_FIELDS:
            fail("Phase 3 review CSV header is invalid")
    review_errors, _, rows = validate_reviews(review_path)
    if review_errors or len(rows) != 19:
        fail("Phase 3 review workflow structure is invalid")

    pilot_path = ROOT / "validation/phase3c/pilot_readiness.json"
    json.loads(pilot_path.read_text(encoding="utf-8"))
    pilot_errors, _, total, ready = validate_pilot(pilot_path)
    if pilot_errors or total != 8 or ready != 1:
        fail("Community pilot readiness structure is invalid")

    mac_path = ROOT / "validation/phase3c/mac_verification.json"
    json.loads(mac_path.read_text(encoding="utf-8"))
    mac_errors, _ = validate_mac(mac_path)
    if mac_errors:
        fail("Mac verification evidence structure is invalid")

    models = require(
        ROOT / "lib/features/journey/domain/journey_models.dart",
        ("enum CultureTopic", "communityValues"),
    )
    if "enum CultureTopic { values" in models:
        fail("CultureTopic must not collide with Dart enum values")
    culture_content = require(
        ROOT / "lib/features/journey/domain/journey_content.dart",
        ("CultureTopic.communityValues",),
    )
    if "CultureTopic.values" in culture_content:
        fail("Culture content still uses the reserved enum values member")

    require(
        ROOT / "lib/features/onboarding/domain/learner_profile.dart",
        ("gentleMode", "'gentleMode': gentleMode", "?? true"),
    )
    require(
        ROOT / "lib/features/journey/presentation/journey_screens.dart",
        ("OPTIONAL DAILY • NO PENALTY", "OPTIONAL WEEKLY • NO DEADLINE"),
    )
    require(
        ROOT / "lib/src/screens.dart",
        ("Gentle engagement", "Keep quests optional and hide streak pressure"),
    )
    require(
        ROOT / "scripts/phase3_review_workflow.py",
        ("--apply", "opaque reviewer_id", "review_required"),
    )
    require(
        ROOT / "scripts/phase3_exit_gate.py",
        ("PHASE 3 EXIT GATE", "--strict"),
    )
    require(
        ROOT / "scripts/write_mac_verification.py",
        ("macos_debug_build", "0.12.0+22"),
    )
    require(
        ROOT / "test/journey_widget_test.dart",
        ("OPTIONAL DAILY • NO PENALTY", "OPTIONAL WEEKLY • NO DEADLINE"),
    )
    require(
        ROOT / "test/learner_profile_test.dart",
        ("older profiles default to gentle engagement", "gentleMode: false"),
    )
    require(
        ROOT / "docs/PHASE_3_REVIEW_HANDOFF.md",
        ("No self-approval", "--apply", "reviewer_id"),
    )
    require(
        ROOT / "docs/COMMUNITY_PILOT_RUNBOOK.md",
        ("No fabricated evidence", "withdraw", "Severity 1"),
    )
    require(
        ROOT / "docs/PHASE_3C_IMPLEMENTATION.md",
        ("HUMAN EVIDENCE PENDING", "0/19", "1/8"),
    )
    require(ROOT / "pubspec.yaml", ("version: 0.12.0+22",))
    print("Phase 3C release gate closure and community pilot preparation: PASS")


if __name__ == "__main__":
    main()
