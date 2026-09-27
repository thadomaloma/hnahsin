#!/usr/bin/env python3
"""Dependency-free Phase 4B delivery and offline-sync contract checks."""

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def fail(message: str) -> None:
    raise SystemExit(f"ERROR: {message}")


def require(relative: str, contracts: tuple[str, ...]) -> str:
    path = ROOT / relative
    if not path.is_file():
        fail(f"Required Phase 4B file is missing: {relative}")
    text = path.read_text(encoding="utf-8")
    for contract in contracts:
        if contract not in text:
            fail(f"{relative} is missing contract: {contract}")
    return text


def main() -> None:
    # The audio half of Phase 4B (upload, review, audio packs, S3 storage)
    # was removed on 2026-09-27; reviewed content delivery and offline sync
    # remain.
    require("pubspec.yaml", ("version: 0.12.0+22", "crypto:", "http:", "path_provider:"))
    schema = require("backend/db/schema.rb", ('create_table "content_packs"',))
    if "audio" in schema or any("audio" in path.name for path in (ROOT / "backend/db/migrate").iterdir()):
        fail("Audio was removed; backend schema and migrations must not define audio tables")
    require(
        "lib/features/content_sync/application/content_sync_service.dart",
        ("invalidRejected", "offlinePreserved", "activeWords", "_store.activate"),
    )
    require(
        "lib/features/content_sync/domain/delivery_models.dart",
        ("canonicalJson", "DeliveredWord", "Only reviewed Mizo packs are accepted"),
    )
    require(
        "test/content_sync_service_test.dart",
        ("verified content pack activates", "tampered pack is rejected", "retains verified offline packs"),
    )
    for retired in (
        "backend/app/models/audio_asset.rb",
        "backend/app/services/media_storage.rb",
        "backend/app/controllers/api/v1/audio_packs_controller.rb",
        "lib/features/audio",
    ):
        if (ROOT / retired).exists():
            fail(f"Audio was removed; {retired} should not exist")
    if "aws-sdk-s3" in (ROOT / "backend/Gemfile").read_text(encoding="utf-8"):
        fail("backend/Gemfile still depends on aws-sdk-s3; audio storage was removed")
    require("docs/PHASE_4B_IMPLEMENTATION.md", ("0.11.0+21", "atomic", "last verified"))
    require("docs/PHASE_4B_GATE_REPORT.md", ("Source-complete", "run_backend.command check", "network disabled"))
    print("Phase 4B reviewed content delivery and offline sync (audio retired): PASS")


if __name__ == "__main__":
    main()
