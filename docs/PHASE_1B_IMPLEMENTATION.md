# Phase 1B — Reliability & Game Completion

**Build:** 0.5.0+6  
**Date:** 13 September 2026  
**Status:** **IMPLEMENTED — Flutter/native and human QA gates pending**

## Outcome

All six games now use one reliability runtime for presentation-state restore,
background pause/autosave, hint-assisted scoring and a real countdown mode. A
learner can leave a game, close the app, return through the Games screen and
choose either **Resume Game** or **Start New Game**.

## Delivered

| Capability | Implementation |
|---|---|
| Shared lifecycle | `GameRuntime` observes resumed/inactive/hidden/paused/detached states |
| Autosave | Active/paused snapshot after answers, hints, item advances and every five timed seconds |
| Full resume | Index/selection, chain, found words, grid selection and crossword cells serialized by adapter |
| Saved-game UX | Launcher detects a saved session and offers Resume or Start New |
| Timed Mode | 90-second countdown, accessible HUD announcement and safe terminal result |
| Relaxed Mode | Mistakes never remove hearts |
| Standard Mode | Three-heart challenge retained |
| Hint contract | One active hint per item; correct hint-assisted answer earns 60 and breaks combo |
| Result safety | Zero-attempt timeout awards zero XP; reward transaction remains idempotent |
| Accessibility | Non-colour answer states, live hint/feedback semantics, labelled word-search cells |
| Tests | Engine timer/zero-XP/hints, runtime expiry, lifecycle snapshot and restoration |
| CI | Phase 1B structural validator added to Mac launcher and Flutter workflow |

## Adapter payloads

| Game | Resumed presentation state |
|---|---|
| Picture Match | Seeded question/options order, current question, selected answer |
| Spelling | Seeded question order, current question, selected letter |
| Tawng Upa | Seeded question order, current question, selected meaning |
| Word Chain | Accepted chain, current feedback and error state |
| Word Search | Found words, active cell path and coaching message |
| Crossword | Every entered cell and last validation state |

Every snapshot also carries engine status, score, combo, hearts, attempts,
random seed, reward transaction ID, remaining time and current hint state.

## Reliability behavior

1. Starting a game creates a deterministic session.
2. A gameplay mutation queues a local snapshot.
3. Backgrounding pauses engine time and saves immediately.
4. Returning resumes the same session and timer.
5. Finishing commits the reward once, then clears the snapshot.
6. Starting new clears the old snapshot before creating another session.

## Verification completed in this environment

- Phase 0 artifact validator: pass
- Phase 1 architecture/content validator: pass
- Phase 1B six-adapter reliability validator: pass
- Mac launcher Bash syntax: pass
- Dart source delimiter scan: pass

Flutter is not installed in the preparation environment. `flutter pub get`,
`flutter analyze`, `flutter test`, macOS build and Android build therefore remain
unverified here and must not be reported as passing.

## Required Mac gate

```bash
chmod +x run_mac.command
./run_mac.command check
```

Then run the app and verify one game in each mode:

```bash
./run_mac.command
```

For resume QA, answer at least one item, close the game/app, reopen **Games**, and
confirm **Resume Game** restores the exact visible state and score.

## Remaining evidence before Phase 1 is closed

- Resolve any real Flutter analyzer/test/native build findings.
- Run VoiceOver and 200% text-scale tests on critical flows.
- Complete a 30-minute exploratory session including six force-close cases.
- Validate timer length and hint usefulness with priority learners.
- Obtain the two-reviewer Mizo content approval; current draft content is still
  blocked from production release.
