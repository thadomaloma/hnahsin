# Deep Vocabulary-Extraction Pass — Kumtluang Bu Hnihna (Class II, SCERT Mizoram)

## Source
PDF: `/root/.claude/uploads/57b88324-b90d-5086-b0d8-d066d67c4974/c86c3621-kumtluang-2.pdf` — "Kumtluang Bu Hnihna", Pawl-II Mizo, SCERT Mizoram (7th Edition, 2021). Prescribed Class II Mizo textbook, all rights reserved.

## Pages examined
The entire book was read page by page with the Read tool's `pages` parameter (20-page chunks), covering:
- PDF pages 1–20, 21–26 (front matter, table of contents, Zirlai 1–3)
- PDF pages 27–46 (Zirlai 3–7)
- PDF pages 47–66 (Zirlai 8–11)
- PDF pages 67–86 (Zirlai 12–16)
- PDF pages 87–106 (Zirlai 16–18)
- PDF pages 107–117 (Zirlai 19–20, end of book content at book-page 103)
- PDF pages 118–124 (back matter: a Road Signs supplementary page in English, and the back cover — no further Mizo vocabulary)

Book-page numbering runs 1–103 across all 20 lessons (Zirlai 1–20); the PDF page offset is +14 relative to book-page numbers. All 20 lessons were read in full, including running story text (skimmed for topic only, never transcribed), lesson-end "Thu pawimawhte" word boxes, picture-labelled vocabulary pages, fill-in-the-blank vocabulary exercises, antonym/synonym matching exercises, and glossary-style definitions embedded in exercises (e.g. Zirlai 12's "Ṭhâl - khaw ro lai tak" style definitions).

## Method
1. Skimmed front matter (pages 1–14) and the table of contents to map all 20 lesson titles and page ranges.
2. Read every lesson page image, noting: (a) lesson-end word boxes ("Thu pawimawhte") not already covered by the first pass; (b) picture-labelled vocabulary sections; (c) vocabulary drawn from matching/antonym/fill-blank exercises, including a few places where the lesson itself supplied a one-line Mizo definition (used only to confirm meaning, never copied into output fields); (d) a handful of clearly glossable words recurring in story dialogue (e.g. fire/rain verbs in the "Mei hi a hlauhawm" fable, bird-care verbs in "Zovi leh sava notê").
3. Cross-checked every candidate against both exclusion lists (first-pass word-box list, exact case-sensitive match including diacritics; and the "already used elsewhere in the app" list) before including it. Two words that seemed novel on first pass (`perh`, `hmuak`) turned out to be **exact** matches to the first list and were removed after a programmatic re-check.
4. Treated words that differ from an excluded word only by diacritic as genuinely distinct **only** when the meaning is clearly different (e.g. `pâwl` = purple, vs. excluded `pawl` = group/class; `chhêm` = to burn deliberately, vs. excluded `chhem`). Treated diacritic variants that are almost certainly the same word as duplicates and skipped them (e.g. `kêl`/`kel`=goat, `âr`/`ar`=chicken, `chakâi`/`chakai`=crab, `thlâwk`/`thlawk`, `hring` in the rainbow-colours list).
5. Wrote every `meaning_mizo` and `example_mizo` from scratch — no sentence, phrase, or line from the book's stories, poems, or dialogue was copied or closely paraphrased anywhere in the output.
6. Words whose exact sense I could not pin down with full confidence (mostly single-occurrence verbs/adjectives inferred from story or exercise context, or antonym-matching exercises with no given answer key) were still included, tagged `VERIFY` with the specific reason, per instructions — except where I had genuinely no usable basis for a gloss at all, in which case I skipped the word (see "Skipped / unglossable" below).
7. Flagged one word, `sial` (mithun), as culture-sensitive since it is a domesticated bovine central to traditional Mizo feasts of merit and status display, even though its appearance here is in an Aesop-style fable about a wolf and a herd.

## Result
**91 new candidate rows** written to `/tmp/tq_deepen/kumtluang_class2_deepen.csv` (header + 91 data rows, validated to parse cleanly as CSV with 15 columns each, no duplicate `candidate_id`/`canonical_form`, no empty required fields).

Rough category breakdown: nature/weather (clouds, seasons, flood, boulder, fog…), animals (crab-bait, python, rooster, mithun…), colours (orange, indigo, gold, purple, dark), fire/rain verbs from the wildfire fable (to burn, to catch fire, to spread, to pour, to spray), bird-care verbs from the caged-birds story (to nurture, to chirp happily), emotion/character adjectives (joyful, stubborn, diligent, ashamed, hopeless, generous, careless), a small set of Psalm-23-style pastoral vocabulary (shepherd, pasture, staff, mercy, righteousness, table), and everyday nouns/verbs (banana, shirt, cup, car, helicopter, to believe, to listen, to open, near/far, song).

## VERIFY list (36 words) — reason summarized per word in each row's `notes` column
`zâr, phu, nawinâwk, ting, serthlum, chhêm, phuh, ruai, nawm, khawrh, puak, kuhmûm, tuihâwk, khiang, dai, thlasik, hmanhmawh, dum, dim, veilam, ît, chhep, hreuh, hlobet, bawhtîr, felna, tiang, ngilneihna, inlâr, ûmpha, tuihâl, duhâm, hnai, khâr, hawng` (plus `sial`, which also carries the culture-sensitive flag below).

Most of these are single-occurrence words inferred from a story context (e.g. a bird panting, a rock python mentioned in passing, a table set in a Psalm-23 paraphrase) or from antonym/fill-blank exercises where the book itself never states the answer. I gave each my best-confidence gloss but flagged it for a fluent speaker to confirm before it goes live.

## Culture-sensitive flag (1 word)
- **`sial`** (mithun) — a large domesticated bovine that is central to traditional Mizo feasts of merit (khuangchawi) and status. It appears here only inside an Aesop-style fable ("Sazâltepa leh Bâkvawmtepu", the wolf-who-cried-wolf story) as ordinary livestock, but because ownership/gifting of mithun carries real cultural weight, I flagged it per the review rules rather than deciding myself. Notes column: `VERIFY culture-sensitive: sial (mithun) is a domesticated bovine central to traditional Mizo feasts of merit and status; route to human culture reviewer.`

No words touching chieftainship, pasaltha/warrior culture, khuavang/spirit-folklore, or death/mourning customs appeared anywhere in this book — its content is entirely everyday life, nature, Aesop-style fables, a Bible story (King Solomon), a Psalm-23 paraphrase, and one biographical story about the athlete Glen Cunningham. The Solomon story does involve a king ("Lal") and royal succession, but this is Biblical/Old-Testament content rather than traditional Mizo chieftainship, so I did not apply the chieftainship flag to it.

## Skipped / deliberately not included
- **Words removed after cross-check**: `perh` and `hmuak` were initially drafted as new but turned out to be exact (case-sensitive) matches already in the first-pass exclusion list; removed.
- **Diacritic-variant duplicates of already-excluded words**, judged to be the same underlying word and skipped to avoid redundant catalogue entries: `kêl` (goat, dup. of excluded `kel`), `âr` (chicken, dup. of excluded `ar`), `chakâi` (crab, dup. of excluded `chakai`), `hring` (in the rainbow-colours exercise, dup. of excluded `hring`), `thlâwk` (dup. of excluded `thlawk`).
- **`thukru`** — dropped; on review it is an exact match to the already-excluded `thukru`.
- **A four-word weather fill-blank set** (`dul`, `reuh`, `ṭiak`, `pui` from a Zirlai 10 exercise) — the exercise gives no answer key and I could not confidently reconstruct which word fills which blank or what each means, so per instructions ("skip if you truly cannot gloss it at all") these were omitted rather than guessed.
- **`fû`** (a picture-vocabulary item on p.52) — the picture (a plain stick/cane) did not match my confidence in any single Mizo gloss (body hair? cane? quill?); skipped as unglossable rather than guessed.
- **Jumbled-letter animal puzzles** (e.g. "KEISA", "AWNGZTE", "IAS" on p.41) and several picture-matching exercises with blank answer lines (e.g. the animal-naming exercises on pp.14, 21, 46, 63, 90, 97) were **not** mined as new vocabulary, because the book itself never states the intended answer word — only first-pass words or already-excluded/duplicate words could be inferred with confidence from these pages.
- Running story/poem text throughout was skimmed for topic only and never transcribed or paraphrased into any output field.

## Files
- `/tmp/tq_deepen/kumtluang_class2_deepen.csv` — 91 vocabulary rows, full schema as specified.
- `/tmp/tq_deepen/kumtluang_class2_deepen_report.md` — this report.
