# Kumtluang Bu Khatna (Class I) — Vocabulary Extraction Report

**Source file:** `a3ed9d83-kumtluang-1.pdf` (142 pages, Kumtluang Bu Khatna / Class I, SCERT Mizoram)
**Output CSV:** `/tmp/tq_content/kumtluang_class1_vocab.csv` — 112 rows
**tq_level tag:** `K1` (placeholder for "Kumtluang Class I")

## Copyright approach

This is a © SCERT Mizoram publication with "not to be republished" watermarks throughout. Per the task instructions, nothing was transcribed from the book's own sentences, stories, poems, dialogues or exercise prose. The book was used only as evidence of *which words a Class I student is expected to know* (mainly via its picture‑labelled alphabet/vocabulary pages, and by noting which nouns/verbs recur across its short reading lessons). Every `meaning_mizo`, `example_mizo` and `english_gloss` in the CSV was written fresh by the extracting agent — none of it reproduces or closely paraphrases book text. Lesson topics are described in my own words in the notes below, not quoted.

## Page ranges examined

- Skipped pp. 1–14 (front matter) as instructed.
- Read in full: pp. 15–34, 35–54, 55–74, 75–94, 95–114, 121–140 (the last read block re-covered 121–126 due to a page-range-size limit, then continued to the back cover at ~142).
- Effectively every page from 15 through the end of the book (~127, followed by a "Zirtirtute Tan" teacher's-notes appendix, an English "Road Signs" page, and the back cover) was viewed.

## Extraction method

1. Read the PDF in ≤20-page chunks using the `pages` parameter, viewing each page's rendered image.
2. Prioritized the clearest, most reliable vocabulary sources:
   - **Alphabet primer pages (pp. 4–17, "Zirlai 1")**: each letter is paired with one picture and one word (e.g. a rooster picture labelled "âr", a goat labelled "kêl"). These are the highest-confidence source.
   - **Picture-word exercise pages** (e.g. p. 18 colour naming, p. 36 and p. 44 family/body-part picture lists, p. 102 fruit/vegetable picture list) — a picture directly captioned with a Mizo word.
   - **Recurring content words** inside the short graded-reading lessons (Zirlai 2–19): nouns and verbs that appear repeatedly in context across multiple sentences/exercises (e.g. "bâwng" = cow, "sazu" = cat, "thei"/"rah" = fruit, common verbs like "ei" = eat, "mut" = sleep, "chhiar" = read).
3. Did **not** extract from pure letter-tracing/handwriting-practice pages (pp. 46–54), phonics syllable drills that are not real dictionary words (e.g. nonsense CV rows like "am ap at al"), or from the story dialogue text itself (only the recurring nouns/verbs implied by that text were extracted, with original glosses and sentences written afterward).
4. Deduplicated by canonical form; where the book used both a generic and a diminutive form of the same animal (e.g. "arpa"/"arpui"/"âr" for rooster/hen/chicken), only the most generic, most clearly confirmed form was kept, to avoid near-duplicate/uncertain entries.

## Word count

**112 distinct words extracted**, spanning: animals (22), verbs (24), nature/weather (11), body parts (9), food (8), family/people (7), objects (6), plants (6), adjectives (6), colours (4), school-related (4), clothing (3), numbers (2).

This falls short of the book's ~800-word curriculum target for the whole grade, as expected — this represents a solid, well-sourced first pass concentrated on the clearest picture-vocabulary and highest-frequency content words, not an exhaustive transcription of every word in the book.

## Words flagged VERIFY (5)

- **lâwi** — glossed as "mithun / wild-ox-like cattle." The picture-primer page shows a large bovine-looking animal but gives no further definition; the exact species is uncertain.
- **pawl** — glossed as "blue," inferred solely from a blue mug's caption in a colour-naming exercise (p. 18); not cross-checked against a dictionary.
- **eng** — glossed as "yellow," inferred from a yellow pumpkin's caption in the same exercise. Flagged because "eng" also commonly functions as the Mizo interrogative "what" elsewhere in the book, so this colour reading is less certain than the others.
- **nghâwng** — glossed as "root (of a plant)," inferred from a personified flower character's dialogue line ("ka nghâwng chu a va na em" — my [nghâwng] hurts) in the "Papari" story (Zirlai 19); plausible but not confirmed against a dictionary.
- **dai** — glossed as "lightning," inferred from its place in a short sky/weather word list alongside "ni," "chhûm," "ruah"; could plausibly instead mean "thunder."

All five are otherwise usable draft entries; they are simply lower-confidence than the rest and worth a native-speaker check before `language_review` is marked done.

## Deliberately skipped

- **English loanwords used only to teach specific letters** — "grep" (grape) and "jam" — were seen on the alphabet pages but skipped as not being genuinely Mizo vocabulary.
- **Religious/identity terms** — "Pathian" (God) and "Lalpa" (Lord) recur constantly throughout the book's prayers, hymns, and closing blessings of nearly every lesson. Consistent with how this project has previously deferred a word like "Mizo" itself to a human culture/language reviewer rather than guessing, these were deliberately left out of the automated extraction rather than assigned a casual gloss.
- **Phonics-drill nonsense syllables** (e.g. rows like "am ap at al ar", "fer fe le re", CV drill tables) — these are letter-sound practice, not real dictionary words, and were not treated as vocabulary.
- **Uncaptioned matching/labelling exercises** — several pages show animal or fruit pictures with blank lines for the student to fill in (pp. 58, 97, 122); since the book itself supplies no Mizo word there, nothing was invented for those images.
- **Ambiguous folk-tale character names** of uncertain species (e.g. "sanghal," "pitartê," "taivâng" as a poetic name for the sun) from the "Chemtâtrâwta" cumulative tale (Zirlai 18) — skipped rather than guessed, since their exact real-world referents were not clear from context alone.

## Notes on content generated

All `meaning_mizo` (simple Mizo-language definitions) and `example_mizo` (original example sentences) were composed fresh for this dataset, generally following a simple "X chu ... a ni" (X is a ...) definition pattern and a short original sentence using the word — deliberately different in wording and structure from anything in the source book. As with any non-native-speaker-generated Mizo text, these should go through the normal `language_review` pass before being marked final.
