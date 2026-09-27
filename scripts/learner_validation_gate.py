#!/usr/bin/env python3
"""Evaluate privacy-minimal Phase 2C learner-session evidence."""

from __future__ import annotations

import argparse
import csv
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SESSIONS = ROOT / "validation/phase2c/learner_sessions.csv"
SEGMENTS = (
    "early_5_7",
    "young_8_13_diaspora",
    "heritage_teen_adult",
)
EXPECTED_FIELDS = (
    "session_id",
    "segment",
    "age_band",
    "diaspora",
    "guardian_consent",
    "first_lesson_unassisted",
    "feedback_next_action",
    "safe_exit",
    "critical_blocker",
    "listen_pick_completed",
    "sentence_builder_completed",
    "voiceover_checked",
    "text_200_checked",
)
BOOLEAN_FIELDS = (
    "diaspora",
    "first_lesson_unassisted",
    "feedback_next_action",
    "safe_exit",
    "critical_blocker",
    "listen_pick_completed",
    "sentence_builder_completed",
    "voiceover_checked",
    "text_200_checked",
)


def _yes(value: str) -> bool:
    return value.strip().lower() == "yes"


def _ratio(rows: list[dict[str, str]], field: str) -> float:
    return sum(_yes(row[field]) for row in rows) / len(rows) if rows else 0


def evaluate(path: Path) -> tuple[list[str], list[str], list[dict[str, str]]]:
    errors: list[str] = []
    blockers: list[str] = []
    try:
        with path.open(newline="", encoding="utf-8-sig") as stream:
            reader = csv.DictReader(stream)
            if tuple(reader.fieldnames or ()) != EXPECTED_FIELDS:
                return ["CSV header does not match the Phase 2C contract"], [], []
            rows = [
                {key: (value or "").strip() for key, value in row.items()}
                for row in reader
                if any((value or "").strip() for value in row.values())
            ]
    except OSError as error:
        return [f"session file unreadable: {error}"], [], []

    seen_ids: set[str] = set()
    for line, row in enumerate(rows, start=2):
        session_id = row["session_id"]
        if not session_id:
            errors.append(f"row {line}: session_id is required")
        elif session_id in seen_ids:
            errors.append(f"row {line}: duplicate session_id {session_id}")
        seen_ids.add(session_id)
        if row["segment"] not in SEGMENTS:
            errors.append(f"row {line}: unknown segment {row['segment']!r}")
        for field in BOOLEAN_FIELDS:
            if row[field].lower() not in ("yes", "no"):
                errors.append(f"row {line}: {field} must be yes or no")
        consent = row["guardian_consent"].lower()
        if consent not in ("yes", "no", "not_required"):
            errors.append(
                f"row {line}: guardian_consent must be yes, no or not_required"
            )
        if row["age_band"] in ("early", "young") and consent != "yes":
            blockers.append(f"{session_id or f'row {line}'}: guardian consent missing")

    if errors:
        return errors, blockers, rows

    counts = Counter(row["segment"] for row in rows)
    for segment in SEGMENTS:
        if counts[segment] < 10:
            blockers.append(f"{segment}: need 10 sessions; found {counts[segment]}")

    if _ratio(rows, "first_lesson_unassisted") < 0.8:
        blockers.append("first lesson unassisted must be at least 80%")
    if _ratio(rows, "feedback_next_action") < 0.9:
        blockers.append("next action after feedback must be at least 90%")
    if rows and _ratio(rows, "safe_exit") < 1:
        blockers.append("safe exit must be 100%")
    if any(_yes(row["critical_blocker"]) for row in rows):
        blockers.append("critical usability/accessibility blocker recorded")
    if _ratio(rows, "listen_pick_completed") < 0.8:
        blockers.append("Listen & Pick completion must be at least 80%")
    if _ratio(rows, "sentence_builder_completed") < 0.8:
        blockers.append("Sentence Builder completion must be at least 80%")

    for segment in SEGMENTS:
        segment_rows = [row for row in rows if row["segment"] == segment]
        if sum(_yes(row["voiceover_checked"]) for row in segment_rows) < 2:
            blockers.append(f"{segment}: need two VoiceOver evidence sessions")
        if sum(_yes(row["text_200_checked"]) for row in segment_rows) < 2:
            blockers.append(f"{segment}: need two 200% text evidence sessions")

    return errors, blockers, rows


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--sessions", type=Path, default=DEFAULT_SESSIONS)
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Exit non-zero until sample and success thresholds pass.",
    )
    args = parser.parse_args()
    errors, blockers, rows = evaluate(args.sessions)

    if errors:
        print("LEARNER VALIDATION DATA: INVALID")
        for error in errors:
            print(f"ERROR • {error}")
        return 1

    print("LEARNER VALIDATION STRUCTURE: PASS")
    print(
        f"LEARNER EXIT GATE: {'PASS' if not blockers else 'PENDING'} "
        f"({len(rows)} sessions)"
    )
    for blocker in blockers:
        print(f"PENDING • {blocker}")
    if args.strict and blockers:
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
