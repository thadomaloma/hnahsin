# Phase 0 — Foundation & Validation Sprint

**Sprint window:** 2–3 weeks  
**Started:** 13 September 2026  
**Owner:** Thumal Quest product team  
**Status:** Active

## Sprint outcome

Phase 0 zawhah team member, Mizo reviewer leh developer-te hian thil tum,
content siam dân, learner flow, technical boundary leh release gate inzawm taka
an hriat theih tûr a ni. Prototype-a feature tam zâwk belh hi sprint goal a ni
lo; professional product sakna lungphûm nghet siam hi goal a ni.

## Workstreams

| ID | Workstream | Output | Owner needed | Status |
|---|---|---|---|---|
| P0-01 | Product | `PRODUCT_REQUIREMENTS.md` + `PRODUCT_DECISION_RECORD.md` | Product owner | **Approved** |
| P0-02 | Learners | `LEARNER_PERSONAS.md` | Product + teacher | Draft complete |
| P0-03 | Language | `CONTENT_EDITORIAL_GUIDE.md` | Mizo language lead | Awaiting human approval |
| P0-04 | Content data | `CONTENT_SCHEMA_V2.md` + JSON Schema | Language + engineering | Draft complete |
| P0-05 | Learning | Game-to-skill map in PRD/spec | Teacher | Awaiting validation |
| P0-06 | UX | `UX_PRODUCT_FLOW.md` | Designer + learner testers | Draft complete |
| P0-07 | Architecture | `ARCHITECTURE_ADR.md` | Engineering | Draft complete |
| P0-08 | Game platform | `GAME_ENGINE_V2_SPEC.md` | Engineering + teacher | Draft complete |
| P0-09 | Trust | `PRIVACY_DATA_INVENTORY.md` | Product + legal reviewer | Draft complete |
| P0-10 | Delivery | Mac launcher + CI + validation script | Engineering | Implemented; Mac execution pending |
| P0-11 | Pilot content | Candidate pack + review tracker | Language Council | Human review pending |
| P0-12 | Gate | `PHASE_0_GATE_REPORT.md` | Product owner | Generated at handoff |

“Draft complete” tih chu implementation input atan a kim tihna a ni; Language
Council, teacher emaw legal reviewer approval ang mihring sign-off a substitute
lo.

## Week plan

### Week 1 — Define and de-risk

- Day 1: Current app audit, scope boundary and product promise
- Day 2: Learner segments, priority launch cohort and onboarding decision
- Day 3: Learning pillars, mastery definition and game-to-skill mapping
- Day 4: Content schema, review states, provenance and correction workflow
- Day 5: Architecture ADR, Mac preflight and CI baseline

### Week 2 — Validate the foundation

- Day 6: Mizo Language & Learning Council kickoff
- Day 7: First 100 candidate terms triage; first 30 audio recording script
- Day 8: UX flow review with child, diaspora and adult representatives
- Day 9: Game Engine V2 rules/test cases review
- Day 10: Mac/iOS/Android smoke build and Phase 0 gate review

### Optional Week 3 — Close human-validation gaps

- Reviewer corrections and second approval
- Audio re-recording/normalization
- Learner usability retest
- Privacy/legal consultation
- Exit-gate evidence and Phase 1 backlog lock

## Required decisions

| Decision | Recommended default | Deadline |
|---|---|---|
| Priority V1 cohort | Ages 8–13 + diaspora beginner | **Approved 13 Sep 2026** |
| Store audience path | Mixed audience, child-safe defaults | **Approved 13 Sep 2026** |
| Account model | Guest-first; optional sync later | **Approved 13 Sep 2026** |
| Canonical Mizo authority | Named Language Council, two approvals | Before content sign-off |
| Monetization through V1 | Ads-free; core learning free | **Approved 13 Sep 2026** |
| Backend timing | Flutter local-first now; Rails in Phase 4 | **Approved 13 Sep 2026** |
| Social boundary | No public chat/profile/global child leaderboard | **Approved 13 Sep 2026** |

## Definition of done

Phase 0 chu heng evidence zawng zawng a awm hnuah chauh **Passed** tih tûr:

- Fresh Mac-ah setup script run theih leh test/build result record
- PRD leh priority learner product owner-in approve
- Council member/role named, reviewer pahnihin pilot pack approve
- 100 words, 40 sentences leh 30 audio clip metadata complete
- Critical UX flow learner segment pathum hmangin test
- Architecture leh Game Engine V2 decision sign-off
- Child-data inventory SDK/permission tin huam
- Phase 1 backlog estimate leh acceptance criteria lock

## Scope control

Phase 0 chhûngah hengte kan build lo ang:

- Public account system or cloud sync
- Rails production backend
- Open chat, public leaderboard or UGC
- Automated Mizo pronunciation score
- Subscription/payment flow
- New story world implementation

Hengte chu specification/prototype level-ah thlîr theih a ni; production feature
angin build tûr erawh Phase 1–4 gate zawm tûr.
