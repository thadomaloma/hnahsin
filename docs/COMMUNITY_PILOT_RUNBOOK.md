# Phase 3C Community Pilot Runbook

## Evidence integrity

No fabricated evidence. Do not prefill positive answers, remove dropouts or
copy one learner into several participant IDs.

## Before recruitment

- Complete every control in `validation/phase3c/pilot_readiness.json`.
- Approve the plain-language privacy notice and withdrawal/deletion route.
- Assign an opaque support owner and test the incident route.
- Keep signed guardian consent outside the repository.
- Disclose clearly that unapproved language/culture content is preview content.

Run:

```bash
python3 scripts/pilot_readiness_gate.py --strict
```

Do not begin a community cohort until this passes.

## Cohort and weekly routine

Recruit five learners from each segment: ages 5–7, diaspora ages 8–17 and adult
heritage learners. Use opaque IDs only. Each participant gets four weekly rows
in `validation/phase3b/engagement_weeks.csv`, including zero-session rows when
they do not return. Week 4 uses `na` for next-week return.

The facilitator checks task completion, voluntary return, repetition, healthy
stopping, age-fit rewards, no-pressure experience, core-learning access and the
assigned screen-reader/200%-text coverage.

## Incident route

- **Severity 1:** safety, privacy exposure, crash/data loss, payment or learning
  blocked. Stop the affected pilot path immediately and notify the support owner.
- **Severity 2:** inaccessible task, misleading cultural claim or repeated
  completion failure. Pause that item and create a tracked correction.
- **Severity 3:** minor copy/layout issue. Record it without coaching the answer.

Anyone may withdraw at any time without losing access to learning. Remove their
linked private consent record and preserve only an anonymous zero-session row
when needed for honest cohort accounting.

## Exit review

```bash
python3 scripts/engagement_validation_gate.py --strict
python3 scripts/phase3_exit_gate.py --strict
```

Phase 3 passes only when upstream audio/learner, content, pilot, engagement and
Mac evidence gates pass with zero critical blockers.
