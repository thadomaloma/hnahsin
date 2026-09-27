#!/usr/bin/env python3
"""Dependency-free structural checks for the Phase 1 professional core."""

from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def fail(message: str) -> None:
    raise SystemExit(f"ERROR: {message}")


def require_files(paths: list[str]) -> None:
    missing = [path for path in paths if not (ROOT / path).is_file()]
    if missing:
        fail(f"Missing Phase 1 files: {', '.join(missing)}")


def validate_dependencies() -> None:
    pubspec = (ROOT / "pubspec.yaml").read_text(encoding="utf-8")
    for package in ("sqflite", "path", "shared_preferences"):
        if not re.search(rf"^  {package}: ", pubspec, flags=re.MULTILINE):
            fail(f"pubspec is missing {package}")


def validate_game_ports() -> None:
    games = (ROOT / "lib/src/games.dart").read_text(encoding="utf-8")
    for game_id in (
        "picture_match",
        "spelling",
        "word_search",
        "word_chain",
        "tawng_upa",
        "crossword",
    ):
        if f"gameId: '{game_id}'" not in games:
            fail(f"{game_id} is not connected to Game Engine V2")

    controller = (ROOT / "lib/src/controller.dart").read_text(encoding="utf-8")
    if "transactionId: result.rewardTransactionId" not in controller:
        fail("Reward idempotency is not wired to the repository")


def validate_release_gate() -> None:
    data = (ROOT / "lib/src/data.dart").read_text(encoding="utf-8")
    app = (ROOT / "lib/src/app.dart").read_text(encoding="utf-8")
    if "THUMAL_QUEST_PRODUCTION" not in data:
        fail("Production content release flag is missing")
    if not any(contract in app for contract in (
        "ContentPolicy.isProduction && !ContentPolicy.releaseReady",
        "ContentPolicy.isProduction && !controller.releaseContentReady",
    )):
        fail("App does not fail closed when release content is unapproved")


def validate_manifest() -> None:
    manifest_path = ROOT / "content/pilot/manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    if manifest.get("release_status") != "draft":
        fail("Pilot pack must remain draft until human approval")
    for entry in manifest.get("files", []):
        source = manifest_path.parent / entry["path"]
        digest = hashlib.sha256(source.read_bytes()).hexdigest()
        if digest != entry["sha256"]:
            fail(f"Checksum mismatch: {entry['path']}")


def main() -> None:
    require_files(
        [
            "lib/data/quest_repository.dart",
            "lib/data/sqflite_quest_repository.dart",
            "lib/features/games/engine/game_engine.dart",
            "lib/features/onboarding/domain/learner_profile.dart",
            "lib/features/onboarding/presentation/onboarding_screen.dart",
            "lib/features/analytics/domain/analytics_event.dart",
            "test/game_engine_v2_test.dart",
            "test/quest_repository_test.dart",
            "content/pilot/manifest.json",
        ]
    )
    validate_dependencies()
    validate_game_ports()
    validate_release_gate()
    validate_manifest()
    print("Phase 1 architecture, game ports, release gate and checksums: PASS")


if __name__ == "__main__":
    main()
