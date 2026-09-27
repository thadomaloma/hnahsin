# Phase 2B — Audio Learning & New Games

**Build:** 0.7.0+13  
**Date:** 13 September 2026  
**Status:** **IMPLEMENTED — AUDIO RECORDING AND DEVICE VERIFICATION PENDING**

## Outcome

Thumal Quest now has a native audio playback boundary, slow replay, transcript
support, two new resumable games and a local content-report queue. Listening
answers and Sentence Builder answers feed the same mastery and spaced-repetition
state introduced in Phase 2A.

No generated voice is presented as authentic Mizo. The ten-row in-app pack is
intentionally marked `planned` until native-speaker recording, consent,
language review and audio review are all complete.

## Delivered

| Capability | Implementation |
|---|---|
| Audio domain | Typed clip metadata, pack manifest, playback speed and fail-closed publication gate |
| Native player | `just_audio` adapter supporting Android, iOS and macOS asset playback |
| Slow replay | Dedicated slow asset with normal-asset fallback at 0.72× playback speed |
| Transcript | Optional hint; hint-assisted answers use the existing reduced-score path |
| Listen & Pick | Five-round audio/meaning game with emoji and English support choices |
| Sentence Builder | Duplicate-safe word tiles, deterministic shuffle and natural-order evaluation |
| Reliability | Autosave, resume, Relaxed/Standard/Timed modes, hearts, score and XP |
| Learning loop | Correct/incorrect game attempts update item mastery and review scheduling |
| Content reports | Reason plus stable content ID stored locally and deduplicated |
| Accessibility | Semantic audio control, transcript path, live feedback and large tap targets |

## Audio release gate

A clip is playable only when all of these exist:

- Normal and slow native-speaker recordings
- Stable speaker ID and dialect/variant metadata
- Recording date and written consent record
- Commercial-use licence
- Mizo language approval
- Technical audio approval
- Published state

Missing audio never triggers cloud text-to-speech and never silently substitutes
another language. Development builds show the transcript hint and the exact
pending status. Production content remains protected by the existing reviewed
content gate.

## Content currently included

- Ten planned TQ0/TQ1 word-audio records mapped to the Phase 0 recording sheet
- Six short prototype Sentence Builder exercises
- Every sentence remains subject to the two-reviewer Mizo editorial gate

## Verification authored

- Audio publication-gate and slow-asset tests
- Sentence tile identity, shuffle and answer-order tests
- Audio status and Sentence Builder widget tests
- Learning-state report persistence/deduplication test
- Phase 2B structural validator and CI/Mac gate integration

## Mac verification

Run:

```bash
./run_mac.command check
```

Then manually verify both new games in Relaxed, Standard and Timed modes; force
close/resume; Sound off; transcript; large text; VoiceOver; and a reviewed test
audio pack on a physical device. Flutter execution is unavailable in the
preparation environment, so analyzer, tests and native builds are not claimed
here.

## Exit-gate status

| Gate | Status |
|---|---|
| New-game implementation and automated contracts | Ready for Mac verification |
| Offline review queue | Implemented in Phase 2A |
| Offline native audio playback | Implemented; reviewed recording files pending |
| Consent/provenance for every published clip | Enforced; no clip published yet |
| 10+ learners per priority segment | Pending field test |

Phase 2B code is complete for device verification. Audio production and learner
testing remain release blockers, not code shortcuts.
