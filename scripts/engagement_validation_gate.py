#!/usr/bin/env python3
"""Evaluate privacy-minimal four-week Phase 3B cohort evidence."""

from __future__ import annotations

import argparse
import csv
from collections import defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CSV = ROOT / "validation/phase3b/engagement_weeks.csv"
EXPECTED_FIELDS = (
    "participant_id",
    "segment",
    "week",
    "guardian_consent",
    "session_count",
    "story_completions",
    "culture_cards_read",
    "returned_next_week",
    "repetition_acceptable",
    "healthy_stop_understood",
    "reward_age_fit",
    "no_pressure_felt",
    "core_learning_unblocked",
    "critical_blocker",
    "screen_reader_checked",
    "text_200_checked",
)
SEGMENTS = ("early_5_7", "diaspora_8_17", "adult_heritage")
YES_NO_FIELDS = (
    "guardian_consent",
    "repetition_acceptable",
    "healthy_stop_understood",
    "reward_age_fit",
    "no_pressure_felt",
    "core_learning_unblocked",
    "critical_blocker",
    "screen_reader_checked",
    "text_200_checked",
)


def _rate(rows: list[dict[str, str]], field: str) -> float:
    return sum(row[field] == "yes" for row in rows) / len(rows) if rows else 0.0


def evaluate(path: Path) -> tuple[list[str], list[str], list[dict[str, str]]]:
    errors: list[str] = []
    blockers: list[str] = []
    try:
        with path.open(newline="", encoding="utf-8-sig") as stream:
            reader = csv.DictReader(stream)
            if tuple(reader.fieldnames or ()) != EXPECTED_FIELDS:
                return ["CSV header does not match the Phase 3B contract"], [], []
            rows = list(reader)
    except OSError as error:
        return [f"CSV cannot be read: {error}"], [], []

    seen: set[tuple[str, int]] = set()
    by_participant: dict[str, list[dict[str, str]]] = defaultdict(list)
    participant_segment: dict[str, str] = {}
    for index, row in enumerate(rows, start=2):
        participant = row["participant_id"].strip()
        segment = row["segment"].strip()
        if not participant:
            errors.append(f"row {index}: participant_id missing")
        if segment not in SEGMENTS:
            errors.append(f"row {index}: invalid segment {segment!r}")
        try:
            week = int(row["week"])
        except ValueError:
            errors.append(f"row {index}: week must be 1 through 4")
            continue
        if week not in (1, 2, 3, 4):
            errors.append(f"row {index}: week must be 1 through 4")
        key = (participant, week)
        if participant and key in seen:
            errors.append(f"row {index}: duplicate participant/week")
        seen.add(key)
        if participant in participant_segment and participant_segment[participant] != segment:
            errors.append(f"row {index}: participant segment changed")
        participant_segment[participant] = segment

        for field in YES_NO_FIELDS:
            if row[field] not in ("yes", "no"):
                errors.append(f"row {index}: {field} must be yes or no")
        if row["returned_next_week"] not in ("yes", "no", "na"):
            errors.append(f"row {index}: returned_next_week must be yes, no or na")
        if week == 4 and row["returned_next_week"] != "na":
            errors.append(f"row {index}: week 4 returned_next_week must be na")
        if week < 4 and row["returned_next_week"] == "na":
            errors.append(f"row {index}: weeks 1–3 require a return outcome")
        for field in ("session_count", "story_completions", "culture_cards_read"):
            try:
                if int(row[field]) < 0:
                    raise ValueError
            except ValueError:
                errors.append(f"row {index}: {field} must be a non-negative integer")
        if segment in ("early_5_7", "diaspora_8_17") and row["guardian_consent"] != "yes":
            errors.append(f"row {index}: child/teen row requires guardian consent")
        by_participant[participant].append(row)

    if errors:
        return errors, blockers, rows

    segment_participants = {
        segment: {
            participant
            for participant, participant_rows in by_participant.items()
            if participant_rows and participant_rows[0]["segment"] == segment
        }
        for segment in SEGMENTS
    }
    for segment, participants in segment_participants.items():
        if len(participants) < 5:
            blockers.append(f"{segment}: need 5 participants; found {len(participants)}")
    for participant, participant_rows in by_participant.items():
        weeks = {int(row["week"]) for row in participant_rows}
        if weeks != {1, 2, 3, 4}:
            blockers.append(f"{participant}: four weekly rows required")

    active_rows = [row for row in rows if int(row["session_count"]) > 0]
    return_rows = [row for row in rows if row["returned_next_week"] != "na"]
    if _rate(return_rows, "returned_next_week") < 0.60:
        blockers.append("voluntary next-week return must be at least 60%")
    if _rate(active_rows, "repetition_acceptable") < 0.90:
        blockers.append("acceptable repetition must be at least 90%")
    if _rate(active_rows, "healthy_stop_understood") < 0.90:
        blockers.append("healthy stopping understanding must be at least 90%")
    if _rate(active_rows, "reward_age_fit") < 0.80:
        blockers.append("age-fit reward approval must be at least 80%")
    if active_rows and _rate(active_rows, "no_pressure_felt") < 1.0:
        blockers.append("no-pressure experience must be 100%")
    if active_rows and _rate(active_rows, "core_learning_unblocked") < 1.0:
        blockers.append("core learning unblocked must be 100%")
    if any(row["critical_blocker"] == "yes" for row in rows):
        blockers.append("critical blockers must be zero")
    for segment in SEGMENTS:
        segment_rows = [row for row in active_rows if row["segment"] == segment]
        if sum(row["screen_reader_checked"] == "yes" for row in segment_rows) < 2:
            blockers.append(f"{segment}: need two screen-reader evidence rows")
        if sum(row["text_200_checked"] == "yes" for row in segment_rows) < 2:
            blockers.append(f"{segment}: need two 200% text evidence rows")
    return errors, blockers, rows


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("csv_path", nargs="?", type=Path, default=DEFAULT_CSV)
    parser.add_argument("--strict", action="store_true")
    args = parser.parse_args()
    errors, blockers, rows = evaluate(args.csv_path)
    if errors:
        print("ENGAGEMENT VALIDATION STRUCTURE: FAIL")
        for error in errors:
            print(f"ERROR • {error}")
        return 1
    participants = len({row["participant_id"] for row in rows})
    print("ENGAGEMENT VALIDATION STRUCTURE: PASS")
    if blockers:
        print(
            f"PHASE 3 ENGAGEMENT EXIT GATE: PENDING "
            f"({participants}/15 participants, {len(rows)}/60 weekly rows)"
        )
        for blocker in blockers[:20]:
            print(f"PENDING • {blocker}")
        if len(blockers) > 20:
            print(f"PENDING • {len(blockers) - 20} additional blockers")
        return 2 if args.strict else 0
    print(
        f"PHASE 3 ENGAGEMENT EXIT GATE: PASS "
        f"({participants} participants, {len(rows)} weekly rows)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
