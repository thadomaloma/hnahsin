# Phase 3C — Release Gate Closure & Community Pilot Preparation

**Build:** 0.9.1+19  
**Date:** 13 September 2026  
**Status:** **CORE IMPLEMENTED — HUMAN EVIDENCE PENDING**

## Outcome

Phase 3 now has one auditable route from preview content to reviewed manifests,
community-pilot readiness, four-week engagement evidence and verified Mac build
evidence. The app also defaults to gentle engagement so recognition cannot turn
into streak pressure.

## Delivered

| Capability | Implementation |
|---|---|
| Gentle engagement | Default-on setting hides streak counts and labels quests optional/no-penalty |
| Backward compatibility | Older saved profiles default safely to gentle mode |
| Review handoff | Exact 19-decision story/card/seasonal review queue |
| Safe promotion | Validated `--apply` flow updates review objects and pack status only |
| Pilot readiness | Eight-control privacy, support, consent and accessibility checklist |
| Mac evidence | Structured evidence written only after validators, format, analyze, tests and build pass |
| Aggregate gate | One strict command combines upstream audio/learner, content, review, pilot, cohort and Mac blockers |
| Operations | Reviewer handoff and community pilot incident/withdrawal runbooks |

## Honest evidence snapshot

| Gate | Current evidence | Status |
|---|---:|---|
| Phase 3 review decisions | 0/19 approved | Pending |
| Pilot readiness controls | 1/8 ready | Pending |
| Culture cards | 0/6 approved | Pending |
| Stories | 0/3 approved | Pending |
| Cohort | 0/15 participants; 0/60 rows | Pending |
| Mac verification | Not run in preparation environment | Pending |

These values are intentionally not converted into pass evidence by source-code
work. Qualified reviewers, pilot owners, real learners and a Mac run are needed.

## Commands

```bash
python3 scripts/phase3_review_workflow.py
python3 scripts/pilot_readiness_gate.py
python3 scripts/mac_verification_gate.py
python3 scripts/phase3_exit_gate.py
```

Authoritative exit review:

```bash
python3 scripts/phase3_exit_gate.py --strict
```

Mac technical verification:

```bash
./run_mac.command check
```

Phase 4 may be developed after this package, but community/public release must
not treat Phase 3 as closed until the strict gate passes.
