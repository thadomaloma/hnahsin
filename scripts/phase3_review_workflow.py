#!/usr/bin/env python3
"""Validate and safely apply Phase 3 story/culture review decisions."""

from __future__ import annotations

import argparse
import csv
import json
import re
from datetime import datetime
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CSV = ROOT / "validation/phase3c/review_decisions.csv"
JOURNEY_MANIFEST = ROOT / "content/journey/phase3a_journey_manifest.json"
CULTURE_MANIFEST = ROOT / "content/journey/phase3b_culture_manifest.json"
EXPECTED_FIELDS = (
    "content_id",
    "content_type",
    "review_type",
    "decision",
    "reviewer_id",
    "reviewed_at",
    "notes",
)
DECISIONS = {"pending", "approved", "rejected"}
REVIEWER_ID = re.compile(r"^[A-Za-z0-9._-]{2,64}$")


def _read_json(path: Path) -> dict[str, object]:
    return json.loads(path.read_text(encoding="utf-8"))


def _catalogs() -> tuple[
    dict[tuple[str, str], tuple[str, str]],
    dict[str, object],
    dict[str, object],
]:
    journey = _read_json(JOURNEY_MANIFEST)
    culture = _read_json(CULTURE_MANIFEST)
    expected: dict[tuple[str, str], tuple[str, str]] = {}
    for story in journey.get("stories", []):
        story_id = story["id"]
        expected[(story_id, "language")] = ("story", "language_review")
        expected[(story_id, "culture")] = ("story", "culture_review")
    for card in culture.get("cards", []):
        card_id = card["id"]
        expected[(card_id, "language")] = ("culture_card", "language_review")
        expected[(card_id, "culture")] = ("culture_card", "culture_review")
    for trail in culture.get("seasonal_trails", []):
        expected[(trail["id"], "culture")] = ("seasonal_trail", "review")
    return expected, journey, culture


def _parse_reviewed_at(value: str) -> bool:
    if not value:
        return False
    try:
        datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError:
        return False
    return True


def validate(
    csv_path: Path = DEFAULT_CSV,
) -> tuple[list[str], list[str], list[dict[str, str]]]:
    errors: list[str] = []
    blockers: list[str] = []
    expected, journey, culture = _catalogs()
    manifest_reviews: dict[tuple[str, str], dict[str, object]] = {}
    for story in journey.get("stories", []):
        manifest_reviews[(story["id"], "language")] = story["language_review"]
        manifest_reviews[(story["id"], "culture")] = story["culture_review"]
    for card in culture.get("cards", []):
        manifest_reviews[(card["id"], "language")] = card["language_review"]
        manifest_reviews[(card["id"], "culture")] = card["culture_review"]
    for trail in culture.get("seasonal_trails", []):
        manifest_reviews[(trail["id"], "culture")] = trail["review"]
    try:
        with csv_path.open(newline="", encoding="utf-8-sig") as stream:
            reader = csv.DictReader(stream)
            if tuple(reader.fieldnames or ()) != EXPECTED_FIELDS:
                return ["review CSV header does not match the contract"], [], []
            rows = list(reader)
    except OSError as error:
        return [f"review CSV cannot be read: {error}"], [], []

    seen: set[tuple[str, str]] = set()
    for line, row in enumerate(rows, start=2):
        key = (row["content_id"].strip(), row["review_type"].strip())
        if key in seen:
            errors.append(f"row {line}: duplicate content/review pair")
        seen.add(key)
        if key not in expected:
            errors.append(f"row {line}: unknown content/review pair {key}")
            continue
        expected_type, _ = expected[key]
        if row["content_type"] != expected_type:
            errors.append(f"row {line}: content_type must be {expected_type}")
        decision = row["decision"].strip()
        if decision not in DECISIONS:
            errors.append(f"row {line}: decision must be pending, approved or rejected")
            continue
        reviewer_id = row["reviewer_id"].strip()
        reviewed_at = row["reviewed_at"].strip()
        if decision == "pending":
            blockers.append(f"{key[0]}: {key[1]} review pending")
            if reviewer_id or reviewed_at:
                errors.append(f"row {line}: pending decision must not claim reviewer/date")
        else:
            if not REVIEWER_ID.fullmatch(reviewer_id):
                errors.append(f"row {line}: use an opaque reviewer_id")
            if not _parse_reviewed_at(reviewed_at):
                errors.append(f"row {line}: reviewed_at must be ISO-8601")
            if decision == "rejected":
                blockers.append(f"{key[0]}: {key[1]} review rejected")
                if not row["notes"].strip():
                    errors.append(f"row {line}: rejected decision requires notes")
        manifest_review = manifest_reviews[key]
        if (
            manifest_review.get("status") != decision
            or (manifest_review.get("reviewer_id") or "") != reviewer_id
            or (manifest_review.get("reviewed_at") or "") != reviewed_at
        ):
            blockers.append(f"{key[0]}: {key[1]} decision not applied to manifest")
    missing = set(expected) - seen
    if missing:
        errors.append(f"review CSV is missing {len(missing)} required decisions")
    if len(rows) != len(expected):
        errors.append(f"review CSV must contain exactly {len(expected)} rows")
    return errors, blockers, rows


