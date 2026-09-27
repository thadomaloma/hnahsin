# Phase 0 Validation Playbook

**Purpose:** Mizo review, audio recording, learner testing leh decision sign-off
chu repeatable leh evidence nei taka kalpui nân.

## 1. Language Council kickoff — 45 minutes

### Participants

- Product owner
- Language reviewer pahnih tal
- Naupang zirtîrtu pakhat tal
- Cultural/audio reviewer where available

### Agenda

1. Product promise and priority learners — 5 min
2. Editorial authority and disagreement rule — 10 min
3. First 20 words + five sentences calibration — 15 min
4. Audio spelling/pronunciation convention — 5 min
5. Remaining review assignment and deadline — 5 min
6. Sign-off record — 5 min

### Decisions to record

- Council member name/role (internal record; app credit permission separate)
- Final dispute resolver or vote rule
- Canonical orthography reference
- Variant acceptance rule
- Reviewer qualification and conflict-of-interest rule
- Cultural item source threshold

## 2. Content calibration

Start with candidate rows 1–20 and sentences 1–5. Reviewer tin mahniin hmasa
review se; chumi hnuah disagreement sawi ho tûr. Group pressure pumpelh nân
independent pass hmasa hi a pawimawh.

### Per-word questions

- Display spelling/diacritic correct em?
- Sense pakhat chiang em?
- Part of speech and level correct em?
- Naupang/diaspora learner tân common/useful em?
- Accepted variant/search alias awm em?
- Example sentence natural em?
- Audio form eng nge record tûr?

### Per-sentence questions

- Native speaker-in nî tin a sawi ang em?
- Target word sense dik a hman em?
- Beginner-in context a man thei em?
- English support hian sense a tidanglam em?
- Age/culture/safety concern awm em?

### Outcome

- `approved`: Language + learning stages both pass
- `changes_requested`: Exact correction/note required
- `rejected`: Reason and replacement suggestion

All current CSV rows are drafts. Spreadsheet update alone should not mark app
release content; V2 item review records and publisher validation are required.

## 3. Audio recording session

### Before recording

- Approved text revision lock
- Speaker/guardian consent signed
- Speaker ID/pseudonym assigned
- Quiet room; phone airplane mode if practical
- Microphone 15–25 cm, stable position
- Short test clip listened on headphones

### Takes

Each first-30 word:

1. Natural normal-speed take ×2
2. Clear slow-learning take ×1 (not unnaturally broken syllables)
3. Linked sentence take after sentence approval, where scheduled

Do not speak filename, personal name or instruction inside clip.

### File naming

`<audio_id>__<take>__<speaker_id>.wav`

Example: `audio.word.001__normal-a__speaker.01.wav`

### Technical QA

- No clipping, strong hiss, room interruption or cut word ending
- Consistent perceived loudness
- Correct asset ID and text revision
- Master file preserved; mobile delivery copy exported separately

### Language/audio QA

Audio reviewer listens first; language reviewer compares with approved text.
Both decisions are recorded. Failed clip is retaken, not digitally “fixed” into
different pronunciation.

## 4. Learner usability session — 20–30 minutes

### Minimum discovery sample

- 3 early learners + guardians
- 5 ages 8–13, including two diaspora learners
- 3 teen/adult heritage learners
- 3 parent/teacher reviewers

### Safety

- Guardian consent for child participation
- Explain session, stopping freedom and recording choice
- Do not require real name, exact birthday or contact in app
- Prefer notes/counters over child video/voice recording
- Never publish participant quote/image without separate permission

### Facilitator script

“He app hi i test a ni lo; app-in eng nge a tihṭhat ngai tih kan zir zâwk a ni.
I duh hunah i chawl thei. Ka pui lo hmasa ang a, i ngaihtuahna min hrilh thei.”

### Tasks

1. App hawng la first learning activity zawng
2. Goal/level thlang
3. Answer pakhat dik leh pakhat dik lo experience
4. Audio play/replay
5. Hint or explanation zawng
6. Session save/exit and resume
7. Learned/mastered progress zawng

### Observe

- Task completion yes/no
- First hesitation point
- Mis-tap or unreadable copy
- Help requested
- Feedback hnuah learner-in eng nge a zir tih a sawi theih
- Visual/sound nuamzia and overwhelm
- Adult vs child presentation fit

### Pass threshold

- ≥80% first lesson unassisted find
- ≥90% feedback hnuah next action find
- 100% safe exit; no accidental adult/data action
- Zero critical accessibility/safety blocker

## 5. Mac validation

From project root:

```bash
chmod +x run_mac.command
./run_mac.command check
```

Record:

- Mac model/architecture and macOS major
- Flutter/Dart version
- Xcode version
- Artifact validation result
- Analyze/test result
- macOS debug build result
- Final error and log path if failed

After check passes:

```bash
./run_mac.command
```

Test first launch, each eight-game entry, result sheet, app restart and saved
progress. For Listen & Pick, verify normal audio, slow replay, transcript,
Sound-off behaviour, provenance and airplane-mode playback.

## 6. Product decision sign-off — completed

PDR-001 was approved by the product owner on 13 September 2026. The template
below is retained for future revisions only.

Copy and complete:

```text
Thumal Quest Phase 0 product decisions
Date:
Owner:

[ ] Priority V1: Ages 8–13 + diaspora beginners
[ ] Mixed audience with child-safe defaults
[ ] Guest-first; optional sync later
[ ] Ads-free through V1; core learning free
[ ] Flutter offline-first; Rails Editorial Studio in Phase 4
[ ] No public chat/profile/global child leaderboard in V1

Changes/notes:
Approved by:
```

## 7. Gate meeting — 30 minutes

Review in order:

1. Product decisions
2. Mac/CI evidence
3. Content counts and reviewer approvals
4. Audio consent/QA
5. Learner-test blockers
6. Privacy/permission gaps
7. Phase 1 backlog and owners

Gate outcome must be one of:

- **Passed:** All exit evidence complete
- **Conditional:** Only named, time-bounded non-safety item remains
- **Not passed:** Content, safety, build or scope blocker remains

Never mark content/safety/build blocker as “conditional” merely to meet a date.
