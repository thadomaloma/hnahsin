#!/usr/bin/env python3
"""Compare English glosses in a review sheet with glosses a reviewer looked up.

Fill the `dictionary_gloss` column of content/review/*.csv with the short
English meaning you find in your own dictionary (a few words, not the whole
entry), then run:

    python3 scripts/compare_dictionary_glosses.py content/review/flagged_words_2026-09-27.csv

For every row with a dictionary gloss and no decision yet it fills
`suggested_decision` (ok / check / fix) and, for "fix", suggests the reviewer's
gloss as `suggested_english_meaning`. Nothing is approved: copy the
suggestions you agree with into `decision` / `fixed_english_meaning`, then run
`bin/rails editorial:apply_review_sheet FILE=...`.
"""

from __future__ import annotations

import csv
import re
import sys
from pathlib import Path

STOP = {"a", "an", "the", "to", "of", "or", "and", "be", "one", "something", "someone", "kind", "type", "e", "g"}


def alternatives(text: str) -> list[set[str]]:
    text = re.sub(r"\(.*?\)", " ", text.lower())
    out = []
    for part in re.split(r"[/,;]|\bor\b", text):
        words = {w.rstrip("s") if len(w) > 3 else w for w in re.findall(r"[a-z]+", part)} - STOP
        if words:
            out.append(words)
    return out


def compare(ours: str, theirs: str) -> str:
    mine, reference = alternatives(ours), alternatives(theirs)
    if not mine or not reference:
        return "check"
    best = 0.0
    for a in mine:
        for b in reference:
            best = max(best, len(a & b) / len(a | b))
    if best >= 0.5:
        return "ok"
    return "check" if best > 0 else "fix"


def main() -> int:
    if len(sys.argv) != 2:
        print(__doc__)
        return 1
    path = Path(sys.argv[1])
    rows = list(csv.DictReader(path.open(encoding="utf-8-sig")))
    fields = list(rows[0].keys()) if rows else []
    counts = {"ok": 0, "check": 0, "fix": 0}
    for row in rows:
        reference = (row.get("dictionary_gloss") or "").strip()
        if not reference or (row.get("decision") or "").strip():
            continue
        verdict = compare(row.get("english_meaning") or "", reference)
        row["suggested_decision"] = verdict
        row["suggested_english_meaning"] = reference if verdict == "fix" else ""
        counts[verdict] += 1
    with path.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)
    print(f"ok: {counts['ok']}  check: {counts['check']}  fix: {counts['fix']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
