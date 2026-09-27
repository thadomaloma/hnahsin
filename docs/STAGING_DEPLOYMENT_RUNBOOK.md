# Phase 4C Staging Deployment Runbook

## 1. Railway topology

Create a separate Railway **staging** environment with one service rooted at
`backend/` and one PostgreSQL service. Railway builds `backend/Dockerfile`, runs
`bin/rails db:migrate` before deployment, and accepts traffic only after
`GET /ready` confirms PostgreSQL is available.
`GET /up` is liveness only.

Use a staging-only HTTPS domain. Never point a development build at the
production Editorial Studio.

## 2. Required variables

```text
DATABASE_URL=<Railway PostgreSQL reference>
SECRET_KEY_BASE=<bin/rails secret output>
```

Keep Rails and database credentials in Railway variables, never `.env` or
Flutter. No object storage is needed: Thumal Quest has no audio or uploads.

## 4. Deploy and bootstrap

After Railway reports `/ready` healthy, create accounts with unique email
addresses and separate real operators:

```bash
EMAIL=editor@example.org PASSWORD='managed-secret' ROLE=editor \
  bin/rails editorial:upsert_user
EMAIL=language@example.org PASSWORD='managed-secret' ROLE=language_reviewer \
  bin/rails editorial:upsert_user
EMAIL=publisher@example.org PASSWORD='managed-secret' ROLE=publisher \
  bin/rails editorial:upsert_user
```

Use Railway's secret-variable mechanism instead of shell history for real
passwords. Confirm login rate limiting, redacted logs, backup schedule and one
restore rehearsal before recording pilot evidence.

## 5. Live delivery verification

From the project root on the Mac:

```bash
export STAGING_BASE_URL="https://editorial-staging.example.org"
./run_staging.command smoke
./run_staging.command app
```

The smoke command verifies HTTPS, `/up`, `/ready`, canonical manifest SHA-256,
ETag/304 behavior and 20+ valid reviewed words. The app command launches the production-gated Flutter build against
that origin. Disable the network only after a successful sync and confirm that
lessons and games still work.

## 6. Incident and rollback

For a failed candidate, do not edit a published database pack. Stop new
publishing, preserve request/pack/checksum evidence, and publish a new rollback
version from the last known-good release. Re-run `./run_staging.command smoke`,
then verify a clean install and an already-synced offline device. Rotate any exposed secret before reopening staging.
