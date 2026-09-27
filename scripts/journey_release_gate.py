#!/usr/bin/env python3
"""Validate Phase 3A story-language and culture-review evidence."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_MANIFEST = ROOT / "content/journey/phase3a_journey_manifest.json"


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
        "all_stories_require_language_and_culture_approval"
    ):
        errors.append("release policy must require language and culture approval")

    stories = payload.get("stories")
    if not isinstance(stories, list):
        return errors + ["stories must be a list"], blockers, 0, 0
    if len(stories) != 3:
        errors.append("Phase 3A core must contain exactly three stories")
    regions = payload.get("regions")
    if not isinstance(regions, list) or len(regions) != 3:
        errors.append("Phase 3A core must contain exactly three regions")

    ids: set[str] = set()
    node_ids: set[str] = set()
    ready = 0
    for index, story in enumerate(stories):
        if not isinstance(story, dict):
            errors.append(f"story {index + 1} must be an object")
            continue
        story_id = story.get("id")
        node_id = story.get("node_id")
        label = story_id if isinstance(story_id, str) else f"story {index + 1}"
        if not isinstance(story_id, str) or not story_id:
            errors.append(f"{label}: id missing")
        elif story_id in ids:
            errors.append(f"{label}: duplicate story id")
        else:
            ids.add(story_id)
        if not isinstance(node_id, str) or not node_id:
            errors.append(f"{label}: node_id missing")
        elif node_id in node_ids:
            errors.append(f"{label}: duplicate node_id")
        else:
            node_ids.add(node_id)
        targets = story.get("target_word_ids")
        if (
            not isinstance(targets, list)
            or len(targets) < 3
            or not all(isinstance(target, str) and target for target in targets)
            or len(set(targets)) != len(targets)
        ):
            errors.append(f"{label}: at least three target words required")

        story_ready = True
        for review_name in ("language_review", "culture_review"):
            review = story.get(review_name)
            if not isinstance(review, dict):
                errors.append(f"{label}: {review_name} must be an object")
                story_ready = False
                continue
            if review.get("status") != "approved":
                blockers.append(f"{label}: {review_name} approval pending")
                story_ready = False
            if not review.get("reviewer_id"):
                blockers.append(f"{label}: {review_name}.reviewer_id missing")
                story_ready = False
            if not review.get("reviewed_at"):
                blockers.append(f"{label}: {review_name}.reviewed_at missing")
                story_ready = False
        if story_ready:
            ready += 1

    if isinstance(regions, list):
        region_story_ids: list[str] = []
        for index, region in enumerate(regions):
            if not isinstance(region, dict) or not isinstance(
                region.get("story_ids"), list
            ):
                errors.append(f"region {index + 1}: story_ids must be a list")
                continue
            region_story_ids.extend(region["story_ids"])
        if set(region_story_ids) != ids or len(region_story_ids) != len(ids):
            errors.append("regions must reference every story exactly once")

    if payload.get("status") != "published":
        blockers.append("pack status is not published")
    return errors, blockers, len(stories), ready


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("manifest", nargs="?", type=Path, default=DEFAULT_MANIFEST)
    parser.add_argument("--strict", action="store_true")
    args = parser.parse_args()
    errors, blockers, total, ready = validate(args.manifest)
    if errors:
        print("JOURNEY MANIFEST: FAIL")
        for error in errors:
            print(f"ERROR • {error}")
        return 1

    print("JOURNEY MANIFEST STRUCTURE: PASS")
    if blockers:
        print(f"JOURNEY RELEASE: PENDING ({ready}/{total} stories ready)")
        for blocker in blockers[:20]:
            print(f"PENDING • {blocker}")
        if len(blockers) > 20:
            print(f"PENDING • {len(blockers) - 20} additional blockers")
        return 2 if args.strict else 0

    print(f"JOURNEY RELEASE: PASS ({ready}/{total} stories ready)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
