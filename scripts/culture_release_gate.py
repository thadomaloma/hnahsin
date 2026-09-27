#!/usr/bin/env python3
"""Validate Phase 3B Culture Trail review and non-FOMO contracts."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_MANIFEST = ROOT / "content/journey/phase3b_culture_manifest.json"


def validate(path: Path) -> tuple[list[str], list[str], int, int]:
    errors: list[str] = []
    blockers: list[str] = []
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        return [f"manifest cannot be read: {error}"], [], 0, 0

    if payload.get("schema_version") != "1.0":
        errors.append("schema_version must be 1.0")
    if payload.get("language") != "lus":
        errors.append("language must use ISO code lus")
    if payload.get("release_policy") != (
        "every_card_requires_language_and_culture_approval"
    ):
        errors.append("release policy must require language and culture approval")
    if payload.get("reward_type") != "recognition_only":
        errors.append("Trail Marks must remain recognition_only")

    cards = payload.get("cards")
    if not isinstance(cards, list):
        return errors + ["cards must be a list"], blockers, 0, 0
    if len(cards) != 6:
        errors.append("Phase 3B core must contain exactly six culture cards")

    ids: set[str] = set()
    ready = 0
    for index, card in enumerate(cards):
        if not isinstance(card, dict):
            errors.append(f"card {index + 1} must be an object")
            continue
        card_id = card.get("id")
        label = card_id if isinstance(card_id, str) else f"card {index + 1}"
        if not isinstance(card_id, str) or not card_id.startswith("culture."):
            errors.append(f"{label}: stable culture ID missing")
        elif card_id in ids:
            errors.append(f"{label}: duplicate card ID")
        else:
            ids.add(card_id)
        level = card.get("minimum_level")
        if not isinstance(level, int) or not 0 <= level <= 4:
            errors.append(f"{label}: minimum_level must be 0 through 4")

        card_ready = True
        for review_name in ("language_review", "culture_review"):
            review = card.get(review_name)
            if not isinstance(review, dict):
                errors.append(f"{label}: {review_name} must be an object")
                card_ready = False
                continue
            if review.get("status") != "approved":
                blockers.append(f"{label}: {review_name} approval pending")
                card_ready = False
            if not review.get("reviewer_id"):
                blockers.append(f"{label}: {review_name}.reviewer_id missing")
                card_ready = False
            if not review.get("reviewed_at"):
                blockers.append(f"{label}: {review_name}.reviewed_at missing")
                card_ready = False
        if card_ready:
            ready += 1

    trails = payload.get("seasonal_trails")
    if not isinstance(trails, list) or not trails:
        errors.append("at least one seasonal trail is required")
    else:
        for trail in trails:
            if not isinstance(trail, dict):
                errors.append("seasonal trail must be an object")
                continue
            label = trail.get("id", "seasonal trail")
            if trail.get("archive_available") is not True:
                errors.append(f"{label}: archive_available must be true")
            if trail.get("deadline") is not None:
                errors.append(f"{label}: deadline must remain null")
            card_ids = trail.get("card_ids")
            if not isinstance(card_ids, list) or not set(card_ids).issubset(ids):
                errors.append(f"{label}: card_ids must reference Culture Trail cards")
            review = trail.get("review")
            if not isinstance(review, dict):
                errors.append(f"{label}: review must be an object")
            else:
                if review.get("status") != "approved":
                    blockers.append(f"{label}: seasonal review approval pending")
                if not review.get("reviewer_id"):
                    blockers.append(f"{label}: review.reviewer_id missing")
                if not review.get("reviewed_at"):
                    blockers.append(f"{label}: review.reviewed_at missing")

    if payload.get("status") != "published":
        blockers.append("pack status is not published")
    return errors, blockers, len(cards), ready


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("manifest", nargs="?", type=Path, default=DEFAULT_MANIFEST)
    parser.add_argument("--strict", action="store_true")
    args = parser.parse_args()
    errors, blockers, total, ready = validate(args.manifest)
    if errors:
        print("CULTURE MANIFEST: FAIL")
        for error in errors:
            print(f"ERROR • {error}")
        return 1
    print("CULTURE MANIFEST STRUCTURE: PASS")
    if blockers:
        print(f"CULTURE RELEASE: PENDING ({ready}/{total} cards ready)")
        for blocker in blockers[:20]:
            print(f"PENDING • {blocker}")
        if len(blockers) > 20:
            print(f"PENDING • {len(blockers) - 20} additional blockers")
        return 2 if args.strict else 0
    print(f"CULTURE RELEASE: PASS ({ready}/{total} cards ready)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
