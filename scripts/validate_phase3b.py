#!/usr/bin/env python3
"""Dependency-free Phase 3B Culture Trail and validation contract checks."""

from __future__ import annotations

import csv
import json
import re
from pathlib import Path

from culture_release_gate import validate as validate_culture
from engagement_validation_gate import EXPECTED_FIELDS, evaluate as evaluate_engagement


ROOT = Path(__file__).resolve().parents[1]


def fail(message: str) -> None:
    raise SystemExit(f"ERROR: {message}")


def require(path: Path, contracts: tuple[str, ...]) -> str:
    if not path.is_file():
        fail(f"Required Phase 3B file is missing: {path.relative_to(ROOT)}")
    text = path.read_text(encoding="utf-8")
    for contract in contracts:
        if contract not in text:
            fail(f"{path.relative_to(ROOT)} is missing contract: {contract}")
    return text


def main() -> None:
    manifest_path = ROOT / "content/journey/phase3b_culture_manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    errors, _, total, _ = validate_culture(manifest_path)
    if errors or total != 6:
        fail("Culture manifest structure is invalid: " + "; ".join(errors))

    content = require(
        ROOT / "lib/features/journey/domain/journey_content.dart",
        (
            "CultureTrailPolicy",
            "cultureCards",
            "collectionMilestones",
            "avatarStyles",
            "seasonalTrails",
            "archiveAvailable: true",
        ),
    )
    dart_ids = set(re.findall(r"id: '(culture\.[^']+)'", content))
    manifest_ids = {card["id"] for card in manifest["cards"]}
    if manifest_ids - dart_ids:
        fail("Culture manifest and Dart catalog IDs drifted")
    for card in manifest["cards"]:
        marker = f"id: '{card['id']}'"
        start = content.find(marker)
        if start < 0 or f"minimumLevel: {card['minimum_level']}" not in content[start:start + 1200]:
            fail(f"Culture level drift at {card['id']}")

    require(
        ROOT / "lib/features/journey/domain/journey_state.dart",
        ("claimedQuestKeys", "trailMarks", "selectedAvatarId"),
    )
    require(
        ROOT / "lib/features/journey/domain/journey_engine.dart",
        (
            "collectCultureCard",
            "claimQuest",
            "selectAvatar",
            "weeklyQuestCatalog",
            "QuestCadence.weekly",
        ),
    )
    require(
        ROOT / "lib/features/journey/presentation/culture_screens.dart",
        (
            "Culture Trail",
            "A hman dân leh a nihna",
            "Recognition only • No lesson is locked",
            "NO DEADLINE",
            "Report a Content Issue",
        ),
    )
    require(
        ROOT / "lib/features/journey/presentation/journey_screens.dart",
        ("WEEKLY • NO COUNTDOWN", "Claim +", "CultureTrailScreen"),
    )
    require(
        ROOT / "lib/src/controller.dart",
        ("collectCultureCard", "claimJourneyQuest", "selectJourneyAvatar"),
    )
    require(
        ROOT / "test/culture_engagement_engine_test.dart",
        ("without duplicating collection", "only once", "no expiry"),
    )
    require(
        ROOT / "test/culture_controller_test.dart",
        ("persists a reviewed culture-card read", "idempotent"),
    )
    require(
        ROOT / "test/culture_widget_test.dart",
        ("accessible Mizo context card", "age-responsive avatar"),
    )

    evidence_path = ROOT / "validation/phase3b/engagement_weeks.csv"
    with evidence_path.open(newline="", encoding="utf-8-sig") as stream:
        if tuple(csv.DictReader(stream).fieldnames or ()) != EXPECTED_FIELDS:
            fail("Engagement evidence CSV header is invalid")
    evidence_errors, _, _ = evaluate_engagement(evidence_path)
    if evidence_errors:
        fail("Engagement evidence structure is invalid: " + "; ".join(evidence_errors))
    require(
        ROOT / "docs/PHASE_3B_FIELD_PLAYBOOK.md",
        ("No fabricated evidence", "early_5_7", "four weekly rows", "--strict"),
    )
    require(
        ROOT / "docs/PHASE_3B_IMPLEMENTATION.md",
        ("EVIDENCE COLLECTION PENDING", "0/6", "0/15", "0/60"),
    )
    require(ROOT / "pubspec.yaml", ("version:",))
    print("Phase 3B culture, collections and engagement validation: PASS")


if __name__ == "__main__":
    main()
