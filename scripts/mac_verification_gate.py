#!/usr/bin/env python3
"""Validate authoritative Phase 3C Mac verification evidence."""

from __future__ import annotations

import argparse
import json
from datetime import datetime
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_MANIFEST = ROOT / "validation/phase3c/mac_verification.json"
EXPECTED_VERSION = "0.12.0+22"
REQUIRED_CHECKS = {
    "artifact_validators",
    "dart_format",
    "flutter_analyze",
    "flutter_tests",
    "macos_debug_build",
}
REQUIRED_ENVIRONMENT = {"macos", "arch", "flutter", "xcode"}


def validate(path: Path = DEFAULT_MANIFEST) -> tuple[list[str], list[str]]:
    errors: list[str] = []
    blockers: list[str] = []
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        return [f"Mac evidence cannot be read: {error}"], []
    if payload.get("schema_version") != "1.0":
        errors.append("schema_version must be 1.0")
    if payload.get("app_version") != EXPECTED_VERSION:
        errors.append(f"app_version must be {EXPECTED_VERSION}")
    environment = payload.get("environment")
    if not isinstance(environment, dict) or set(environment) != REQUIRED_ENVIRONMENT:
        errors.append("Mac environment fields do not match the contract")
    elif payload.get("status") == "passed" and not all(environment.values()):
        errors.append("passed evidence requires every Mac environment value")
    checks = payload.get("checks")
    if not isinstance(checks, dict) or set(checks) != REQUIRED_CHECKS:
        errors.append("Mac check fields do not match the contract")
    else:
        for name, status in checks.items():
            if status not in ("pending", "passed"):
                errors.append(f"{name}: status must be pending or passed")
            elif status != "passed":
                blockers.append(f"{name}: evidence pending")
    verified_at = payload.get("verified_at")
    if verified_at:
        try:
            datetime.fromisoformat(str(verified_at).replace("Z", "+00:00"))
        except ValueError:
            errors.append("verified_at must be ISO-8601")
    if payload.get("status") != "passed":
        blockers.append("Mac verification status is not passed")
    elif not verified_at:
        errors.append("passed evidence requires verified_at")
    return errors, blockers


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("manifest", nargs="?", type=Path, default=DEFAULT_MANIFEST)
    parser.add_argument("--strict", action="store_true")
    args = parser.parse_args()
    errors, blockers = validate(args.manifest)
    if errors:
        print("PHASE 3C MAC EVIDENCE: FAIL")
        for error in errors:
            print(f"ERROR • {error}")
        return 1
    if blockers:
        print("PHASE 3C MAC EVIDENCE: PENDING")
        for blocker in blockers:
            print(f"PENDING • {blocker}")
        return 2 if args.strict else 0
    print("PHASE 3C MAC EVIDENCE: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