def apply_decisions(csv_path: Path = DEFAULT_CSV) -> tuple[int, int]:
    errors, _, rows = validate(csv_path)
    if errors:
        raise ValueError("; ".join(errors))
    expected, journey, culture = _catalogs()
    story_by_id = {item["id"]: item for item in journey["stories"]}
    card_by_id = {item["id"]: item for item in culture["cards"]}
    trail_by_id = {item["id"]: item for item in culture["seasonal_trails"]}
    approved = 0
    for row in rows:
        key = (row["content_id"], row["review_type"])
        content_type, review_field = expected[key]
        item = {
            "story": story_by_id,
            "culture_card": card_by_id,
            "seasonal_trail": trail_by_id,
        }[content_type][row["content_id"]]
        decision = row["decision"]
        item[review_field] = {
            "status": decision,
            "reviewer_id": row["reviewer_id"] or None,
            "reviewed_at": row["reviewed_at"] or None,
        }
        if decision == "approved":
            approved += 1

    journey_reviews = [
        story[field]["status"]
        for story in journey["stories"]
        for field in ("language_review", "culture_review")
    ]
    culture_reviews = [
        card[field]["status"]
        for card in culture["cards"]
        for field in ("language_review", "culture_review")
    ] + [trail["review"]["status"] for trail in culture["seasonal_trails"]]
    journey["status"] = (
        "published" if all(value == "approved" for value in journey_reviews)
        else "review_required"
    )
    culture["status"] = (
        "published" if all(value == "approved" for value in culture_reviews)
        else "review_required"
    )
    JOURNEY_MANIFEST.write_text(
        json.dumps(journey, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    CULTURE_MANIFEST.write_text(
        json.dumps(culture, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    return approved, len(rows)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("csv_path", nargs="?", type=Path, default=DEFAULT_CSV)
    parser.add_argument("--apply", action="store_true")
    parser.add_argument("--strict", action="store_true")
    args = parser.parse_args()
    errors, blockers, rows = validate(args.csv_path)
    if errors:
        print("PHASE 3 REVIEW WORKFLOW: FAIL")
        for error in errors:
            print(f"ERROR • {error}")
        return 1
    if args.apply:
        approved, total = apply_decisions(args.csv_path)
        print(f"PHASE 3 REVIEW MANIFESTS UPDATED ({approved}/{total} approvals)")
        errors, blockers, rows = validate(args.csv_path)
    approved = sum(row["decision"] == "approved" for row in rows)
    if blockers:
        print(f"PHASE 3 REVIEW WORKFLOW: PENDING ({approved}/{len(rows)} approvals)")
        for blocker in blockers[:20]:
            print(f"PENDING • {blocker}")
        return 2 if args.strict else 0
    print(f"PHASE 3 REVIEW WORKFLOW: PASS ({approved}/{len(rows)} approvals)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
