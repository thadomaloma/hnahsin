# Phase 3A — Mizo Journey, Story & Engagement Core

**Build:** 0.8.0+15  
**Date:** 13 September 2026  
**Status:** **CORE IMPLEMENTED — REVIEW EVIDENCE PENDING**

## Outcome

Thumal Quest now turns isolated lessons into a persistent, story-led Mizo
journey. The experience is local-first, age-responsive and deliberately gentle:
there is no energy timer, paid unlock, public leaderboard or fear-of-missing-out
countdown. Phase 2C audio and learner-validation gates remain unchanged and
pending.

## Delivered

| Capability | Implementation |
|---|---|
| Mizo Journey | Three-region map: Home & Community, Hills & Nature, Living Culture |
| Story Quest | Three branching conversation stories with Mizo-first text and optional English support |
| Learning safety | Natural replies are required; incorrect choices provide corrective Mizo feedback without punishment |
| Learning loop | Story target words enter the Phase 2A mastery and spaced-repetition schedule once |
| Progression | Prerequisite and TQ-level locks; replay cannot duplicate collection progress |
| Collection | One culture card and age-responsive cosmetic/achievement mark per story |
| Daily engagement | Story, word-review and culture tasks generated from local calendar days |
| Weekly rhythm | Three-story weekly target presented without a countdown or loss threat |
| Streak grace | One missed day can be absorbed; longer absence restarts gently at one |
| Comeback | No shame or lost-progress message after an absence |
| Healthy stopping | Every story ends with an explicit safe stopping point |
| Persistence | Journey, collection, action counts, grace and stopping acknowledgements stored locally |
| Release safety | Story pack fails closed until language and culture reviews are approved |

## Content evidence snapshot

| Gate | Current evidence | Status |
|---|---:|---|
| Playable preview stories | 3/3 | Implemented |
| Language-approved stories | 0/3 | Pending |
| Culture-approved stories | 0/3 | Pending |
| Mac analyze/test/native build | Not run in preparation environment | Pending |

The three stories are preview content only. Their `reviewRequired` state is
intentional; it must not be changed merely to make the strict gate pass.

## Commands

Non-blocking status report:

```bash
python3 scripts/journey_release_gate.py
```

Authoritative content gate:

```bash
python3 scripts/journey_release_gate.py --strict
./run_mac.command check
```

## Remaining human work

- Two qualified reviewers check natural Mizo, spelling and age suitability
- A culture reviewer checks representation, context and the tlawmngaihna note
- Reviewer identity/date fields are entered in the manifest
- Story pack status changes to `published` only after every approval
- Child and adult learners verify that rewards and story tone feel distinct
- Four-week internal cohort checks repetition, voluntary return and healthy exit
- Mac runs formatter, analyzer, Flutter tests and native debug build

Phase 3A is technically implemented, but the wider Phase 3 exit gate remains
open until reviewer, cohort and Mac evidence is real.
