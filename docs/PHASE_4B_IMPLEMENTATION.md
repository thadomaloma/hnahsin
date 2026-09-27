# Phase 4B — Content Delivery, Audio Pipeline & Offline Sync

Build: **0.11.0+21**

## Delivered

- Direct-to-object-store audio upload with short-lived signatures and server-side size, MIME and SHA-256 verification.
- Speaker/dialect/date/consent/licence provenance; independent language and audio review; no uploader self-review.
- Authenticated preview, immutable audio releases, full-snapshot publishing, public read API and auditable rollback.
- Flutter ETag sync for content/audio packs, strict `lus` schema checks, per-file integrity limits, immutable local files and atomic active-pack pointers.
- Last verified content survives offline, timeout, malformed JSON, partial download and checksum failure.
- Reviewed remote word records feed Word Library, placement, Daily Lesson, Picture Match and Listen & Pick. Bundled content remains the safe fallback.
- Professional learner-facing delivery status with explicit update action; no learner account/progress payload is introduced.

## Release gates

Run `./run_backend.command check` for migrations, RuboCop, Brakeman, Rails tests/routes and Phase 4B contracts. Run `./run_mac.command check` for validators, formatting, Flutter analysis/tests and a macOS debug build.

This environment did not contain Ruby, PostgreSQL, Flutter or Dart, so the project must still pass both commands on the Mac before Phase 4B is signed off.

## Editorial word body contract

Published `word` records become runtime content when their body contains non-empty `word`, `meaning_mizo`, `english_gloss`, `example_mizo`, `emoji`, a supported `category`, and integer `difficulty` from 1–5. A remote catalog must contain at least 20 reviewed words, including five beginner words, to replace the bundled catalog and satisfy the production content gate.

## Phase 4C entry conditions

- Mac and backend checks pass against build 21.
- Staging uses private object storage and narrow CORS.
- Two named independent audio reviewers complete one real recording through publish/download/offline replay.
- A corrupt-candidate drill proves the last verified pack stays playable.
