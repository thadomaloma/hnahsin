# Hnahsin

**Khelh la, zir la, thiam rawh.**

Hnahsin is a premium, game-first Mizo language-learning Flutter app for
learners from age 5 through adults. Version 0.12 adds production staging,
real-audio pilot evidence and live sync validation while preserving the
game-first offline experience and local learner progress.

> **2026-09-27 — audio removed.** Pronunciation audio, Listen & Pick and the
> backend audio pipeline (upload, review, audio packs, S3 media storage) were
> removed from the app and Editorial Studio. Hnahsin is now text- and
> picture-based; the **Thumal Kawp** memory game replaced Listen & Pick. The
> audio-related release notes below are kept as project history.

## Version 0.12 Phase 4C highlights

- Railway `/ready` gate checks PostgreSQL and private media storage
- Production S3 configuration fails closed; container runs unprivileged
- Live HTTPS smoke verifies ETag, manifest checksums and every audio byte
- Audio releases are cryptographically bound to the exact reviewed content revisions
- Five-clip real Mizo audio pilot with four distinct workflow operators
- Clean install, offline replay, corrupt candidate, preservation and rollback drills
- 5 MiB pack, 100-clip and 250 MiB client safety budgets
- One-command report/smoke/strict staging workflow and CI evidence artifact

## Version 0.11 Phase 4B highlights

- Signed direct audio upload with MIME, size and SHA-256 verification
- Independent language/audio decisions, secure preview and no self-review
- Immutable audio packs, public delivery API, ETag caching and rollback
- Atomic Flutter activation with last-verified-pack recovery
- Reviewed remote words and audio feed the live learning/game catalog
- Private S3-compatible production storage; disk-backed local development
- Delivery status UI, tests, CI contracts and Mac/backend release gates

## Version 0.10 Phase 4A highlights

- Rails 8.1 + PostgreSQL Editorial Studio in `backend/`
- Editor, Language Reviewer, Culture Reviewer, Publisher and Admin roles
- Immutable revisions, independent maker-checker review and append-only audit
- Fail-closed publishing: unreviewed content cannot enter a public pack
- Full-snapshot content packs with canonical SHA-256 checksums and safe rollback
- Public read-only V1 API with ETag and offline-safe cache semantics
- Responsive premium editorial UI with natural-English labels
- Separate Rails security/style/test CI and Mac backend launcher

## Version 0.9.1 Phase 3C highlights

- Default-on **Gentle engagement** mode with optional/no-penalty quest copy
- Backward-compatible learner preference stored entirely on device
- Exact 19-decision story, culture-card and seasonal reviewer queue
- Safe review-to-manifest promotion without machine or self-approval
- Eight-control privacy, consent, support and accessibility pilot-readiness gate
- Structured Mac evidence written only after validators, analysis, tests and build
- One aggregate Phase 3 strict gate with honest pending blockers
- Community pilot incident, withdrawal and evidence-integrity runbook

## Version 0.9 Phase 3B highlights

- Six Mizo-first **Culture Cards** with context and example sentences
- TQ0–TQ2 Culture Trail progression and local content-error reporting
- Culture-card, story-reward and milestone collections
- Age-responsive avatar names and selectable visual identity
- Claimable daily and weekly goals with idempotent **Trail Marks**
- Recognition-only rewards that never block a lesson or learning feature
- Chapchar Kut seasonal archive with no countdown or expiry pressure
- Fail-closed language/culture review manifest for all Culture Trail content
- Privacy-minimal four-week cohort evidence gate across three learner segments

## Version 0.8 Phase 3A highlights

- Three-region **Mizo Journey** map with prerequisite and TQ-level progression
- Three Mizo-first **Story Quests** with natural conversation choices
- Optional English support based on the learner profile
- Culture-note collection and age-responsive story rewards
- Daily Story, Word Review and Culture tasks stored fully offline
- Weekly learning rhythm without countdown pressure or fear of missing out
- One missed-day grace and a gentle, shame-free comeback experience
- A clear healthy stopping point after every story
- Idempotent story completion, so replay cannot duplicate collection progress
- Fail-closed language and culture review manifest for every story

## Version 0.5 Phase 1B highlights

