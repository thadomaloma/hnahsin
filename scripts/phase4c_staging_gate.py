#!/usr/bin/env python3
"""Validate Phase 4C human, deployment, content-release and live-sync evidence."""

from __future__ import annotations

import argparse
import json
import re
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import urlparse


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_PILOT = ROOT / "validation/phase4c/staging_pilot.json"
DEFAULT_SMOKE = ROOT / "validation/phase4c/live_smoke.json"
SHA256 = re.compile(r"^[0-9a-f]{64}$")
DRILLS = {
    "clean_install_sync",
    "offline_replay",
    "corrupt_candidate_rejected",
    "last_verified_pack_preserved",
    "rollback_restored_pack",
}


def load_object(path: Path) -> dict[str, object]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise ValueError(f"cannot read valid JSON from {path}: {error}") from error
    if not isinstance(value, dict):
        raise ValueError(f"JSON object required: {path}")
    return value


def text(value: object) -> bool:
    return isinstance(value, str) and bool(value.strip())


def validate(pilot_path: Path, smoke_path: Path) -> tuple[list[str], list[str]]:
    errors: list[str] = []
    blockers: list[str] = []
    pilot = load_object(pilot_path)
    smoke = load_object(smoke_path)

    for name, value in (("pilot", pilot), ("live smoke", smoke)):
        if value.get("schema_version") != "1.0":
            errors.append(f"{name}: schema_version must be 1.0")
        if value.get("build") != "0.12.0+22":
            errors.append(f"{name}: build must be 0.12.0+22")

    if pilot.get("environment") != "staging":
        errors.append("pilot: environment must be staging")
    base_url = pilot.get("base_url")
    if text(base_url):
        parsed = urlparse(str(base_url))
        if parsed.scheme != "https" or not parsed.hostname:
            errors.append("pilot: base_url must be a valid HTTPS origin")
    else:
        blockers.append("staging base URL is pending")
    executed_at = pilot.get("executed_at")
    if not text(executed_at):
        blockers.append("pilot execution timestamp is pending")
    else:
        try:
            executed = datetime.fromisoformat(str(executed_at).replace("Z", "+00:00"))
            if executed.utcoffset() is None:
                raise ValueError
            age = datetime.now(timezone.utc) - executed.astimezone(timezone.utc)
            if age.total_seconds() < 0 or age.total_seconds() > 7 * 24 * 60 * 60:
                blockers.append("pilot evidence must be less than seven days old")
        except ValueError:
            errors.append("pilot: executed_at must be timezone-aware ISO 8601")
    if not text(pilot.get("operator_id")):
        blockers.append("pilot operator ID is pending")

    deployment = pilot.get("deployment")
    required_deployment = {
        "production_secrets_configured",
        "database_backup_restore_tested", "log_redaction_checked", "ready_endpoint_passed",
    }
    if not isinstance(deployment, dict) or set(deployment) != required_deployment:
        errors.append("pilot: deployment controls do not match the Phase 4C schema")
    else:
        for key in sorted(required_deployment):
            if deployment[key] is not True:
                blockers.append(f"deployment control pending: {key}")

    roles = pilot.get("role_separation")
    role_keys = {"editor_id", "language_reviewer_id", "publisher_id"}
    if not isinstance(roles, dict) or set(roles) != role_keys:
        errors.append("pilot: role_separation schema is invalid")
    else:
        ids = [roles[key] for key in sorted(role_keys)]
        if not all(text(value) for value in ids):
            blockers.append("three pseudonymous workflow role IDs are required")
        elif len(set(ids)) != len(ids):
            blockers.append("editor, language reviewer and publisher must be distinct")

    release = pilot.get("content_release")
    release_keys = {"published_content_pack_version", "published_content_pack_checksum"}
    if not isinstance(release, dict) or set(release) != release_keys:
        errors.append("pilot: content_release schema is invalid")
    else:
        if not text(release["published_content_pack_version"]):
            blockers.append("published content pack version is pending")
        if not isinstance(release["published_content_pack_checksum"], str) or not SHA256.fullmatch(release["published_content_pack_checksum"]):
            blockers.append("published content pack SHA-256 is pending")

    drills = pilot.get("drills")
    if not isinstance(drills, dict) or set(drills) != DRILLS:
        errors.append("pilot: sync drill schema is invalid")
    else:
        for name in sorted(DRILLS):
            result = drills[name]
            if not isinstance(result, dict) or set(result) != {"passed", "evidence_ref"}:
                errors.append(f"pilot: invalid drill record: {name}")
            elif result["passed"] is not True or not text(result["evidence_ref"]):
                blockers.append(f"sync drill pending: {name}")

    signoffs = pilot.get("signoffs")
    signoff_keys = {"backend_owner_id", "language_lead_id", "privacy_owner_id"}
    if not isinstance(signoffs, dict) or set(signoffs) != signoff_keys:
        errors.append("pilot: signoff schema is invalid")
    elif not all(text(signoffs[key]) for key in signoff_keys):
        blockers.append("backend, language and privacy sign-offs are pending")

    if smoke.get("ready") is not True:
        blockers.append("live staging readiness smoke is pending")
    if smoke.get("etag_revalidation") is not True:
        blockers.append("live ETag revalidation is pending")
    if not isinstance(smoke.get("reviewed_word_count"), int) or smoke["reviewed_word_count"] < 20:
        blockers.append("live staging needs at least 20 reviewed words")
    if text(base_url) and smoke.get("base_url") != str(base_url).rstrip("/"):
        blockers.append("pilot and live-smoke staging origins do not match")
    if isinstance(release, dict) and text(release.get("published_content_pack_checksum")):
        if smoke.get("content_checksum") != release["published_content_pack_checksum"]:
            blockers.append("pilot and live-smoke content pack checksums do not match")
    checked_at = smoke.get("checked_at")
    if text(checked_at):
        try:
            checked = datetime.fromisoformat(str(checked_at).replace("Z", "+00:00"))
            if checked.utcoffset() is None:
                raise ValueError
            age = datetime.now(timezone.utc) - checked.astimezone(timezone.utc)
            if age.total_seconds() < 0 or age.total_seconds() > 24 * 60 * 60:
                blockers.append("live staging smoke must be less than 24 hours old")
        except ValueError:
            errors.append("live smoke: checked_at must be ISO 8601")
    else:
        blockers.append("live staging smoke timestamp is pending")
    return errors, blockers


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--pilot", type=Path, default=DEFAULT_PILOT)
    parser.add_argument("--smoke", type=Path, default=DEFAULT_SMOKE)
    parser.add_argument("--strict", action="store_true")
    args = parser.parse_args()
    try:
        errors, blockers = validate(args.pilot, args.smoke)
    except ValueError as error:
        raise SystemExit(f"ERROR: {error}") from error
    if errors:
        raise SystemExit("ERROR: Phase 4C evidence structure failed:\n- " + "\n- ".join(errors))
    if blockers:
        print(f"Phase 4C evidence structure: PASS ({len(blockers)} external gates pending)")
        for blocker in blockers:
            print(f"- {blocker}")
        if args.strict:
            raise SystemExit("ERROR: Phase 4C strict staging gate is not ready")
        return
    print("PHASE 4C STAGING, CONTENT RELEASE AND PRODUCTION SYNC: PASS")


if __name__ == "__main__":
    main()
