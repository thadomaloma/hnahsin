# Phase 4B Gate Report

**Build:** 0.11.0+21  
**Prepared:** 13 September 2026  
**Status:** Source-complete; native/backend runtime evidence pending

## Verified in this workspace

- Phase 0–4B dependency-free contract validators pass.
- Shell launchers pass `bash -n`.
- JSON evidence parses and Editorial Studio ERB delimiter scan passes.
- No production secret, uploaded audio, database, log or cache is included in the release archive.

## Required Mac evidence

```bash
cd "/path/to/thumal_quest"
./run_backend.command check
./run_mac.command check
```

The backend command must complete database preparation, RuboCop, Brakeman,
Rails tests and route loading. The Mac command must complete Dart formatting,
Flutter analysis/tests and the native macOS debug build. Attach both diagnostic
files if either command fails.

## Required staging evidence

- Private S3-compatible bucket with narrow Editorial Studio CORS.
- Real upload whose declared and stored MIME, size and SHA-256 agree.
- Uploader, Language Reviewer and Audio Reviewer are distinct people.
- Published pack downloads to a clean device and replays with network disabled.
- A deliberately corrupt candidate is rejected while the prior pack remains playable.
- Rollback publishes a new immutable version and restores the selected clip set.

Phase 4C is not approved until these runtime and human-review gates pass.

