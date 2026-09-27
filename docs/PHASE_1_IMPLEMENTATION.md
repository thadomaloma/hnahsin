# Phase 1 — Professional Core Implementation Report

**Build:** 0.6.0+11  
**Date:** 13 September 2026  
**Status:** **TECHNICAL GATE PASSED — human QA and content gates open**

> Updated by `PHASE_1B_IMPLEMENTATION.md` for gameplay reliability and
> `PHASE_1C_IMPLEMENTATION.md` for Mac verification and stabilization.

## Outcome

The prototype now has a production-shaped local core without weakening the
Phase 0 human-language gate. A new learner can create a guest profile, receive a
starting path, play through the existing games using one deterministic engine
contract, and persist progress transactionally on supported native platforms.
Production builds fail closed while the Mizo corpus remains unapproved.

## Delivered in this slice

| Phase 1 deliverable | Evidence | Status |
|---|---|---|
| Feature architecture | `lib/features/*`, `lib/data/*` | Core domain/data split implemented |
| Local database/repository | SQLite + preferences fallback + migration | Implemented; Mac build passed |
| Guest onboarding | Five screens: age band, level, goals, preferences | Implemented |
| Age-responsive settings | Broad band, child-safe defaults, local-only profile | Implemented baseline |
| Game Engine V2 | Seed, lifecycle, scoring, snapshot, reward ID | Implemented baseline |
| Six-game engine port | Explicit stable ID for every game | Implemented through compatibility façade |
| Tutorial and modes | Tutorial launcher; Relaxed, Standard and Timed | Implemented |
| Resume | Full presentation-state snapshots for all six games | Implemented |
| Accessibility | English navigation, semantic HUD/answers/feedback, large-text-safe scrolling | Code pass implemented; device audit pending |
| Local-safe analytics | Aggregate event contract; no learner free text/audio/name | Implemented model only; no external SDK |
| Content integrity | Versioned manifest + SHA-256 validator | Implemented |
| Release eligibility | Compile-time production gate accepts approved content only | Implemented; currently blocks release as intended |
| Tests/CI | Engine/profile/reward/widget tests + Android/macOS/iOS jobs | Mac analyze/test/build passed |
| Local data deletion | Confirmed Reset Local Progress action | Implemented |

## Safety and language boundary

- `THUMAL_QUEST_PRODUCTION=true` activates a fail-closed release gate.
- No current seed item is silently promoted to `approved`.
- Google Cloud or machine translation is not treated as canonical Mizo.
- A qualified two-reviewer decision remains necessary before publication.
- No ads, public chat, public profile or child leaderboard were introduced.

## Verification completed here

- Phase 0 artifact validator: pass
- Phase 1 structure, ports, release gate and SHA-256 validator: pass
- Bash syntax checks for Mac launcher and diagnostics: pass
- Phase 1C Mac bootstrap/native-smoke validator: pass
- Source delimiter sanity scan: pass

The product owner confirmed the authoritative Mac package resolution, analyzer,
test and macOS build gate passed. Android/iOS CI smoke evidence and manual human
QA remain open.

## Run the authoritative Mac check

From the extracted project directory:

```bash
chmod +x run_mac.command
./run_mac.command check
```

If it passes, start the desktop build:

```bash
./run_mac.command
```

The first run may generate Flutter host folders. To test public-release content
behavior deliberately:

```bash
flutter run -d macos --dart-define=THUMAL_QUEST_PRODUCTION=true
```

It should show the content-review gate until the manifest/corpus receives human
approval.

## Remaining Phase 1 exit work

1. Run VoiceOver/TalkBack and 200% text-scale critical-flow tests.
2. Complete a 30-minute exploratory play test with force-close/restart cases.
3. Validate Timed Mode length and hint usefulness with priority learners.
4. Secure the scheduled/approved internally reviewed word target; never bypass
   the two-reviewer content gate.

Phase 1 should be marked complete only after those evidence-backed gates pass.
