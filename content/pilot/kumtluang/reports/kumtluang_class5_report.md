# Kumtluang Bu Ngana (Class V) — Vocabulary Extraction Report

**Source:** Kumtluang Bu Ngana, Class V, SCERT Mizoram (© SCERT Mizoram, "not to be republished" watermark present throughout).
**Output:** `/tmp/tq_content/kumtluang_class5_vocab.csv` (168 rows)

## Page ranges examined

- Pages 1–16ish: skipped per instructions (known front matter: title, copyright, committee lists, foreword, teaching guidelines).
- Pages 13–20 (PDF): re-read to locate and confirm the Class V curriculum-objectives block and the front-matter tail (Constitution of India page, Table of Contents "A CHHUNG THU").
- Pages 20/1 through 161/143 (PDF/book numbering; offset = PDF page − 19 for the first section, settling to PDF − 18 from Zirlai 1 onward — the book's own printed page numbers were used as the reference): all 26 lessons (Zirlai 1–26) read page-by-page across six large batches, examining both the running lesson text (skimmed for topic/theme only) and, especially, each lesson's own **"Thu pawimawhte" (Important Words)** end-of-lesson vocabulary boxes, which the textbook itself provides — this was the primary and most reliable extraction source.
- Pages 162–164 (PDF): back matter (Childline/road-sign reference images, SCERT back cover) — no further lesson content; confirmed the book's content ends at printed page 143 (Zirlai 26).
- One redundant re-read occurred (PDF 123–142 overlapped with the tail of a prior 121–140 batch) due to a page-offset miscalculation; no content was lost, just one duplicated batch.

## Class V vocabulary target (side task)

Found on the Class-V-specific objectives block, section **7. Thumal hriat (Vocabulary)**, immediately following the Grammar and "Mizo hnam ro hlu leh ziarâng" sections and just before "TEHNA (EVALUATION)":

> **"Mizo tawng thumal 2000 tal an hria ang a, an hmang thiam ang."**

**Class V target: approximately 2,000 words.** This is consistent with the stated progression pattern (Class I ≈800 → II ≈1000 → III ≈1300 → IV ≈1500 → **V ≈2000** → VI ≈2500 → VII ≈3000), confirming Class V's front matter runs the standard curriculum-objectives block (listening/speaking/reading/writing/grammar/culture/vocabulary sub-sections) shared in structure with the other grade books.

## Extraction method

1. Skimmed lesson titles and topics across all 26 lessons (a mix of hymns/poems, moral stories, a historical biography, a folk legend, a traffic-safety lesson, a grammar/punctuation/parts-of-speech unit, an idioms unit, and a Mizo-traditional-dress unit).
2. Prioritized each lesson's own **"Thu pawimawhte"** boxed word list — these are single words or short phrases the textbook itself flags as the lesson's key vocabulary, which is both the most curriculum-faithful source and the safest from a copyright standpoint (a word list, not prose).
3. For Zirlai 14 ("Ṭawng Upa" — a full lesson of Mizo idioms with the book's own definitions and example sentences), extracted the **idiom headwords only** and wrote entirely original definitions/examples — did not reuse the book's definition wording or example sentences.
4. For Zirlai 24 ("Mizo Incheina" — traditional dress), extracted the named garment/ornament terms (puan types, ornaments) shown as captioned images/vocabulary, which is well suited to `picture_match` and is inherently factual/cultural nomenclature.
5. For lessons without an explicit word box (e.g. Zirlai 2, 5, 10, 13, 15, 17, 20, 22, 25, 26 — largely grammar drills, dialogue/drama scripts, or dense narrative), pulled a smaller number of clearly useful, grade-appropriate standalone words from context (glossed independently, never copying the book's sentences).
6. Every `meaning_mizo` and `example_mizo` was composed fresh; none are transcriptions or close paraphrases of the book's own sentences. Only the one permitted curriculum-target sentence above is quoted from the book.

## Results

- **168 distinct words/idioms/phrases extracted**, all Class V–level (favoring words that go beyond Class I–IV basics: abstract values vocabulary, legend/folklore terms, historical/civic vocabulary, idioms, and Mizo traditional-dress nomenclature).
- Categories used (`seed_category`): `values`, `nature`, `legend`, `community`, `verbs`, `adjectives`, `idiom`, `traditional_dress`.
- `game_modes`: `picture_match` included only for concrete, visually unambiguous items (birds, flowers, plants, tools, traditional garments, clear physical actions); omitted for abstract nouns, idioms, and multi-word phrases where a single clean image would be ambiguous or misleading.
- `difficulty`: set to `5` for all rows (Class V), `tq_level`: `K5` placeholder as instructed.

## Words flagged VERIFY (5 total)

- **thlit fimsak** — gloss ("to trim/harvest carefully") inferred from the Zirlai 8 forest-conservation passage; exact idiomatic nuance uncertain.
- **chhe rup** — gloss ("to become degraded/depleted") inferred contextually from the same environmental passage.
- **tichereu** — gloss ("to make barren/lay waste") inferred, not explicitly defined in the book.
- **vani-an** — a betrothal/marriage-vow term from the Zirlai 9 folktale (Raldâwna leh Tumchhingi); gloss inferred from narrative context, worth a native-speaker check for precise cultural usage.
- **mang khawh** — gloss ("to perceive/sense deeply, as in a dream") inferred from limited context; nuance uncertain.

All other 163 words were glossed with reasonable confidence based on how they were used in context (definitions given directly in the book's own "Thu pawimawhte" boxes for many of them, or clear narrative usage for the rest).

## Deliberately skipped / out of scope

- All grammar-drill/exercise content (fill-in-the-blank sentences, comprehension questions, punctuation drills, Parts-of-Speech unit content) — these are pedagogical scaffolding, not vocabulary-list material, and reusing their sentences would risk reproducing book text.
- Full prose of stories/legends/poems — read only for context/theme, never transcribed.
- Names of real historical/biblical/mythological figures used only as story characters (e.g., Kairûma, Rimenhawihi, Zopari, Patechaka) — proper nouns, not general vocabulary, so excluded from the word list even though the lessons themselves were read.
- A handful of context-dependent words too ambiguous to gloss confidently outside their story were dropped rather than force-flagged for VERIFY (e.g., "sairawkherh", "saisir", "kel kawl" from Zirlai 3/9 — meanings weren't recoverable with enough confidence even as a flagged guess).

## Files

- `/tmp/tq_content/kumtluang_class5_vocab.csv` — 168-row vocabulary CSV, matching the required schema.
- `/tmp/tq_content/build_csv_class5.py` — generation script (kept for reproducibility/audit).
