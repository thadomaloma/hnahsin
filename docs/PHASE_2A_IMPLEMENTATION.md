# Phase 2A — Learning Engine Foundation

**Build:** 0.6.1+12  
**Date:** 13 September 2026  
**Status:** **IMPLEMENTED — DEVICE VERIFICATION PENDING**

## Outcome

Thumal Quest now turns word practice into a persistent learning loop. A learner
can take a ten-question placement check, enter one of five TQ levels, complete a
daily offline lesson, and have every answer scheduled for later recall. The
Learn screen reports due, new and mastered items rather than rewarding raw
screen time.

## Delivered

| Capability | Implementation |
|---|---|
| TQ0–TQ4 framework | Five named levels with age-neutral English UI and Mizo learning descriptions |
| Placement Check | Ten deterministic meaning questions, optional TQ0 start and saved result |
| Mastery model | New, Learning, Familiar, Strong and Mastered states per content ID |
| Spaced repetition | Again/Hard/Good/Easy ratings, lapse count, ease factor and UTC due date |
| Daily planner | Due reviews first, then level-eligible unseen words; fully offline |
| Adaptive difficulty | Moves at most one TQ level after a bounded recent-answer window |
| Daily Lesson | Mizo word/meaning/example practice with immediate corrective feedback |
| Skill dashboard | Current TQ level plus Due, New and Mastered counts |
| Persistence | SQLite schema v2 migration, preferences fallback and in-memory test repository |
| Safety boundary | Existing reviewed-content gate remains authoritative; no cloud data or child identity added |

## Learning loop

1. Placement estimates a starting TQ level.
2. Daily planner selects overdue items before new level-eligible words.
3. The learner answers with immediate Mizo-context feedback.
4. The scheduler records accuracy, repetition, interval and next due time.
5. Recent performance may move difficulty one level up or down.
6. Tomorrow's offline queue is derived from the persisted state.

## Scheduling defaults

- **Again:** repeat after ten minutes, reset repetition count, record a lapse
- **Hard:** minimum one-day interval and a small ease reduction
- **Good:** one day, then three days, then ease-based growth
- **Easy:** three days, then seven days, then accelerated growth
- Mastered status begins after four successful scheduled repetitions
- Adaptive changes require at least five recent outcomes and use at most eight

These are safe product defaults for the pilot, not a claim of a clinically or
academically validated memory model. Learner testing will tune thresholds.

## Persistence migration

SQLite database version moves from 1 to 2 and adds one `learning_state` JSON
record for the local guest. Existing profile, XP, reward ledger and resumable
game sessions are preserved. Reset Local Progress clears learning state too.

Build 0.6.1+12 also corrects the SharedPreferences reward-ledger call so that
`setStringList` receives only its key and list value. The learning-state key is
kept in the reset allow-list, where it belongs.

## Verification authored

- Placement boundary tests across all five TQ levels
- Scheduler advance/lapse/due-date tests
- Adaptive difficulty evidence-window tests
- Due-first daily-plan test
- Learning-state JSON round-trip test
- Controller persistence and reset tests
- Placement navigation widget test
- Phase 2A structural validator and CI gate

## Remaining Phase 2A device gate

Run on the verified Mac:

```bash
./run_mac.command check
```

Then manually confirm placement, app restart, Daily Lesson, tomorrow-due state,
large text and VoiceOver. Flutter execution is unavailable in the preparation
environment, so analyzer/tests/native builds are not claimed here.

## Deferred to Phase 2B

- Native-speaker audio and downloadable audio packs
- Listen & Pick
- Sentence Builder
- Slow replay, transcript and audio provenance UI
- Game-wide item-attempt telemetry adapters
