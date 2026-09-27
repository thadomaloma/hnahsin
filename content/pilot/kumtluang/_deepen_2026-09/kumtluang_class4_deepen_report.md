# Kumtluang Bu Lina (Class IV) — Deep Vocabulary Pass Report

## Source
`f08cc3ce-kumtluang-4.pdf` — SCERT Mizoram, Class IV Mizo textbook, 122 pages total (front matter, 20 lessons across pages 1–106 of the printed numbering, and back matter including road-sign and Childline pages). Read in full via the Read tool in six ≤20-page batches covering PDF pages 1–20, 21–40, 41–60, 61–80, 81–100/87–106, and 103–122, i.e. every page of the book was viewed.

## Method
1. Skimmed pages 1–14 (front matter, DIKSHA instructions, copyright notice, committee lists, syllabus objectives, table of contents) — no vocabulary extracted from this section.
2. Went lesson by lesson (Zirlai 1–20) looking specifically at:
   - Lesson-end "Thu pawimawhte" word boxes (the first pass's target) — each box was cross-checked word-by-word against the supplied exclude list rather than skipped wholesale, because spot checks showed the exclude list does **not** always cover every word in a labelled box (e.g. most of Lesson 18's box and several of Lesson 9's box words were still available). Any box word not on the exclude list was added.
   - Picture-labelled and categorisation exercises (e.g. the fish/bird sorting exercise p.34, the "Chunglêng/Hnuailêng" sky-vs-ground animal sort p.92, the animal-call matching exercise p.80–81, the fruit-matching exercise p.76, the good-deed/bad-deed sorting exercise p.68).
   - Antonym- and synonym-matching exercises (pp.37, 42–43, 69, 99) — a rich source of adjective pairs not covered by word boxes.
   - "Hla thu hrilh fiahna" verse-glossary sections, which paraphrase poem vocabulary in plain Mizo (Lesson 10, p.46) — a format distinct from the labelled word boxes and evidently missed by the first pass.
   - Dialogue stage directions in the play-style Lesson 14 ("Felate chhung"), which are rich in manner/emotion adverbs (e.g. *huam*, *thatho*, *nui*, *dim*) not listed in any word box.
   - Narrative text describing named bird and fish species used in traditional hunting/fishing (Lessons 8, 9, 18) and traditional attire (Lesson 20).
3. Running text/story prose itself was only skimmed for topic and never transcribed; no sentence, stanza, or story line from the book was copied into any field. Every `meaning_mizo` and `example_mizo` was freshly composed.
4. Every candidate canonical form was checked against both supplied exclude lists (exact match, case- and diacritic-sensitive) before inclusion; a small script (`/tmp/tq_deepen/build_csv_class4_v2.py`, kept only in this session's directory) generated the CSV and a duplicate/collision check confirmed zero overlaps with either exclude list and zero internal duplicate IDs or canonical forms.

## Result
**128 new candidate words** written to `/tmp/tq_deepen/kumtluang_class4_deepen.csv`.

Rough breakdown by source type:
- Dialogue/emotion & manner words (Lesson 14, incl. its word box checked individually): 20
- Good-deed/bad-deed behaviour vocabulary (p.68 exercise): 6
- Antonym/opposite-pair adjectives (pp.37, 69): 17
- Lesson 10 poem glossary ("Hla thu hrilh fiahna"): 5
- Lesson 19 flood-poem vocabulary list: 6
- "Dik lo / Dik" correct-usage table (Lesson 2), correct-form words only: 7
- Miscellaneous word-box words that survived exact-match checking (Lessons 3, 6, 8, 9, 11, 12, 15, 18, 1, 16): 27
- Wild dove/pigeon and other bird species named in hunting narratives and the sky/ground animal-sort exercise: 21
- Other animals from the animal-call exercise and the Chunglêng/Hnuailêng sort (pig, goat, cicada, owl, vulture, porcupine, barking deer, jungle fowl, etc.): 15
- Fruit-matching exercise (guava, rose apple, "round", "itchy"): 4
- Traditional clothing term from Lesson 20 narrative (not in its word box): 1

## VERIFY list (uncertain glosses, flagged in each row's notes)
Words where the book gives no plain-language gloss and the meaning was inferred from context, so a language reviewer should double-check before publishing:
- `inthlahrung`, `phûrpui`, `nawi`, `ṭiauvut` (Lesson 14/19 word lists, no gloss given)
- `nghafuan`, `hnianghnâr` (Lesson 8 hunting narrative)
- `zângruh`, `dawihzep` (Lesson 18 fable — vivid but uncommon words)
- `theiherâwt` (fruit-matching exercise — local fruit, exact common English name uncertain)
- All 21 bird-species words (`bâwng`, `nghatun`, `nghadawl`, `nghahrah`, `nghavawk`, `nghavâng`, `ngharûl`, `lengphâr`, `chhâwlhring`, `chinrâng`, `kireuh`, `tawllâwt`, `varihâw`, `bullut`, `chhuangtuar`, `vapual`, `chêngkawl`, `changpât`, `pit`, `zawhtê`, `savawm`) — confidently identified as named wild bird species from hunting/fishing narratives and a sky-vs-ground categorisation exercise, but exact common English species names could not be confirmed.
- `sihal`, `sanghar`, `sazu`, `sazuk`, `sanghal` — animal names from an animal-call/animal-sort exercise, glossed as barking deer / porcupine by best inference; `sanghar` and `sazu` in particular may denote the same animal, and `sihal`/`sazuk`/`sanghal` may overlap — flagged for a language reviewer to disambiguate.

## Culture-sensitive flags (routed to human culture reviewer, per instructions)
- **`thlaichhiah`** (Lesson 11) — the Mim Kut custom of laying out food for deceased family members at their graves. Death/mourning/ancestor-remembrance custom.
- **`chhâwng hnawh`** (Lesson 11) — a traditional egg-tapping children's game played during the Pawl Kut festival. Ceremonial/traditional festival practice.
- **`râl`** (Lesson 9, "Pa chak – Saizahâwla") — war/battle/armed conflict between villages, mentioned in connection with a legendary strongman/pasaltha-like hunter figure. Traditional warrior-culture context.
- **`kawrtawnghâk`** (Lesson 20, "Hmasang silhfên") — a traditional style of wrapping cloth worn by men before woven garments became common. Traditional clothing/craft practice.

## Deliberately skipped / not included
- All exact matches to the two supplied exclude lists (checked programmatically — zero collisions confirmed).
- Purely grammatical/orthographic material: punctuation lessons (Zirlai 5), letter-writing format instructions (Zirlai 17), the "Dik lo/Dik" table's near-duplicate suffixed forms of already-excluded roots (e.g. "khawngaihthlak" vs. the excluded "khawngaihthlakawm"), and organisation-name abbreviations (YMA, MZP, etc.).
- Reduplicated onomatopoeic eating-sound words from the Lesson 6 word box (*them them*, *melh melh*, *diat diat*, *cherh cherh*) — kept the clearer root words (*tuihnâi*, *biru*, *thâwm*) but omitted these four as too imprecise to gloss confidently as distinct headwords.
- Several very obscure single-appearance animal names from the sky/ground sort exercise (*choâk*, *rûlngân*, *ngâu*, *chawngzawng*) — could not be confidently glossed even generically from the surrounding text, so were left out per the "skip if you truly cannot gloss it" instruction.
- Fruit-matching-exercise items *khawkherh*, *balhla*, *chengkek*, *theipalingkawh* — too uncertain to gloss with confidence (kept *sâpthei* and *theiherâwt*, which had clearer contextual support).
- Real people's names throughout (Rema, Diki, Zova, Fela, Sangi, committee members, etc.) and any Bible/Scripture names — none were treated as vocabulary.
- Whole poems/stories were never transcribed; only individual headwords were extracted, each given an original Mizo definition and example sentence written from scratch.

## Files
- `/tmp/tq_deepen/kumtluang_class4_deepen.csv` — 128 vocabulary rows, header included.
- `/tmp/tq_deepen/kumtluang_class4_deepen_report.md` — this report.
