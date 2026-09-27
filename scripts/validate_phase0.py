#!/usr/bin/env python3
"""Dependency-free validation for Thumal Quest Phase 0 artifacts."""

from __future__ import annotations

import csv
import json
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def fail(message: str) -> None:
    print(f"ERROR: {message}")
    raise SystemExit(1)


def read_csv(relative_path: str) -> list[dict[str, str]]:
    path = ROOT / relative_path
    if not path.is_file():
        fail(f"Missing {relative_path}")
    with path.open(encoding="utf-8", newline="") as handle:
        return list(csv.DictReader(handle))


def require_unique(rows: list[dict[str, str]], field: str, label: str) -> None:
    values = [row.get(field, "") for row in rows]
    if any(not value for value in values):
        fail(f"{label} has an empty {field}")
    duplicates = sorted({value for value in values if values.count(value) > 1})
    if duplicates:
        fail(f"{label} duplicate {field}: {', '.join(duplicates)}")


def validate_documents() -> None:
    required = [
        "MASTER_ROADMAP.md",
        "PHASE_0_SPRINT.md",
        "PRODUCT_REQUIREMENTS.md",
        "LEARNER_PERSONAS.md",
        "CONTENT_EDITORIAL_GUIDE.md",
        "CONTENT_SCHEMA_V2.md",
        "UX_PRODUCT_FLOW.md",
        "ARCHITECTURE_ADR.md",
        "GAME_ENGINE_V2_SPEC.md",
        "PRIVACY_DATA_INVENTORY.md",
        "MAC_SETUP.md",
        "PHASE_0_GATE_REPORT.md",
        "PRODUCT_DECISION_RECORD.md",
        "VALIDATION_PLAYBOOK.md",
    ]
    missing = [name for name in required if not (ROOT / "docs" / name).is_file()]
    if missing:
        fail(f"Missing Phase 0 documents: {', '.join(missing)}")

    decision = (ROOT / "docs/PRODUCT_DECISION_RECORD.md").read_text(encoding="utf-8")
    if "**Status:** **APPROVED**" not in decision:
        fail("PDR-001 product defaults are not recorded as approved")
    approved_ids = [f"PD-0{index}" for index in range(1, 7)]
    missing_ids = [decision_id for decision_id in approved_ids if decision_id not in decision]
    if missing_ids:
        fail(f"PDR-001 is missing decisions: {', '.join(missing_ids)}")


def validate_schema_and_sample() -> None:
    schema_path = ROOT / "content/schema/content_item.schema.json"
    sample_path = ROOT / "content/pilot/sample_word_item.json"
    try:
        schema = json.loads(schema_path.read_text(encoding="utf-8"))
        sample = json.loads(sample_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        fail(f"Content JSON could not be read: {error}")

    required = schema.get("required", [])
    missing = [field for field in required if field not in sample]
    if missing:
        fail(f"Sample item missing required fields: {', '.join(missing)}")
    if sample.get("schema_version") != "2.0":
        fail("Sample item must use schema 2.0")
    if sample.get("status") != "draft":
        fail("Phase 0 sample must remain draft until human approval")
    if sample.get("language") != "lus":
        fail("Mizo content language must be lus")


def validate_pilot() -> None:
    candidates = read_csv("content/pilot/pilot_candidates.csv")
    sentences = read_csv("content/pilot/pilot_sentences.csv")

    if len(candidates) != 100:
        fail(f"Expected 100 candidate words, found {len(candidates)}")
    if len(sentences) != 40:
        fail(f"Expected 40 candidate sentences, found {len(sentences)}")

    require_unique(candidates, "candidate_id", "pilot candidates")
    require_unique(sentences, "sentence_id", "pilot sentences")

    candidate_ids = {row["candidate_id"] for row in candidates}
    for row in sentences:
        for candidate_id in row["linked_candidate_ids"].split("|"):
            if candidate_id and candidate_id not in candidate_ids:
                fail(f"Sentence {row['sentence_id']} references {candidate_id}")

    accidentally_released = [
        row["candidate_id"]
        for row in candidates
        if row["status"] in {"approved", "published"}
    ]
    if accidentally_released:
        fail("Pilot candidates cannot be approved without human review")

    print("Pilot pack: 100 words, 40 sentences")


def main() -> None:
    validate_documents()
    validate_schema_and_sample()
    validate_pilot()
    print("Product defaults: PDR-001 approved (PD-01 through PD-06)")
    print("Phase 0 artifact validation: PASS")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(130)
