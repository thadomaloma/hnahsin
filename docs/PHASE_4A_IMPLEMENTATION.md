# Phase 4A — Backend Foundation & Editorial Studio Core

**Build:** 0.10.0+20  
**Date:** 13 September 2026  
**Status:** Engineering core implemented; native Rails/Flutter gates require Mac/CI evidence

## Delivered

- Rails 8.1 full-stack Editorial Studio and PostgreSQL schema
- Secure signed-cookie sessions, CSRF protection, login rate limiting and
  inactive-user denial
- Editor, Language Reviewer, Culture Reviewer, Publisher and Admin roles
- Immutable content revisions with stable IDs and canonical SHA-256 checksums
- Maker-checker workflow: author self-review prohibited and dual reviews require
  distinct people
- Fail-closed release service: no unreviewed revision can enter a content pack
- Immutable published packs, exact-version rollback and append-only audit events
- Premium responsive server-rendered Editorial Studio screens in natural English
- Public read-only versioned API with ETag/Last-Modified/checksum headers
- PostgreSQL migration, seed-by-environment, Docker/staging definition and CI
- Service/API tests for authorization, approvals, publish, rollback, checksums,
  cache requests and audit immutability

## Deliberate Phase 4A boundary

The Flutter learner app remains guest-first and offline-first. Phase 4A stores
editorial staff email, password digest, role and audit history; it does not
store learner accounts, progress, answers, voice or analytics. Audio upload/CDN,
optional sync, family groups and closed beta operations remain later Phase 4
work.

## Verification state

Dependency-free repository contract validation passes in the supplied build.
This build environment has no Ruby, Bundler, PostgreSQL, Flutter or Dart
toolchain, so it cannot truthfully attest runtime Rails tests, static analysis
or native builds. Run both gates on the Mac:

```bash
./run_backend.command check
./run_mac.command check
```

GitHub CI independently runs RuboCop, Brakeman, Rails tests, Flutter format,
analysis, tests and Android/iOS/macOS smoke builds.

## Phase 4A acceptance

| Gate | Engineering status | Authoritative evidence |
|---|---|---|
| Required roles and self-review denial | Implemented | Rails service tests pending run |
| Unreviewed content cannot publish | Implemented | Rails service tests pending run |
| Pack checksum and conditional API | Implemented | Rails request tests pending run |
| Exact reviewed rollback | Implemented | Rails service tests pending run |
| Offline learner app remains independent | Preserved | Flutter Mac gate pending this build |
| Staging deploy | Prepared | Real host/secret/backup drill pending |

Phase 4A may be accepted after the two local/CI gates pass. A community beta is
not authorized by this engineering checkpoint alone.
