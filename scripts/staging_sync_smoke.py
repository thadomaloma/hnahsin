#!/usr/bin/env python3
"""Verify a live staging deployment and its reviewed content pack."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import ssl
import sys
from datetime import datetime, timezone
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import urljoin, urlparse
from urllib.request import Request, urlopen


MAX_JSON_BYTES = 5 * 1024 * 1024


def fail(message: str) -> None:
    raise RuntimeError(message)


def canonical_json(value: object) -> bytes:
    return json.dumps(
        value, ensure_ascii=False, sort_keys=True, separators=(",", ":")
    ).encode("utf-8")


def fetch(url: str, *, etag: str | None = None, maximum: int = MAX_JSON_BYTES) -> tuple[int, dict[str, str], bytes]:
    headers = {"Accept": "application/json", "User-Agent": "ThumalQuest-Phase4C/1.0"}
    if etag:
        headers["If-None-Match"] = etag
    request = Request(url, headers=headers)
    try:
        with urlopen(request, timeout=20, context=ssl.create_default_context()) as response:
            body = response.read(maximum + 1)
            if len(body) > maximum:
                fail(f"response exceeds safe limit: {url}")
            return response.status, {key.lower(): value for key, value in response.headers.items()}, body
    except HTTPError as error:
        if error.code == 304:
            return 304, {key.lower(): value for key, value in error.headers.items()}, b""
        fail(f"HTTP {error.code}: {url}")
    except URLError as error:
        fail(f"network error for {url}: {error.reason}")


def require_json(base_url: str, path: str) -> tuple[dict[str, object], dict[str, str]]:
    status, headers, body = fetch(urljoin(base_url, path))
    if status != 200:
        fail(f"expected HTTP 200 for {path}, got {status}")
    try:
        payload = json.loads(body)
    except (UnicodeDecodeError, json.JSONDecodeError) as error:
        fail(f"invalid JSON for {path}: {error}")
    if not isinstance(payload, dict):
        fail(f"JSON object required for {path}")
    return payload, headers


def verify_pack(base_url: str, path: str, *, item_key: str) -> tuple[dict[str, object], dict[str, str]]:
    payload, headers = require_json(base_url, path)
    manifest = payload.get("manifest")
    if not isinstance(manifest, dict):
        fail(f"manifest object missing for {path}")
    if manifest.get("schema_version") != "1.0" or manifest.get("language") != "lus":
        fail(f"unsupported schema or language for {path}")
    if manifest.get("pack_version") != payload.get("version"):
        fail(f"pack version mismatch for {path}")
    checksum = hashlib.sha256(canonical_json(manifest)).hexdigest()
    if checksum != payload.get("checksum") or headers.get("x-content-checksum") != checksum:
        fail(f"manifest checksum mismatch for {path}")
    values = manifest.get(item_key)
    if not isinstance(values, list) or not values:
        fail(f"non-empty {item_key} required for {path}")
    etag = headers.get("etag")
    if not etag:
        fail(f"ETag missing for {path}")
    conditional, _, _ = fetch(urljoin(base_url, path), etag=etag)
    if conditional != 304:
        fail(f"conditional request did not return 304 for {path}")
    return payload, headers


def verify_content(payload: dict[str, object]) -> int:
    items = payload["manifest"]["items"]  # type: ignore[index]
    words = []
    stable_ids: set[str] = set()
    for item in items:  # type: ignore[union-attr]
        if not isinstance(item, dict):
            fail("content item must be an object")
        stable_id = item.get("stable_id")
        body = item.get("body")
        if not isinstance(stable_id, str) or not stable_id or stable_id in stable_ids:
            fail("content stable IDs must be present and unique")
        stable_ids.add(stable_id)
        if not isinstance(body, dict):
            fail(f"content body is invalid for {stable_id}")
        if hashlib.sha256(canonical_json(body)).hexdigest() != item.get("checksum"):
            fail(f"content item checksum mismatch for {stable_id}")
        if item.get("content_type") != "word":
            continue
        required = ("word", "meaning_mizo", "english_gloss", "example_mizo", "emoji", "category")
        if all(isinstance(body.get(key), str) and body[key].strip() for key in required):
            if isinstance(body.get("difficulty"), int) and 1 <= body["difficulty"] <= 7:
                words.append(body)
    if len(words) < 20 or sum(word["difficulty"] == 1 for word in words) < 5:
        fail("staging requires 20 valid reviewed words including five beginner words")
    return len(words)


def run(base_url: str) -> dict[str, object]:
    parsed = urlparse(base_url)
    local = parsed.hostname in {"localhost", "127.0.0.1"}
    if parsed.scheme != "https" and not (local and parsed.scheme == "http"):
        fail("staging base URL must use HTTPS")
    base_url = base_url.rstrip("/") + "/"
    live, _ = require_json(base_url, "/up")
    ready, _ = require_json(base_url, "/ready")
    if live.get("status") != "ok" or ready.get("status") != "ready":
        fail("deployment is not live and ready")
    content, _ = verify_pack(base_url, "/api/v1/content_packs/latest", item_key="items")
    word_count = verify_content(content)
    return {
        "schema_version": "1.0",
        "build": "0.12.0+22",
        "checked_at": datetime.now(timezone.utc).isoformat(),
        "base_url": base_url.rstrip("/"),
        "ready": True,
        "content_version": content["version"],
        "content_checksum": content["checksum"],
        "reviewed_word_count": word_count,
        "etag_revalidation": True,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--base-url", default=os.environ.get("STAGING_BASE_URL"))
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    if not args.base_url:
        raise SystemExit("ERROR: --base-url or STAGING_BASE_URL is required")
    try:
        report = run(args.base_url)
    except RuntimeError as error:
        raise SystemExit(f"ERROR: {error}") from error
    rendered = json.dumps(report, ensure_ascii=False, indent=2) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(rendered, encoding="utf-8")
    sys.stdout.write(rendered)
    print("PHASE 4C LIVE STAGING SYNC: PASS")


if __name__ == "__main__":
    main()
