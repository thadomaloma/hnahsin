#!/usr/bin/env python3
"""Aggregate the complete Phase 3 release gate without inventing evidence."""

from __future__ import annotations

import argparse

from culture_release_gate import DEFAULT_MANIFEST as CULTURE_MANIFEST
from culture_release_gate import validate as validate_culture
from engagement_validation_gate import DEFAULT_CSV as ENGAGEMENT_CSV
from engagement_validation_gate import evaluate as validate_engagement
from journey_release_gate import DEFAULT_MANIFEST as JOURNEY_MANIFEST
from journey_release_gate import validate as validate_journey
from learner_validation_gate import DEFAULT_SESSIONS as LEARNER_SESSIONS
from learner_validation_gate import evaluate as validate_learners
from mac_verification_gate import validate as validate_mac
from phase3_review_workflow import validate as validate_reviews
from pilot_readiness_gate import validate as validate_pilot


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--strict", action="store_true")
    args = parser.parse_args()
    structural: list[str] = []
    pending: list[str] = []

    learner_errors, learner_blockers, _ = validate_learners(LEARNER_SESSIONS)
    journey_errors, journey_blockers, _, _ = validate_journey(JOURNEY_MANIFEST)
    culture_errors, culture_blockers, _, _ = validate_culture(CULTURE_MANIFEST)
    engagement_errors, engagement_blockers, _ = validate_engagement(ENGAGEMENT_CSV)
    review_errors, review_blockers, _ = validate_reviews()
    pilot_errors, pilot_blockers, _, _ = validate_pilot()
    mac_errors, mac_blockers = validate_mac()
    structural.extend(learner_errors)
    structural.extend(journey_errors + culture_errors + engagement_errors)
    structural.extend(review_errors + pilot_errors + mac_errors)
    pending.extend(learner_blockers)
    pending.extend(journey_blockers + culture_blockers + engagement_blockers)
    pending.extend(review_blockers + pilot_blockers + mac_blockers)

    if structural:
        print("PHASE 3 EXIT GATE: FAIL")
        for error in structural:
            print(f"ERROR • {error}")
        return 1
    if pending:
        print(f"PHASE 3 EXIT GATE: PENDING ({len(pending)} blockers)")
        for blocker in pending[:30]:
            print(f"PENDING • {blocker}")
        if len(pending) > 30:
            print(f"PENDING • {len(pending) - 30} additional blockers")
        return 2 if args.strict else 0
    print("PHASE 3 EXIT GATE: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
