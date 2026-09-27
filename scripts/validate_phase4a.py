#!/usr/bin/env python3
"""Dependency-free Phase 4A backend/editorial contract checks."""

from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def fail(message: str) -> None:
    raise SystemExit(f"ERROR: {message}")


def require(relative: str, contracts: tuple[str, ...]) -> str:
    path = ROOT / relative
    if not path.is_file():
        fail(f"Required Phase 4A file is missing: {relative}")
    text = path.read_text(encoding="utf-8")
    for contract in contracts:
        if contract not in text:
            fail(f"{relative} is missing contract: {contract}")
    return text


def main() -> None:
    require("pubspec.yaml", ("version: 0.12.0+22",))
    require("backend/Gemfile", ('gem "rails", "~> 8.1.0"', 'gem "pg"', 'gem "brakeman"'))
    require(
        "backend/db/migrate/20260913090000_create_editorial_core.rb",
        ("create_table :content_revisions", "create_table :review_decisions", "create_table :content_packs", "create_table :audit_events", "jsonb_typeof(body)", "add_check_constraint"),
    )
    require(
        "backend/app/services/editorial/record_decision.rb",
        ("authors cannot review their own revision", "language and culture approval require different reviewers", "required_approvals_complete?"),
    )
    require(
        "backend/app/services/editorial/publish_pack.rb",
        ("every revision requires all approvals", "previously_published", "CanonicalJson.dump", "Digest::SHA256", "content_pack.published"),
    )
    require(
        "backend/app/controllers/api/v1/content_packs_controller.rb",
        ("status_published", "stale?", "X-Content-Checksum", "stale-if-error"),
    )
    require(
        "backend/app/controllers/sessions_controller.rb",
        ("rate_limit", "cookies.signed", "httponly", "same_site"),
    )
    require(
        "backend/test/services/editorial_workflow_test.rb",
        ("author cannot approve their own revision", "cannot release an unreviewed revision", "rollback republishes", "audit events cannot"),
    )
    require("docs/API_CONTENT_PACK_V1.md", ("ETag", "offline", "checksum"))
    require("docs/EDITORIAL_STUDIO_OPERATIONS.md", ("Language Reviewer", "Culture Reviewer", "rollback", "No self-approval"))
    require("run_backend.command", ("brakeman", "bin/rails test", "BACKEND CHECK PASSED"))
    config = json.loads((ROOT / "backend/railway.json").read_text(encoding="utf-8"))
    if config.get("deploy", {}).get("healthcheckPath") not in {"/up", "/ready"}:
        fail("Railway health check must target a supported health endpoint")
    print("Phase 4A backend foundation and Editorial Studio core: PASS")


if __name__ == "__main__":
    main()
