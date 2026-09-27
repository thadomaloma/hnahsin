# Kumtluang Bu Thumna (Class III) — Vocabulary Extraction Report

## Source
`Kumtluang Bu Thumna` (Class III reader), © State Council of Educational
Research and Training (SCERT), Mizoram — All Rights Reserved. 134-page PDF.

## Pages examined
- Skipped pages 1–14 (front matter: title, copyright, committee lists,
  foreword, teaching guidelines, curriculum objectives) as instructed.
- Read pages 15–134 in full (six batches of ~20 pages: 15–34, 35–54,
  55–74, 75–94, 95–114, 115–134), covering every lesson from **Zirlai 1**
  through **Zirlai 20**, plus the closing exercise/appendix pages (road
  signs, Childline notice, back cover). Coverage spans the beginning,
  middle, and end of the book, with no gaps.
- The book's actual instructional content ends around printed page 117;
  pages 118–134 are a road-signs reference sheet and blank/back-cover
  pages with no extractable vocabulary.

## Extraction method
1. Read each 20-page batch as images and identified, lesson by lesson,
   (a) the book's own end-of-lesson **"Thu pawimawhte" (key words)**
   boxes — these were the highest-value, most reliable source, since the
   textbook itself flags the words it wants a Class III student to learn;
   (b) concrete nouns/verbs appearing in matching exercises, fill-in-the-
   blank drills, picture-labeling exercises, and word-search puzzles; and
   (c) a smaller number of clearly age-appropriate words from the lesson
   prose itself (e.g. body parts, seasons, animals, school life).
2. For every candidate word I wrote an entirely original one-sentence
   Mizo definition (`meaning_mizo`), an original English gloss
   (`english_gloss`), and an original example sentence (`example_mizo`)
   that I composed myself — none of these are copied or lightly reworded
   from the textbook's own sentences, story text, poems, or exercises.
   The book was used strictly to answer "does this word exist and is it
   Class-III-appropriate," never as a source of text to reproduce.
3. Deduplicated by lowercased `canonical_form` (0 duplicates in the final
   file). Categorized each word into a short seed_category (animals,
   nature, seasons, calendar, festivals, body, family, school, household,
   community, transport, clothing, verbs, adjectives, emotions, manners,
   values, abstract, history, food, crafts, health).
4. `game_modes` includes `picture_match` only for concrete, unambiguous,
   visually depictable nouns (animals, body parts, school objects,
   emotions with a clear facial expression, etc.). Abstract nouns,
   values (e.g. `finna`, `taihmâk`), verbs of internal state, and month
   names were given `word_chain,spelling,word_search` only.

## Word count
**156 distinct words** extracted to
`/tmp/tq_content/kumtluang_class3_vocab.csv`, favoring words that read as
genuine Class-III-level additions (e.g. `hnatlang`, `taihmâk`, `zakzum`,
`fianrial`, seasonal/calendar vocabulary, folktale-derived nouns) over
content that would already be covered in Class I/II (very basic color,
number, or greeting words were intentionally left out).

Rough category breakdown: animals/nature ~28, seasons & the 12
traditional Mizo calendar-month names ~16, festivals ~3, body/family ~9,
school ~9, household/crafts/transport/clothing ~15, verbs ~24,
adjectives/emotions/manners/values/abstract ~48, history/traditional
tools ~3, food ~4.

## Words flagged VERIFY (12 rows)
These are flagged in the `notes` column with `VERIFY:` because either
(a) the exact species/object the textbook's illustration depicts
couldn't be pinned down with full confidence (e.g. `theitê`, `nikir`,
`dingdi`-type flower names were ultimately left out rather than guessed
further), or (b) the word names a specific traditional custom/object
whose precise scope I simplified for a general-audience definition:
`nikir`, `khuangchawi` (festival name), `sawhchiar`, `phubâ`,
`khalhna`, `khapna`, `pasaltha`, `tawktarh`. A reviewer with deeper
Mizoram cultural/agricultural knowledge should double-check these before
they leave draft status.

## Content deliberately skipped or handled cautiously
- **Nuchhimi thawnthu (Zirlai 13)** is a well-known but fairly dark Mizo
  folktale involving a cruel stepmother figure, a supernatural
  antagonist ("Hmuichukchurudûninu"), and violence toward a child. I
  extracted only neutral household/nature words from this lesson
  (comb, attic, granary, main road, "sad," "peaceful," etc.) and did not
  narrate, summarize, or reproduce any of the story's plot or dialogue.
- **Chawngbawla (Zirlai 10)**, a folk-hero hunting story, contains a
  headhunting/trophy-taking reference ("lu zuar"); I excluded that term
  and any words tied to taking human trophies. I kept a handful of
  neutral traditional-tool words (gun, dao, spear, trap) as historical
  vocabulary only, and gave them no `picture_match` mode and no weapon
  emoji, to keep the game presentation low-key for children.
- **Religious/hymn lessons** (Zirlai 7 "Aw Pathian Nang Lalber I Ni,"
  Zirlai 9 "Nihlawhna Thu," and the devotional passages inside Zirlai 20)
  were treated as a vocabulary source only for a few generic words
  (e.g. `remna`, `muanna`, `hmangaihna`); I did not lift any of the
  hymn/prayer language itself, and avoided extracting proper religious
  nouns (Pathian, Isua, Lalpa, etc.) as game vocabulary, consistent with
  keeping the word list secular and game-appropriate.
- **Ethnic/identity terms**: following the same approach described for
  this project (deferring a word like "Mizo" itself to a human culture
  reviewer rather than guessing), I did not add "Mizo" or other
  ethnonyms as standalone vocabulary entries, even though the word
  appears throughout the book (e.g. "Mizo Hun Puite," "Mizoram").
- **Traditional festival names** (`khuangchawi`, `sawhchiar`, the twelve
  Mizo calendar month names) were kept as vocabulary since the textbook
  itself teaches them explicitly as a curriculum unit (a Mizo-to-English
  month table), but I flagged the festival-specific ones for human
  cultural review rather than asserting deep ritual detail.
- I did not transcribe or paraphrase any of the book's stories, poems,
  or dialogues as running text anywhere in the deliverables — only
  individual words, plus my own original one-line definitions and
  example sentences.

## Files produced
- `/tmp/tq_content/kumtluang_class3_vocab.csv` — 156-row vocabulary CSV,
  matching the exact 15-column project schema.
- `/tmp/tq_content/kumtluang_class3_report.md` — this report.
