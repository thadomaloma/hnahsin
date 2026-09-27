# Phase 3 Language & Culture Review Handoff

## Rule

No self-approval and no machine-generated approval. A qualified Mizo language
reviewer checks wording/naturalness; a culture reviewer checks accuracy,
representation and contemporary context. One person may hold both roles only if
the project records that qualification explicitly outside this repository.

## Privacy-safe reviewer record

Use an opaque `reviewer_id` such as `REV-LANG-01`; do not put a person's name,
email or phone number in Git. Keep the reviewer-to-ID register in controlled
organisational storage.

## Workflow

1. Review every story/card in the running app and its manifest source.
2. Fill `validation/phase3c/review_decisions.csv`.
3. Use `pending`, `approved` or `rejected`; rejected rows require notes.
4. Use an ISO-8601 date/time such as `2026-09-20T10:00:00+09:00`.
5. Validate without changing manifests:

   ```bash
   python3 scripts/phase3_review_workflow.py
   ```

6. After a second person checks the sheet, apply decisions:

   ```bash
   python3 scripts/phase3_review_workflow.py --apply
   ```

7. Confirm the source manifests and full release blockers:

   ```bash
   python3 scripts/journey_release_gate.py --strict
   python3 scripts/culture_release_gate.py --strict
   python3 scripts/phase3_exit_gate.py --strict
   ```

The apply command updates only the review objects and pack publication state.
It does not rewrite Mizo learning content or convert a rejection into approval.
