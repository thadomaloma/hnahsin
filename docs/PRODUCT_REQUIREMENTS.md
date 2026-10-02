# Hnahsin — Product Requirements Document

**Version:** 0.2 / Phase 0 product-approved  
**Date:** 13 September 2026  
**Product:** Hnahsin  
**Platforms:** Android and iOS first; macOS/web for development and selected use

## 1. Product summary

Hnahsin chu Mizo tawng zirna atâna premium mobile game a ni. A core value
chu Mizo thumal, ngaihthlakna, chhiarna, spelling, sentence leh culture chu
session tawi leh nuam hmanga zir chhohtîr a ni. Mizoram chhûnga naupang chauh ni
lovin India ram dang leh foreign-a Mizo family, heritage learner, adult
refresher leh Mizo tawng zir duh mi tân pawh a ni.

## 2. Problem statement

Priority learner-ten heng harsatna hi an tawng:

- Mizo zirna digital content chu a tlem, a inang lo emaw review/provenance a
  chiang lo.
- Diaspora naupangin Mizo an hria deuh mahse chhiar/ziak leh sentence siam an
  harsat.
- Existing word puzzle chuan khelh a nuam thei, mahse spaced recall leh skill
  progression a nei loh chuan thiamna a teh theih lo.
- Kum 5 mi leh puitling chu UI/content pakhat angin serve theih a ni lo.
- Internet chak lohna leh low-end device-in learning continuity a tibuai.
- Child data, ads, chat leh translation error chuan community trust a nghawng.

## 3. Product objective

### Primary objective

Learner-in kar tin human-reviewed Mizo item tam zâwk a master a, nî tin nunah a
hmang thei tûra game-first learning habit siam.

### Secondary objectives

- Mizo thumal leh cultural content versioned digital corpus siam
- Parent/teacher/community tân rintlak leh safe product siam
- Native-speaker audio archive rights-clear siam
- Future classroom and family learning ecosystem foundation siam

### Non-goals for V1

- Formal language certification
- Mizo dictionary authority nih claim
- Unmoderated social network
- Real-time multiplayer
- AI translation/pronunciation chu correct tih automatic guarantee
- Naupang screen time sei thei ang bera siam

## 4. Priority audience

### Recommended beachhead

**Primary:** Ages 8–13, beginner to growing-reader Mizo learners; Mizoram and
diaspora.  
**Secondary:** Diaspora teens/adults and adult refreshers.  
**Supported foundation:** Ages 5–7 with a narrower picture/audio path.

Product chu all ages tân a inhawng ang; V1 quality focus chu audience tlem zâwk
ah dahin generic experience laka kan invêng ang.

## 5. Jobs to be done

- “Ka fa hian Mizo thumal nî tin tlem tlem zir se, ka enpui reng ngai lo se.”
- “Foreign-a ka seilian a, Mizo ka hria deuh mahse chhiar leh sawi ngam ka duh.”
- “Mizo thumal ka hre tawh; tawng upa leh natural sentence ka zir belh duh.”
- “Game ka khelh duh a, khelh pahin thumal thar ka zir duh.”
- “Zirtîrtu angin content dik leh learner progress hriat ka duh.”

## 6. Experience principles

1. First useful play within 60 seconds
2. Session length learner-in thlang
3. Mizo content primary; English is support
4. Wrong answer is teaching moment, not punishment
5. Progress survives offline and app restart
6. Mastery is recall over time, not one correct tap
7. Child path has no manipulative commercial pressure
8. Every published language item has provenance and approval

## 7. Functional requirements

### FR-01 Onboarding and placement

- Learner selects broad age band: 5–7, 8–13, 14–17, 18+
- Selects current level: New, Understand some, Can speak, Can read/write
- Selects goal: Home conversation, Reading, Vocabulary, Culture, Refresh
- Selects support language: English initially; Mizo-only later
- App recommends TQ path; placement check can adjust it
- Exact birthdate, real name and email are not required for guest use

**Acceptance:** Learner can reach first playable lesson in no more than five
decisions and 60 seconds.

### FR-02 Learning path

- Path contains lesson nodes with explicit skills and prerequisites
- Lesson mixes introduction, guided practice, game and later review
- New item count is age/level appropriate
- Learner can replay completed lesson
- Core path works offline

**Acceptance:** One word can be traced from first exposure through mastery state.

### FR-03 Game platform

- One shared session lifecycle: ready, active, paused, completed, failed, quit
- Deterministic seeded rounds for testing and support
- Relaxed mode available; timer cannot block core learning
- Hint, feedback, explanation and result model consistent
- App background/close can restore unfinished session where suitable
- Content eligibility filters out unapproved items from release builds

**Acceptance:** All core games use the same result and progress contract.

### FR-04 Review and mastery

- Items have New, Learning, Strong and Mastered states
- Scheduler produces due reviews offline
- Correct/incorrect, hint use and response confidence influence next due date
- Mastery requires correct recall on separated dates/context
- Learner can see due review without opaque punishment

