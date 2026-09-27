#!/usr/bin/env python3
"""Dependency-free Phase 4C staging and production-sync contract checks."""

from __future__ import annotations

import json
from pathlib import Path

from phase4c_staging_gate import validate as validate_staging


ROOT = Path(__file__).resolve().parents[1]


def fail(message: str) -> None:
    raise SystemExit(f"ERROR: {message}")


def require(relative: str, contracts: tuple[str, ...]) -> str:
    path = ROOT / relative
    if not path.is_file():
        fail(f"Required Phase 4C file is missing: {relative}")
    value = path.read_text(encoding="utf-8")
    for contract in contracts:
        if contract not in value:
            fail(f"{relative} is missing contract: {contract}")
    return value


def main() -> None:
    # The real-audio pilot and S3 media storage were retired with the removal
    # of audio on 2026-09-27; staging now covers reviewed content only.
    require("pubspec.yaml", ("version: 0.12.0+22",))
    require("backend/config/routes.rb", ('get "up"', 'get "ready"'))
    require(
        "backend/app/controllers/health_controller.rb",
        ("SELECT 1", "service_unavailable", "no-store"),
    )
    require("backend/railway.json", ('"healthcheckPath": "/ready"', '"preDeployCommand": "bin/rails db:migrate"'))
    require("backend/config/initializers/content_security_policy.rb", ("connect_src :self", "media_src :none"))
    require(
        "scripts/staging_sync_smoke.py",
        ("canonical_json", "If-None-Match", "content item checksum mismatch", "0.12.0+22", "HTTPS"),
    )
    require(
        "scripts/phase4c_staging_gate.py",
        ("editor, language reviewer and publisher must be distinct", "less than 24 hours old", "--strict"),
    )
    require(
        "lib/features/content_sync/application/content_transport.dart",
        ("maximumPackBytes", "Pack response exceeded the safe limit", "If-None-Match"),
    )
    require(
        "test/content_transport_test.dart",
        ("insecure non-local origin", "preserves a 304 response", "oversized pack response"),
    )
    require("backend/test/controllers/health_controller_test.rb", ("readiness checks the database", "fails closed"))
    require("run_staging.command", ("report|smoke|strict|app", "THUMAL_QUEST_PRODUCTION=true"))
    require("docs/PHASE_4C_IMPLEMENTATION.md", ("0.12.0+22", "Railway", "external evidence"))
    require("docs/STAGING_DEPLOYMENT_RUNBOOK.md", ("/ready", "rollback"))
    if (ROOT / "backend/config/initializers/production_delivery.rb").exists():
        fail("S3 media storage was removed; production_delivery.rb should not exist")
    config = json.loads((ROOT / "backend/railway.json").read_text(encoding="utf-8"))
    if config.get("deploy", {}).get("healthcheckPath") != "/ready":
        fail("Railway must use the dependency-aware /ready endpoint")
    errors, _ = validate_staging(
        ROOT / "validation/phase4c/staging_pilot.json",
        ROOT / "validation/phase4c/live_smoke.json",
    )
    if errors:
        fail("Phase 4C evidence templates are invalid: " + "; ".join(errors))
    print("Phase 4C staging, content release and production-sync contracts: PASS")


if __name__ == "__main__":
    main()