- Figma-style product design system with an accessible, all-ages interface
- Custom floating navigation using **Home**, **Learn**, **Games**, and **Profile**
- English interface labels with Mizo lesson content and explanations
- Platform-native typography, consistent 8-point spacing, iconography, and states
- **Bulṭan**, **Zirchho**, and **Thiamna** learning paths
- Picture Match, Spelling, Word Search, Word Chain, Tawng Upa, and Crossword
- Randomized rounds, three hearts, combo scoring, accuracy, stars, and XP
- Persistent XP, learning path, completions, daily goal, and best scores
- Five-step guest onboarding with broad age band, proficiency and goal choices
- SQLite progress/reward/session repository on Android, iOS and macOS
- Idempotent reward ledger, so one result cannot award XP twice
- Seeded Game Engine V2 and full presentation-state resume for all six games
- Relaxed, Standard and 90-second Timed modes with per-game tutorials
- App lifecycle pause/autosave and explicit Resume/Start New controls
- Hint-assisted scoring with saved hint state
- In-app local progress reset and privacy-minimal analytics event contract
- Fail-closed production content gate and versioned SHA-256 pilot manifest
- 30 structured Mizo entries with categories, difficulty, and review status
- Offline-first play; no account or public chat
- Secure Google Cloud Translation integration plan using Mizo code `lus`

## Phase 0 foundation

The professional-product foundation now includes:

- Product requirements and learner personas
- A 20-screen UX product flow
- Mizo editorial governance and Content Schema V2
- A draft pilot set of 100 words, 40 sentences, and 30 audio rows
- Production architecture and Game Session Engine V2 specifications
- Privacy/child-safety data inventory
- Improved Mac preflight runner, artifact validation, and Flutter CI
- Approved Phase 0 product defaults recorded in `PRODUCT_DECISION_RECORD.md`

Start with [`docs/PHASE_0_GATE_REPORT.md`](docs/PHASE_0_GATE_REPORT.md). Draft
language content is not public-release approved until two qualified Mizo
reviewers sign it off.

Phase 1 implementation status and open exit gates are recorded in
[`docs/PHASE_1_IMPLEMENTATION.md`](docs/PHASE_1_IMPLEMENTATION.md).
The Phase 1B implementation report is
[`docs/PHASE_1B_IMPLEMENTATION.md`](docs/PHASE_1B_IMPLEMENTATION.md).
The Mac verification and stabilization report is
[`docs/PHASE_1C_IMPLEMENTATION.md`](docs/PHASE_1C_IMPLEMENTATION.md).
The learning-engine implementation report is
[`docs/PHASE_2A_IMPLEMENTATION.md`](docs/PHASE_2A_IMPLEMENTATION.md).
The audio and new-game implementation report is
[`docs/PHASE_2B_IMPLEMENTATION.md`](docs/PHASE_2B_IMPLEMENTATION.md).
The audio-production and learner-validation report is
[`docs/PHASE_2C_IMPLEMENTATION.md`](docs/PHASE_2C_IMPLEMENTATION.md).
The journey, story and engagement-core report is
[`docs/PHASE_3A_IMPLEMENTATION.md`](docs/PHASE_3A_IMPLEMENTATION.md).
The Culture Trail, collection and cohort-validation report is
[`docs/PHASE_3B_IMPLEMENTATION.md`](docs/PHASE_3B_IMPLEMENTATION.md).

> The included corpus is product seed content. Any entry marked
> `reviewRequired` must be approved by a Mizo language educator before release.

## Run on a Mac

Install the current Flutter SDK and Xcode. From this project directory run:

```bash
chmod +x run_mac.command
./run_mac.command
```

Choose an iOS Simulator when prompted, or run a named target:

```bash
open -a Simulator
flutter devices
flutter run -d <device-id>
```

The first `flutter create` command generates the iOS, Android, macOS, and web host
projects while preserving `lib/`, `test/`, and assets from this package.

Double-click `run_mac.command` also works. For checks without opening the app:

```bash
./run_mac.command check
```

The check now includes formatting, analysis, tests and a macOS debug build. If
it fails, send `hnahsin_diagnostics.txt`; the launcher creates it
automatically. You can regenerate it with `./run_mac.command report`.

See [`docs/MAC_SETUP.md`](docs/MAC_SETUP.md) for Flutter/Xcode troubleshooting.

## Run Editorial Studio on a Mac

Install Ruby 3.3+, Bundler and PostgreSQL, then run:

```bash
export EDITORIAL_ADMIN_EMAIL="owner@example.org"
export EDITORIAL_ADMIN_PASSWORD="a-password-manager-generated-secret"
./run_backend.command setup
./run_backend.command
```

Open `http://localhost:3000`. Verify the backend with
`./run_backend.command check`. See
[`docs/EDITORIAL_STUDIO_OPERATIONS.md`](docs/EDITORIAL_STUDIO_OPERATIONS.md).

## Release builds

```bash
flutter build appbundle --release
flutter build ipa --release
```

Before store submission, set final bundle identifiers, signing teams, privacy
details, screenshots, age rating, and launcher icons. Have Mizo educators sign
off the full content set and test with children and adults.

## Project structure

