# Kumtluang Bu Sarihna (Class VII) — Vocabulary Extraction Report

**Source file:** `/root/.claude/uploads/57b88324-b90d-5086-b0d8-d066d67c4974/484b8def-Kumtluang_Class_VII.pdf` (180 pages listed; actual content runs pages 1–166, followed by blank/no further pages)

## Pages examined

- Pages 1–17: skipped (known front matter per task instructions).
- Pages 18–166: read in ~20-page chunks, covering the entire remainder of the book (Zirlai/Lessons 1 through 29, i.e. essays, poems, folktales, a grammar unit, a drama, and a financial-literacy story).
- Pages 167–180: confirmed empty/non-existent — the PDF's actual content ends at page 166 (a `Read` request for pages 175–180 returned the same final pages 161–166), so no content was missed at the end of the book.
- Coverage was full front-to-back (beginning, middle, and end of the lesson content), not a sample — every lesson title and every explicit vocabulary/idiom/glossary box in the book was reviewed.

## Extraction method

1. Skimmed each lesson for its title/topic (for categorization) and prioritized the book's own explicit study-aid boxes — "Thu pawimawhte" (key words), "Thu har hrilh fiahna" / "Hla thu hrilh fiahna" (word/phrase glosses), and idiom lists — since these are exactly the words SCERT itself flags as the target vocabulary for the grade.
2. Also pulled clearly age-appropriate standalone nouns/verbs/adjectives from dense prose (e.g. food-chain animal names in the wildlife lesson, musical-instrument names in the "Mizo Rimawi Hmanruate" lesson, adjectives from the grammar unit) when they were clearly distinct, real words rather than sentence fragments.
3. For every selected word, I did **not** copy the textbook's own gloss or example sentences. I wrote my own short Mizo definition (`meaning_mizo`), my own English gloss, and an original example sentence (`example_mizo`) that only reuses the target word itself, per the copyright constraint. The book was used strictly to decide *which words exist and belong at this grade*, never as source text to reproduce.
4. Deduplicated by canonical form (case-insensitive) before writing the CSV.

## Output

- CSV: `/tmp/tq_content/kumtluang_class7_vocab.csv` — **150 distinct words/phrases**, all columns per the requested schema (`tq_level` = `K7`, `status` = `draft`, all review/audio fields = `pending`, `difficulty` = `7`).
- Categories used (`seed_category`): culture-instrument, culture-tradition, culture-sport, culture-object, culture-animal, culture-folklore, culture-literature, nature (wildlife/plant/food), idiom, abstract-value/action/emotion/noun/quality, grammar-term, grammar-time, adjective-color/size/quality/distance/temperature/quantity/number, school, sport, sport-action.
- `game_modes`: `picture_match` was included only for concrete, unambiguous, visually depictable items (drums, gongs, animals, colors, a basket, a ladder, corn, etc.); abstract/idiom/value/grammar words got `word_chain,spelling,word_search` only, as instructed.

## Words flagged `VERIFY` (11 total)

Two sub-reasons, both noted directly in each row's `notes` field:

**Culture/religion-sensitive (route to human culture reviewer)** — words touching Mizo folk-spirit belief, ritual/mourning custom, ethnic-identity ceremony, or family/social-taboo topics, where I judged it unsafe for me to assert a confident definitive meaning:
- `khuavang` (old Mizo nature-spirit/deity concept)
- `zângkhua` (a constellation named in Mizo folk astronomy)
- `thingtuluang` (a supernatural rooster from the Liandova-te Unau folktale)
- `puichhuah` (a mourning-related ritual-release custom mentioned in the folktale glossary — I was not fully confident of the precise ritual meaning, hence also flagged)
- `khuan hmasa` (a house-building ceremonial custom)
- `khuangchawi` (the major traditional community honor-feast/status ceremony)
- `inbuan` (traditional Mizo wrestling — a marked ethnic-cultural sport)
- `puanrin` (traditional woven cloth border pattern — material culture)
- `laiking fa neih` (idiom about a child born out of wedlock — social/family-sensitive)
- `vanduaithlâk` (term for a disabled/disadvantaged person — sensitive people-description term)
- `rilṭam` (jealousy/envy — flagged lightly since it was drawn from a sibling-rivalry folktale with family-conflict overtones)

No word was invented a definition for beyond what I could reasonably infer from clear textbook context; where the book's own gloss for a folklore/ritual term was ambiguous (e.g. `puichhuah`), I said so explicitly in the row's notes rather than asserting confidence.

## What was deliberately skipped

- Pages 1–17 (front matter), per instructions.
- All full sentences/paragraphs of the book's own essays, stories, poems, and dialogue (e.g. the "Babulon Mi Hausa Ber Chu" financial-literacy story, the "Hriatpuia" drama script, the "Liandova-te Unau" folktale, all hla/poems) — these were read for vocabulary-spotting only; no prose was transcribed or paraphrased into the output.
- Pure grammar-mechanics items with no standalone lexical value (e.g. pronoun-suffix drill particles like *nge*, *tin*, *che* usage notes in Zirlai 14; Direct/Indirect Speech drills; fill-in-the-blank exercise scaffolding) — these are exercises about Mizo grammar mechanics, not vocabulary words a flashcard deck would teach.
- A handful of very obscure/uncertain animal or plant names I could not confidently gloss even loosely (e.g. a few one-off items in the "Vau Thla" nature poem's word list) were left out rather than guessed at.
- Very basic words a Class VII student would already know from earlier grades (e.g. simple body-part or color terms already covered in lower grades) were mostly excluded in favor of more advanced/literary/abstract Class-VII-level vocabulary, per the task's request to favor genuine grade-level additions.
