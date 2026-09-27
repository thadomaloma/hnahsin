# Kumtluang-derived vocabulary dataset (2026-09-16)

Source: the official Government of Mizoram (SCERT) "Kumtluang" Class I-VII
textbook series, uploaded by the project owner. Extracted by 7 parallel
research agents (one per grade), each working from the actual scanned PDF
pages, using the book only to identify *which words exist and are
grade-appropriate* -- every definition and example sentence in these CSVs
was independently written, never copied or paraphrased from the textbook's
own prose/stories/poems. See COPYRIGHT NOTE below.

## Files

- `kumtluang_vocab_master_deduped.csv` -- **1470 distinct words**, one row
  per word, `tq_level` set to the LOWEST grade it appeared in (K1=Class I
  .. K7=Class VII) when an agent independently re-surfaced the same basic
  word in more than one grade's book (normal -- curricula reinforce words).
- `kumtluang_vocab_all_with_repeats.csv` -- all 1642 rows before
  dedup, if you want to see every grade a word showed up in.
- `by_class/kumtluang_classN_vocab.csv` -- each grade's raw output
  (original first-pass sample + the 2026-09-17/18 deeper second pass,
  appended).
- `reports/kumtluang_classN_report.md` -- each agent's method (first
  pass), page ranges actually examined, and reasoning for anything it
  flagged or skipped. Second-pass (deeper extraction) reports live at
  `_deepen_2026-09/kumtluang_classN_deepen_report.md`.

## Word count by grade (after dedup, lowest-grade-wins)

First-pass sample (2026-09-16) + deeper second pass (2026-09-17/18, one
targeted full re-read per grade, net-new words only after dropping exact
duplicates of already-catalogued words -- 608 net-new distinct words added
to this file; the deeper pass's Vartian source lives in its own
`content/pilot/vartian_candidates.csv`, not folded into this Kumtluang-only
master file):

| Grade | Official curriculum target | First pass | + Deeper pass | Total |
|---|---|---|---|---|
| Class I (K1)   | ~800  | 112 | +56  | 168 |
| Class II (K2)  | ~1000 | 108 | +71  | 205 |
| Class III (K3) | ~1300 | 141 | +68  | 224 |
| Class IV (K4)  | ~1500 | 105 | +101 | 236 |
| Class V (K5)   | ~2000 (confirmed from the book's own objectives page) | 158 | +80  | 248 |
| Class VI (K6)  | ~2500 | 126 | +60  | 209 |
| Class VII (K7) | ~3000 | 112 | +202 | 352 |

Even after the deeper pass this remains a **sample**, not the complete
official word list -- the books are scanned image PDFs with no text
layer, so extraction is still a careful visual read rather than an OCR
transcription of every one of the ~800-3000 words per grade. The deeper
pass re-read each full book (not just lesson-end word boxes) and was
explicitly told to skip anything already catalogued, which is why the
net-new counts above are additions, not replacements.

## Cross-check against the existing pilot dataset

862 distinct Kumtluang words vs. the existing `pilot_candidates.csv` +
`diaspora_expansion_candidates.csv` (182 distinct words combined):
- **86 words overlap** -- independently confirmed as legitimate,
  grade-appropriate vocabulary by two separate processes. Good sanity check.
- **776 words are net-new** additions this dataset brings.

## `tq_level` -- action needed before merging into the live catalog

This dataset uses placeholder tags `K1`-`K7` (Kumtluang Class I-VII), which
do **NOT** match the existing in-app `tq_level` convention seen in
`pilot_candidates.csv` / `diaspora_expansion_candidates.csv`, which only
goes up to `TQ0`-`TQ3` (4 levels, hand-curated, not grade-anchored).

Before this feeds `controller.wordCatalog` / `chainVocabulary`, a decision
is needed on how to reconcile the two:
- **Option A** -- adopt `K1..K7` as the definitive 7-level ladder going
  forward (rename to `TQ1`..`TQ7` or similar) and remap the existing 182
  TQ0-3 words onto it by re-checking which grade each actually belongs at.
- **Option B** -- keep TQ0-3 as the near-term shipping levels (map roughly
  K1+K2 -> TQ0, K3 -> TQ1, K4 -> TQ2, K5 -> TQ3) and hold K6/K7 (abstract,
  more advanced) as a `TQ4`/`TQ5` future expansion once the app has more
  content depth.
- **Option C** -- something else the project owner prefers.

## COPYRIGHT NOTE -- read before publishing/shipping any of this

The Kumtluang textbooks are (c) SCERT Mizoram, "ALL RIGHTS RESERVED", and
most copies carry a "not to be republished" watermark. This dataset only
ever contains individual words plus originally-written meanings/examples
-- never the book's own sentences, stories, or poems. That is the safe
boundary; it should stay that way through every future edit of these files.

## Review flags

333 of the 1470 rows carry a `VERIFY:` note (uncertain spelling/sense, or
sense inferred from context rather than explicitly defined in the book).
109 of those are specifically flagged `culture-sensitive` (traditional
chieftainship, warrior/pasaltha culture, khuavang spirit-folklore,
ceremonial/craft terms, wrestling and zawlbûk customs, marriage/festival
customs, and a number of death/mourning-related terms) and should route to
the same human culture reviewer this project has already been deferring
words like "Mizo," "bekang," "sawhchiar," and "puan" to -- not resolved by
AI guesswork. Filter `notes` for `VERIFY` to find all of them.

**One item needs the reviewer's attention before anything else**: the
Class VII deeper pass surfaced `ral lu aih` (candidate roughly
`word.ralluaih`), a historical reference to headhunting/war-trophy
celebration custom -- flagged by the extracting agent itself as "the
single most sensitive item found." It is included here only as a
catalogued, VERIFY-flagged, unreviewed candidate (draft status, not
imported into gameplay) exactly like every other culture-sensitive row --
it is not treated as approved or game-ready in any way -- but given its
sensitivity it is worth the reviewer looking at first, and worth a
conscious decision (include with careful framing / exclude entirely)
rather than defaulting to whatever the general review queue order happens
to produce.

Separately, 55 of the 1470 rows carry a `VERIFY possible duplicate` or
`VERIFY spelling-variant` note -- these were added automatically during
the 2026-09-17/18 merge, when a new word matched an existing catalogued
word except for a diacritic (e.g. new `lam` vs. existing `lâm`, new `zar`
vs. existing `zâr`). Diacritics can distinguish genuinely different Mizo
words, so these were **not** auto-merged or auto-dropped -- only exact
(case-insensitive) spelling matches to already-catalogued words were
dropped as true duplicates (158 of the original 876 candidates from the
deeper pass). The 67 near-matches need a language reviewer's eye to say
whether each pair is the same word (drop/merge) or genuinely distinct
(keep both). See `_deepen_2026-09/verify_dedup_flags.csv` for the full
list with both forms side by side.
