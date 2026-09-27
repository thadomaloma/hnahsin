#!/usr/bin/env python3
"""Write Mac evidence only after run_mac.command completes every check."""

from __future__ import annotations

import argparse
import json
from datetime import datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "validation/phase3c/mac_verification.json"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--macos", required=True)
    parser.add_argument("--arch", required=True)
    parser.add_argument("--flutter", required=True)
    parser.add_argument("--xcode", required=True)
    args = parser.parse_args()
    payload = {
        "schema_version": "1.0",
        "app_version": "0.12.0+22",
        "status": "passed",
        "verified_at": datetime.now(timezone.utc).isoformat(),
        "environment": {
            "macos": args.macos,
            "arch": args.arch,
            "flutter": args.flutter,
            "xcode": args.xcode,
        },
        "checks": {
            "artifact_validators": "passed",
            "dart_format": "passed",
            "flutter_analyze": "passed",
            "flutter_tests": "passed",
            "macos_debug_build": "passed",
        },
    }
    OUTPUT.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"Mac verification evidence written: {OUTPUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