**Acceptance:** Scheduler unit tests cover first exposure, lapse, mastery and
clock/timezone boundary.

### FR-05 Audio

- Published clip has speaker consent/license and language metadata
- Play, slow replay, transcript and replay count supported
- Download packs work offline
- Audio unavailable state has text fallback
- Speaking record is opt-in and permission is contextual

**Acceptance:** No lesson becomes unusable because audio download fails.

### FR-06 Progress and profiles

- Guest profile and local progress by default
- Daily goal 3/5/10 minutes or item count
- XP, skill mastery, collection and personal best shown
- Optional account/sync introduced only after privacy gate
- Child profile uses nickname/avatar without public discoverability

### FR-07 Content quality

- Release builds load only `approved` and active content version
- Every item records source, reviewers, revision and age suitability
- User can report spelling/meaning/audio issue
- Editor can correct, publish and roll back content pack

### FR-08 Guardian and safety

- External link, account creation, purchase and data management are gated for
  child path
- No open chat, precise location, contacts or public free-form profile
- Privacy summary is readable in English and Mizo
- Data delete/export path exists before cloud account launch

### FR-09 Offline and sync

- First bundled pack is usable without account/network
- Local database is source of truth for active session and progress
- Remote content update is atomic and checksum/version verified
- Interrupted sync cannot damage current playable pack
- Conflict policy is documented before multi-device launch

### FR-10 Accessibility

- 200% text scale critical flows
- Screen-reader semantics for navigation, answers and progress
- Correct/wrong not colour-only
- Audio transcript and reduced motion
- Minimum touch targets appropriate to selected learner path

## 8. Game-to-skill matrix

| Game | Vocabulary | Spelling | Reading | Listening | Sentence | Culture |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| Picture Match | Primary | — | Support | Future | — | Support |
| Spelling | Support | Primary | Support | Future | — | — |
| Word Search | Support | Primary | Support | — | — | — |
| Word Chain | Primary | Support | Support | — | — | — |
| Tawng Upa | Primary | — | Primary | Future | Support | Primary |
| Crossword | Primary | Primary | Primary | — | Support | Support |
| Listen & Pick | Support | — | Support | Primary | — | — |
| Sentence Builder | Support | Support | Primary | Support | Primary | Support |
| Story Quest | Support | — | Primary | Primary | Primary | Primary |

## 9. Content and language requirements

- Standard Mizo is launch baseline; variant is preserved with context
- Machine output is always draft/unreviewed
- Two qualified approvals required for public content
- Cultural/older term requires cultural reviewer where flagged
- Copyright/license recorded for text, illustration and audio
- Search normalization must not replace display spelling
- Mizo Unicode characters remain text, not image

## 10. Engagement requirements

- Daily/weekly quest advances learning objective
- Streak includes grace and easy recovery
- Reward is content/cosmetic, not random paid chance
- Natural stopping point after every short session
- Comeback message is supportive, not shame-based
- No global child leaderboard in V1

## 11. Non-functional requirements

| ID | Requirement | V1 target |
|---|---|---|
| NFR-01 | Stability | ≥99.5% crash-free sessions |
| NFR-02 | Startup | Warm start p95 ≤2s on supported mid-range device |
| NFR-03 | Offline | 100% core games and bundled path usable offline |
| NFR-04 | Content integrity | Atomic pack update + checksum + rollback |
| NFR-05 | Accessibility | Critical flows pass manual checklist |
| NFR-06 | Security | No known critical/high release defect |
| NFR-07 | Privacy | Minimum data; no child ad identifier |
| NFR-08 | Testability | Critical domain rules ≥80% automated coverage |

## 12. Metrics

**North Star:** Weekly Mastered Mizo Items (WMMI).

- Activation: onboarding + first round completion
- Learning: due reviews completed and four-week gain
- Retention: D1/D7/D30 by broad learner segment
- Quality: crash-free sessions, content error rate, audio failures
- Trust: correction response time, privacy/support requests
- Healthy use: sessions per week; not maximum child minutes

Analytics events must not contain free-form child input or unnecessary personal
data.

## 13. Release criteria

- Required content is fully approved, traceable and reversible
- Priority segment usability test passes
- Offline, restart and interrupted-update tests pass
- Store target audience/data declarations match real behavior
- Privacy, accessibility, performance and dependency reviews pass
- Support and correction owner is active

## 14. Approved product decisions

On 13 September 2026, the product owner approved PDR-001:

1. V1 prioritizes ages 8–13 and diaspora beginners.
2. The app follows a mixed-audience path with child-safe defaults.
3. Guest-first is required; optional cloud sync comes later.
4. V1 is ads-free and core learning remains free.
5. Flutter is offline-first; Rails Editorial Studio begins in Phase 4.
6. V1 has no public chat/profile/global child leaderboard.

See `PRODUCT_DECISION_RECORD.md` for the authoritative scope and change control.

### Still open

- Name Language Council members and decision chair
- Select first pilot communities and testing consent process
- Approve Family Supporter details only after learning/retention validation
