# Kumtluang Class IV (Bu Lina) — Vocabulary Extraction Report

**Source PDF:** `6e7d4fab-kumtluang-4.pdf` (122 pages), Government of Mizoram / SCERT Kumtluang series, Class IV.
**Output CSV:** `/tmp/tq_content/kumtluang_class4_vocab.csv` — 135 distinct vocabulary rows.
**Copyright note:** The book is © SCERT Mizoram, "not to be republished." No sentences, story text, poem lines, or exercise text were transcribed or paraphrased from the book anywhere in the CSV. The book was used only to identify *which words exist and are age-appropriate for Class IV*. Every `meaning_mizo`, `english_gloss`, and `example_mizo` was independently written by the assistant.

## Page ranges examined

Pages 1–13 were skipped per instructions (known front matter). The following ranges were read in full (text + illustrations) via the PDF tool's page-range reader:

- 14–33 (Zirlai 1–5: flower poem, word-usage/dialect corrections, "Lehkhabu" reading-culture lesson, abbreviations lesson, punctuation lesson)
- 34–53 (Zirlai 6–11: village mouse/city mouse fable, boat/sea poem, fishing story "Pafa lên dêng," strongman legend "Pa chak – Saizahâwla," bird poem "Savate," Kût/festivals dialogue)
- 54–73 (continuation of Zirlai 9–11 exercises, Zirlai 12–15: proverbs/values poem "Thufingte," Mizo-identity poem "Mizo kan nih kan lawm e," family road-safety dialogue "Fela-te chhung," buried-treasure folktale "Ro phûm rûk")
- 74–93 (continuation of Zirlai 15, Zirlai 16–18: gibbon song "Hâudâng lêng," letter-writing lesson "Lehkha i thawn ang u," animal fable "Chunglêng leh hnuailêng indo")
- 94–113 (continuation of Zirlai 18 exercises, Zirlai 19–20: moral/nature poem "Tui mal far tê tê chu," traditional-clothing history lesson "Hmasang silhfên")
- 100–119 (re-confirmed overlap and covered the remainder of Zirlai 19–20, zoo-scene sentence exercise, road-signs page, and back matter, which ends the book's content around page 107; pages 108–122 are back cover / Childline notice / blank matter with no vocabulary content)

This gives coverage across the entire book (beginning, middle, and end), all 20 lessons (Zirlai 1–20).

## Extraction method

1. Read each page image, noting lesson titles/themes and any explicit "Thu pawimawhte" (key vocabulary) call-out boxes the book itself provides at the end of most lessons — these were treated as a strong signal of which words the book considers Class IV-level.
2. Scanned exercise sections (fill-in-the-blank word banks, matching exercises, word-search puzzles) for additional named vocabulary items.
3. For every candidate word, independently composed a fresh Mizo-language definition (`meaning_mizo`), English gloss, and an original example sentence — never reusing the book's own sentences, story lines, or poem text.
4. Deduplicated within the list; favored words that go beyond likely Class I–III basics (e.g., kept `tûkthuan`/`chawchhun`/`zanriah` as a taught distinction over generic "chaw ei," kept `khawngaihthlakawm`, `suangtuahna`, `inngaihtlawmna` as clearly advanced compounds) and dropped overly basic items the book itself uses only as background words (e.g., plain `sikul`, `chhiar`, `ziak`, `thian`).
5. Assigned `game_modes` per word: `picture_match` was added only for concrete, visually unambiguous nouns (animals, plants, clothing items, places, foods, objects); abstract nouns, verbs, and adjectives got `word_chain,spelling,word_search` only.

## Counts

- **135** distinct words extracted (within the requested 120–180 range).
- Category spread: verbs (24), adjectives (19), abstract (18), animals (15), geography (12), school/literacy (11), nature (8), clothing/traditional (9), community (6), festival/culture (6), food (4), folktale/legend (3).

## Words flagged VERIFY

- `rûl` — general word for "snake"; included alongside `rûlpui` (large snake/python) as a plausible general/specific pair, but the precise scope distinction wasn't confirmed against a dictionary.
- `thahrui` — glossed as "sinew/tendon (source of physical strength)" based on context in the "Pa chak – Saizahâwla" strongman legend; the literal anatomical meaning could not be independently confirmed.
- `hmarâm` — glossed generically as "facial or body tattoo/decoration," based on one background sentence in the traditional-clothing history lesson; kept deliberately vague/factual rather than descriptive of any specific practice.

## Content deliberately skipped or handled cautiously

- **Zirlai 13, "Mizo kan nih kan lawm e"** — an identity/patriotic poem about Mizo ethnic pride and heritage. Per the project's existing practice of deferring identity-loaded terms (e.g., the word "Mizo" itself) to a human culture reviewer rather than guessing at framing, no vocabulary was pulled from this lesson's poem text itself. (Neutral, factual festival names like `kût`, `chapchâr kût`, `mîm kût`, `pawl kût` were drawn from the separate Kût lesson instead, since those are simply named cultural events, not identity assertions.)
- **`siamtu` ("creator/maker"), `ralpui` ("enemy army"), `lentupui` (a legendary giant serpent)** — all appeared in the "Savate" bird poem, which reads as having devotional/hymn-like framing (a common register in Mizo nature poetry). These were left out rather than risk asserting a specific religious or mythological framing without a human reviewer's judgment call.
- **`hnam` ("nation/people/tribe")** and similar ethnonym-adjacent words from the identity poem were likewise not extracted.
- General difficult-to-verify bird-species names appearing only in a word-search puzzle (e.g., `nghavâng`, `chhuangtuar`, `pengleng`, `tawllâwt`, `varihâw`) were left out because their precise English identification could not be confirmed with confidence — better to omit than guess incorrectly on species identity.
- The `zawlbûk` (traditional bachelors' dormitory) and `sechal` (mithun) entries are described only in plain, factual, encyclopedia-style terms (what the institution/animal is), not via any narrative or cultural-value claim from the book, since these carry real cultural weight.

## Output files

- `/tmp/tq_content/kumtluang_class4_vocab.csv` — 135 rows, columns: `candidate_id, canonical_form, seed_category, tq_level, status, language_review, learning_review, audio_status, notes, english_gloss, meaning_mizo, example_mizo, difficulty, game_modes, emoji`.
- `/tmp/tq_content/kumtluang_class4_report.md` — this report.
