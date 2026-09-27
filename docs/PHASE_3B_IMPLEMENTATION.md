# Phase 3B — Culture Trail, Collections & Engagement Validation

**Build:** 0.9.0+16  
**Date:** 13 September 2026  
**Status:** **CORE IMPLEMENTED — EVIDENCE COLLECTION PENDING**

## Outcome

The Mizo Journey now includes a review-gated Culture Trail, a collection room,
claimable daily/weekly recognition and a measurable four-week engagement study.
Trail Marks unlock optional visual identity only: lessons, reviews, stories and
culture learning are never sold or blocked by marks.

## Delivered

| Capability | Implementation |
|---|---|
| Culture Trail | Six Mizo-first cards covering values, community, heritage, celebration and language |
| Tawng Upa context | Meaning, living context, example sentence and optional English support |
| TQ progression | Three entry cards at TQ0; richer heritage cards open at TQ1/TQ2 |
| Collection room | Culture cards, Story rewards and three collection milestones |
| Age-responsive identity | Child/adult labels and three selectable avatar styles |
| Trail Marks | Idempotent daily/weekly quest claims; recognition-only, not spendable currency |
| Weekly engagement | Story and Culture Trail goals with no countdown pressure |
| Seasonal framework | Chapchar Kut trail remains available through an archive with no deadline |
| Content safety | Six cards and the seasonal trail require language/culture approval |
| Issue reporting | Every Culture Card connects to the existing local content-report path |
| Cohort validation | Privacy-minimal 15-participant, 60-row, four-week evidence contract |

## Evidence snapshot

| Gate | Current evidence | Status |
|---|---:|---|
| Language/culture-approved cards | 0/6 | Pending |
| Approved seasonal trails | 0/1 | Pending |
| Cohort participants | 0/15 | Pending |
| Four-week evidence rows | 0/60 | Pending |
| Mac analyze/test/native build | Not run in preparation environment | Pending |

These are accurate zeros. Empty evidence cannot satisfy a strict gate.

## Commands

Progress reports:

```bash
python3 scripts/culture_release_gate.py
python3 scripts/engagement_validation_gate.py
```

Authoritative blockers:

```bash
python3 scripts/culture_release_gate.py --strict
python3 scripts/engagement_validation_gate.py --strict
python3 scripts/journey_release_gate.py --strict
./run_mac.command check
```

## Remaining human work

- Two qualified Mizo reviewers check every term, sentence and English support
- Culture reviewer checks history, representation and contemporary context
- Record real reviewer IDs/dates and publish only after all approvals
- Recruit at least five learners in each of the three priority segments
- Complete four weekly rows per participant without names/contact details
- Resolve any pressure, blocked-learning or critical usability report
- Run Flutter analyzer, all tests and native builds on the verified Mac

Phase 3B code is implemented. Phase 3 remains evidence-gate pending until the
content, cohort and Mac strict checks pass.
