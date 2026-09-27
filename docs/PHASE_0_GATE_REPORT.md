# Phase 0 Gate Report

**Report version:** 0.2  
**Date:** 13 September 2026  
**Overall status:** **IN PROGRESS — foundation prepared, human/Mac validation pending**

## Executive result

Phase 0 technical/product foundation package is now present in the repository.
All machine-checkable content inventory and document-structure checks pass in
the available environment. Phase 0 is not declared complete because Mizo
language approvals, learner usability sessions and a real Mac Flutter/Xcode
build still require named people/devices. Recommended product defaults were
approved by the product owner on 13 September 2026 in `PRODUCT_DECISION_RECORD.md`.

## Deliverable status

| Deliverable | Evidence | Status |
|---|---|---|
| Master roadmap | `MASTER_ROADMAP.md` | Complete |
| Sprint plan | `PHASE_0_SPRINT.md` | Complete |
| Product requirements | `PRODUCT_REQUIREMENTS.md` + `PRODUCT_DECISION_RECORD.md` | Product defaults approved |
| Learner personas | `LEARNER_PERSONAS.md` | Draft complete; research pending |
| Editorial guide | `CONTENT_EDITORIAL_GUIDE.md` | Draft complete; Council approval pending |
| Content schema V2 | Doc + JSON Schema + sample item | Machine-valid draft |
| Candidate word pack | `pilot_candidates.csv` | 100/100 drafted; human review pending |
| Candidate sentences | `pilot_sentences.csv` | 40/40 drafted; human review pending |
| Audio recording sheet | `pilot_audio_script.csv` | 30/30 planned; recording/review pending |
| UX flow | `UX_PRODUCT_FLOW.md` | 20-screen handoff complete; usability pending |
| Architecture ADR | `ARCHITECTURE_ADR.md` | Product boundary accepted; engineer approval pending |
| Game Engine V2 | `GAME_ENGINE_V2_SPEC.md` | Draft complete; Phase 1 implementation pending |
| Privacy inventory | `PRIVACY_DATA_INVENTORY.md` | Current/planned data mapped; legal review pending |
| Mac run path | `run_mac.command` + `MAC_SETUP.md` | Improved; actual Mac execution pending |
| CI baseline | `.github/workflows/flutter-ci.yml` | Added; first repository run pending |
| Artifact validator | `scripts/validate_phase0.py` | Pass |

## Exit-gate scorecard

| Gate | Result | Blocking evidence/action |
|---|---|---|
| Fresh Mac build/run | Pending | Run `./run_mac.command check` on user’s Mac |
| PRD/priority cohort approved | **Passed** | PDR-001 approved 13 September 2026 |
| Two Mizo reviewers appointed | Blocked | Names/roles not yet supplied |
| 100 words + 40 sentences approved | Blocked | All deliberately remain `draft` |
| 30 native audio clips approved | Blocked | Speaker/consent/recording required |
| Three-segment UX test | Blocked | Minimum 14 participants not yet tested |
| Architecture ADR approved | Pending | Product/engineering sign-off |
| Game Engine V2 spec approved | Pending | Learning/engineering sign-off |
| Child-data inventory complete | Partial | Generated platform manifests/SDK tree and legal review pending |
| CI green | Pending | Project not connected/run on CI in this environment |

**Phase 0 pass:** No. This is an honest gate, not a failure: all work that can be
prepared locally has been prepared; human/device evidence remains.

## Automated checks run here

- Bash syntax for Mac launcher: passed
- JSON syntax for content schema/sample: passed
- Required Phase 0 document inventory: passed
- Pilot CSV counts: 100 words / 40 sentences / 30 audio rows
- Candidate, sentence and audio IDs unique: passed
- Cross-file pilot references: passed
- Accidental `approved`/`published` candidate detection: passed
- Markdown code-fence balance scan: passed
- ZIP integrity: passed for Phase 0 Foundation V2 package

Flutter is not installed in the execution environment used to prepare this
package; therefore `flutter pub get`, `flutter analyze`, `flutter test` and
native builds cannot truthfully be reported as passed here. The Mac launcher
and CI execute those checks in environments where Flutter is available.

## Audit issues carried into Phase 1

### Critical before public beta

1. Current V0.3 review metadata does not enforce release eligibility.
2. Current content constants have no reviewer/source/rights revision contract.
3. Progress is SharedPreferences-only and not transactional.
4. Game state is widget-local and cannot resume reliably.
5. Random rounds are not seeded/reproducible.
6. No in-app reset/delete progress path.

### Important quality debt

- Repeated game lifecycle and feedback code
- No placement/onboarding
- No mastery/spaced review
- No native Mizo audio
- No large-text/screen-reader integration test
- No app/content version support bundle
- Platform permission manifests not yet audited

## Product-owner decisions

The product owner approved these defaults on 13 September 2026:

1. **Priority V1:** Ages 8–13 + diaspora beginners
2. **Audience:** Mixed audience with child-safe defaults
3. **Account:** Guest-first; cloud sync later
4. **Revenue through V1:** Ads-free; core learning free
5. **Technology:** Flutter offline-first; Rails Editorial Studio in Phase 4
6. **Social:** No public chat/profile/leaderboard in V1

Authoritative record: `PRODUCT_DECISION_RECORD.md`. Any future change requires a
new dated revision and impact note.

## Fastest route to close Phase 0

1. Run Mac check and share only the final error/log if it fails.
2. Appoint at least two Mizo reviewers, including one teaching children.
3. Review the first 20 candidate words and five sentences as a calibration set.
4. Update editorial rules from reviewer disagreements.
5. Review remaining pilot pack and record approvals.
6. Record first 30 word clips with consent and run audio QA.
7. Test critical UX with the minimum participant set.
8. Complete engineering/learning sign-off for ADR and Game Engine V2, then mark
   Phase 0 Passed.

## Phase 1 entry condition

Phase 1 implementation may begin with architecture scaffolding and onboarding
prototype after product defaults/ADR approval. Release-content integration and
learning claims must wait for human language/learning approvals.
