# Phase 4C — Staging Deployment, Real Audio Pilot & Production Sync Validation

**Build:** 0.12.0+22  
**Status:** Source-complete; external evidence intentionally pending

## Implemented

- Dependency-aware `/ready` endpoint verifies PostgreSQL and disk/S3 media; `/up` remains lightweight liveness.
- Production refuses to boot without private S3 configuration.
- Railway deploy now gates traffic on `/ready` and migrates before release.
- Runtime container uses an unprivileged user.
- Live HTTPS smoke validates content/audio manifest SHA-256, ETag/304, runtime word minimums and every published audio file.
- Flutter rejects pack JSON above 5 MiB and audio packs above 100 clips/250 MiB.
- Every audio asset is bound to an independently reviewed content revision; every audio release names the exact content-pack ID, version and SHA-256 it was recorded for. Backend publishing, live smoke and Flutter all reject cross-revision audio.
- Real pilot evidence schema enforces five clips, consent references, four distinct workflow operators, five device/failure drills and four owner sign-offs.
- One-command staging report, smoke, strict gate and production-gated Mac app launch.
- CI validates Phase 4C contracts, builds the production container and offers a manual live-staging smoke workflow.

## Truthful release state

Code and dependency-free structural gates can pass in this workspace. A Railway
deployment, private bucket, real native-speaker recordings, independent human
reviews, database restore, physical-device offline run and controlled rollback
cannot be fabricated. Their templates remain `false`/`null` until operators
perform them. Therefore Phase 4C strict approval is expected to remain blocked
until the runbooks are completed.

## Exit gate

```bash
./run_backend.command check
./run_mac.command check
export STAGING_BASE_URL="https://your-staging-origin"
./run_staging.command strict
```

Only all three successful commands authorize Phase 5 — Store Launch Readiness.