```text
lib/
  main.dart
  features/
    learning/
      domain/        TQ levels, mastery, scheduling and daily planning
      presentation/  Placement, daily lesson and skill dashboard
    games/            Shared engines and Phase 2B game presentations
    journey/          Phase 3 map, stories, Culture Trail, rewards and UI
  src/
    app.dart           Premium shell and navigation
    controller.dart    Repository-backed learner profile and progress
    data.dart          Structured offline Mizo content
    game_session.dart  Compatibility façade for Game Engine V2
    games.dart         Six original playable game modes
    screens.dart       Home, learning path, games, profile
    theme.dart         Design tokens and Material theme
    widgets.dart       Shared premium UI components
docs/
  ARCHITECTURE_ADR.md             Offline-first production architecture
  CONTENT_EDITORIAL_GUIDE.md      Mizo review and publishing rules
  CONTENT_SCHEMA_V2.md            Versioned content contract
  GAME_ENGINE_V2_SPEC.md          Shared game-session platform
  LEARNER_PERSONAS.md             Priority learner needs and testing
  MASTER_ROADMAP.md               Product, learning, game and launch master plan
    MAC_SETUP.md                    Mac preflight, test and run help
    MAC_QA_CHECKLIST.md             Automated, accessibility and stability gate
    PHASE_1C_IMPLEMENTATION.md      Mac verification and stabilization evidence
    PHASE_2A_IMPLEMENTATION.md      Levels, mastery, scheduling and daily plan
    PHASE_2B_IMPLEMENTATION.md      Audio gate, player and two new games
    PHASE_2C_IMPLEMENTATION.md      Audio production and learner evidence status
    PHASE_2C_FIELD_PLAYBOOK.md      Recording and usability-test operations
    PHASE_3A_IMPLEMENTATION.md      Journey/story engineering and open gates
    PHASE_3A_CONTENT_REVIEW.md      Language and culture review checklist
    PHASE_3B_IMPLEMENTATION.md      Culture/collection engineering and gates
    PHASE_3B_FIELD_PLAYBOOK.md      Four-week cohort validation procedure
    PHASE_3C_IMPLEMENTATION.md      Release-closure engineering and evidence
    PHASE_3_REVIEW_HANDOFF.md       Language/culture reviewer workflow
    COMMUNITY_PILOT_RUNBOOK.md      Consent, incidents and cohort operations
  PHASE_0_GATE_REPORT.md          Evidence, blockers and next actions
  PHASE_0_SPRINT.md               Two-to-three-week sprint board
  PRIVACY_DATA_INVENTORY.md       Child-safety and planned data map
  PRODUCT_DECISION_RECORD.md      Approved Phase 0 product defaults
  PRODUCT_REQUIREMENTS.md         Product scope and acceptance criteria
  UX_PRODUCT_FLOW.md              Twenty-screen design handoff
  VALIDATION_PLAYBOOK.md          Reviewer, audio and learner-test procedure
  google_cloud_mizo_strategy.md
  ui_design_system.md
content/
  pilot/                          Draft words and sentences
  schema/                         Machine-readable Content Schema V2
  journey/                        Phase 3 story/culture review manifests
scripts/
  validate_phase0.py              Dependency-free artifact validation
  validate_phase1.py              Core architecture/checksum guard
  validate_phase1b.py             Resume/timer/hint adapter guard
  validate_phase2a.py             Learning engine and persistence guard
  validate_phase2b.py             New-game (Thumal Kawp, Sentence Builder) guard
  validate_phase2c.py             Production and evidence-workflow guard
  validate_phase3a.py             Journey/story architecture guard
  validate_phase3b.py             Culture/collection/evidence guard
  validate_phase3c.py             Release-closure and pilot-readiness guard
  learner_validation_gate.py      Strict sample and usability threshold gate
  journey_release_gate.py         Strict language/culture story gate
  culture_release_gate.py         Strict Culture Trail review gate
  engagement_validation_gate.py  Strict four-week cohort gate
  phase3_review_workflow.py       Review queue validation and safe promotion
  pilot_readiness_gate.py         Community-pilot operational safety gate
  mac_verification_gate.py        Version-bound native Mac evidence gate
  phase3_exit_gate.py             Aggregate strict Phase 3 release gate
assets/branding/
backend/                              Rails Editorial Studio and content API
test/
```

## Product-safety position

Canonical Mizo wording never comes directly from machine translation. Cloud
Translation may suggest an English gloss through a controlled backend, but a
human reviewer must approve it before publication. API credentials must never
be embedded in the Flutter application.

## Product roadmap

Development from this prototype onward is governed by
[`docs/MASTER_ROADMAP.md`](docs/MASTER_ROADMAP.md). It defines the learner
segments, learning and retention systems, Mizo editorial governance, child
safety, architecture, success metrics, phase deliverables, and release gates.

The current milestone is **Phase 4C — Staging Deployment, Real Audio Pilot &
Production Sync Validation**. Its source implementation is complete. Railway,
private-bucket, real-speaker/reviewer, offline-device, backup and rollback
evidence remain external gates and must not be marked complete without a real run.
