#!/usr/bin/env python3
"""Validate safety and operations readiness before Phase 3 community testing."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_MANIFEST = ROOT / "validation/phase3c/pilot_readiness.json"
REQUIRED_CONTROLS = {
    "privacy_notice_approved",
    "facilitator_briefed",
    "guardian_consent_route_tested",
    "withdrawal_and_deletion_tested",
    "support_owner_assigned",
    "incident_route_tested",
    "accessibility_route_ready",
    "content_preview_disclosed",
}
REQUIRED_PRIVACY = {
    "opaque_participant_ids_only",
    "no_names_contacts_exact_birthdates_or_precise_location",
    "signed_consent_stored_outside_repository",
    "withdrawal_rows_retained_as_zero_session_rows",
}


def validate(path: Path = DEFAULT_MANIFEST) -> tuple[list[str], list[str], int, int]:
    errors: list[str] = []
    blockers: list[str] = []
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        return [f"pilot manifest cannot be read: {error}"], [], 0, 0
    if payload.get("schema_version") != "1.0":
        errors.append("schema_version must be 1.0")
    if payload.get("target_participants") != 15:
        errors.append("target_participants must remain 15")
    if payload.get("target_weekly_rows") != 60:
        errors.append("target_weekly_rows must remain 60")
    controls = payload.get("controls")
    if not isinstance(controls, dict) or set(controls) != REQUIRED_CONTROLS:
        return errors + ["pilot controls do not match the contract"], [], 0, 0
    ready = 0
    for name, control in controls.items():
        if not isinstance(control, dict):
            errors.append(f"{name}: control must be an object")
            continue
        status = control.get("status")
        if status not in ("pending", "ready"):
            errors.append(f"{name}: status must be pending or ready")
        if status == "ready":
            ready += 1
            if not control.get("owner_id") or not control.get("evidence_ref"):
                errors.append(f"{name}: ready requires owner_id and evidence_ref")
        else:
            blockers.append(f"{name}: readiness evidence pending")
    privacy = payload.get("privacy_contract")
    if not isinstance(privacy, dict) or set(privacy) != REQUIRED_PRIVACY:
        errors.append("privacy contract does not match the required fields")
    elif not all(privacy.values()):
        errors.append("every privacy contract flag must remain true")
    if payload.get("status") != "ready":
        blockers.append("pilot status is not ready")
    return errors, blockers, len(controls), ready


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("manifest", nargs="?", type=Path, default=DEFAULT_MANIFEST)
    parser.add_argument("--strict", action="store_true")
    args = parser.parse_args()
    errors, blockers, total, ready = validate(args.manifest)
    if errors:
        print("COMMUNITY PILOT READINESS: FAIL")
        for error in errors:
            print(f"ERROR • {error}")
        return 1
    if blockers:
        print(f"COMMUNITY PILOT READINESS: PENDING ({ready}/{total} controls ready)")
        for blocker in blockers:
            print(f"PENDING • {blocker}")
        return 2 if args.strict else 0
    print(f"COMMUNITY PILOT READINESS: PASS ({ready}/{total} controls ready)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
