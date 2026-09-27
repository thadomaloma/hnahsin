# Editorial Studio Operations

**Build:** 0.10.0+20  
**Scope:** Phase 4A content workflow and release operations

## Role separation

| Role | May do | Must not do |
|---|---|---|
| Editor | Create metadata/revisions; submit drafts | Approve own work; publish |
| Language Reviewer | Approve/reject Mizo language | Edit revision; self-approve; publish |
| Culture Reviewer | Approve/reject cultural context | Edit revision; self-approve; publish |
| Publisher | Publish fully approved packs; rollback | Bypass required review |
| Admin | Operate all workflow areas | Self-approval remains prohibited |

No self-approval is allowed. Stories, culture cards and seasonal trails need
both Language Reviewer and Culture Reviewer decisions from different people.
Words and sentences need Language Reviewer approval. A rejection requires a
note and sends the item back to draft work.

## First local setup

```bash
brew install ruby postgresql@16
brew services start postgresql@16
gem install bundler
export EDITORIAL_ADMIN_EMAIL="owner@example.org"
export EDITORIAL_ADMIN_PASSWORD="use-a-password-manager-generated-secret"
./run_backend.command setup
./run_backend.command
```

The seed script creates an admin only when both environment variables are
present. It includes no default or committed password.

Create least-privilege team accounts without placing passwords in source:

```bash
cd backend
EMAIL="reviewer@example.org" PASSWORD="generated-secret" ROLE="language_reviewer" bin/rake editorial:upsert_user
EMAIL="former-member@example.org" bin/rake editorial:disable_user
```

## Release procedure

1. Editor creates a structured Mizo-first revision and submits it.
2. Required independent reviewers inspect learner text, meaning, examples,
   age-fit, cultural context and rights/provenance.
3. Publisher selects only approved items and assigns a new semantic version.
4. Studio freezes the manifest, revision selection and SHA-256 checksum.
5. Validate `/api/v1/content_packs/latest` and a specific public UUID in staging.
6. Flutter downloads to temporary storage and keeps its prior offline pack until
   the new pack passes schema and checksum validation.

## Rollback procedure

A published pack is immutable. Do not edit it in place. Open the known-good
release, enter a new semantic version and choose **Publish rollback**. The new
pack points to the exact reviewed revisions from the source pack and records
`rollback_of` plus an append-only audit event.

## Staging checklist

- Configure `DATABASE_URL`, `RAILS_MASTER_KEY` and a strong `SECRET_KEY_BASE` in
  the host secret store.
- Keep TLS/`force_ssl` enabled and restrict administrator access operationally.
- Run `./run_backend.command check` before deployment.
- Run database migrations as a pre-deploy step; verify `/up` afterwards.
- Create named users with the minimum required role; disable departed users.
- Back up PostgreSQL and rehearse restore before community beta.
- Export audit history to restricted retention storage; do not put learner data
  in editorial JSON.
- Add MFA/SSO before broad production access; password auth is Phase 4A staging
  foundation only.
