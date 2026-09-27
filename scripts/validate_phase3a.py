#!/usr/bin/env python3
"""Dependency-free Phase 3A architecture and content contract checks."""

from __future__ import annotations

import json
import re
from pathlib import Path

from journey_release_gate import validate as validate_journey


ROOT = Path(__file__).resolve().parents[1]


def fail(message: str) -> None:
    raise SystemExit(f"ERROR: {message}")


def require(path: Path, contracts: tuple[str, ...]) -> str:
    if not path.is_file():
        fail(f"Required Phase 3A file is missing: {path.relative_to(ROOT)}")
    text = path.read_text(encoding="utf-8")
    for contract in contracts:
        if contract not in text:
            fail(f"{path.relative_to(ROOT)} is missing contract: {contract}")
    return text


def main() -> None:
    manifest_path = ROOT / "content/journey/phase3a_journey_manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    errors, _, total, _ = validate_journey(manifest_path)
    if errors or total != 3:
        fail("Journey manifest structure is invalid: " + "; ".join(errors))
    regions = manifest.get("regions", [])
    if {region.get("id") for region in regions} != {
        "region.home",
        "region.nature",
        "region.culture",
    }:
        fail("Journey manifest must contain the three canonical regions")

    content = require(
        ROOT / "lib/features/journey/domain/journey_content.dart",
        (
            "JourneyContentPolicy",
            "JourneyReviewState.reviewRequired",
            "story.homecoming",
            "story.river_walk",
            "story.helping_hand",
            "Tlawmngaihna",
        ),
    )
    for story in manifest["stories"]:
        if f"'{story['id']}'" not in content or f"'{story['node_id']}'" not in content:
            fail(f"Journey manifest and Dart catalog drifted at {story['id']}")
    word_data = (ROOT / "lib/src/data.dart").read_text(encoding="utf-8")
    word_ids = set(re.findall(r"WordEntry\(\s*id: '([^']+)'", word_data))
    for story in manifest["stories"]:
        missing_targets = set(story["target_word_ids"]) - word_ids
        if missing_targets:
            fail(
                f"{story['id']} targets missing word IDs: "
                + ", ".join(sorted(missing_targets))
            )

    require(
        ROOT / "lib/features/journey/domain/journey_engine.dart",
        (
            "JourneyNodeStatus",
            "completeStory",
            "graceAvailable",
            "shouldShowComeback",
            "dailyQuestCatalog",
            "acknowledgeHealthyStop",
        ),
    )
    require(
        ROOT / "lib/features/journey/domain/journey_state.dart",
        ("completedNodeIds", "actionCounts", "healthyStops", "toJson"),
    )
    require(
        ROOT / "lib/features/journey/presentation/journey_screens.dart",
        (
            "Mizo Journey",
            "Choose a natural reply",
            "Welcome back",
            "A good stopping point",
            "My Collection",
        ),
    )
    require(
        ROOT / "lib/src/controller.dart",
        ("_reviewStoryTargets", "story.targetWordIds", "alreadyCompleted"),
    )
    require(
        ROOT / "lib/src/screens.dart",
        ("JourneyContentPolicy.releaseReady", "JourneyScreen(controller: controller)"),
    )
    repository = require(
        ROOT / "lib/data/preferences_quest_repository.dart",
        ("phase3a.journey_state", "saveJourneyState", "loadJourneyState"),
    )
    if "_journeyKey" not in repository.split("Future<void> resetAll", 1)[1]:
        fail("Journey state must be included in local reset")
    require(
        ROOT / "lib/data/sqflite_quest_repository.dart",
        ("version: 3", "CREATE TABLE journey_state", "saveJourneyState"),
    )
    require(
        ROOT / "test/journey_engine_test.dart",
        ("consumes grace", "cannot duplicate", "reset by date"),
    )
    require(
        ROOT / "test/journey_controller_test.dart",
        ("persists story completion", "cannot be completed out of order"),
    )
    require(
        ROOT / "test/journey_widget_test.dart",
        ("exposes the first story", "requires a natural reply"),
    )
    require(ROOT / "pubspec.yaml", ("version:",))
    require(
        ROOT / "docs/PHASE_3A_IMPLEMENTATION.md",
        ("REVIEW EVIDENCE PENDING", "0/3", "Healthy stopping"),
    )
    print("Phase 3A journey, story and engagement core: PASS")


if __name__ == "__main__":
    main()
