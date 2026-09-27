# Kumtluang Bu Hnihna (Class II) — Vocabulary Extraction Report

## Source
`/root/.claude/uploads/57b88324-b90d-5086-b0d8-d066d67c4974/72b9b6db-kumtluang-2.pdf` (120 PDF pages; book content runs from PDF page 15 to roughly PDF page 118, i.e. book pages 1–103, covering 20 numbered lessons/"Zirlai" plus front matter and a short back-matter section on road signs and a Childline notice).

## Page ranges examined
- PDF pages 15–34 (book pp. 1–20): Zirlai 1–5 (rhymes, cursive-writing drills, "Fanghmir leh Ṭhuro" fable, "Inmamawh tawn vek kan ni" poem, "Mei hi a hlauhawm" forest-fire story)
- PDF pages 35–54 (book pp. 21–40): Zirlai 6–9 (good-manners guidance, "Chhimbâl" rainbow story, "Mawi leh duhawm nan" hygiene poem, "Zâwngtê leh Satel" monkey/tortoise fable)
- PDF pages 55–74 (book pp. 41–60): Zirlai 9 exercises, Zirlai 10 "Pangpar" (flower/weather story), Zirlai 11 "Zîng ni êng mawi" (morning hymn), Zirlai 12 "Lui kal" (river outing), Zirlai 13 "Zovi leh sava notê" (girl and baby birds)
- PDF pages 75–94 (book pp. 61–80): Zirlai 13 exercises, Zirlai 14 "Kei ka hmunah" (classroom/patriotic poem), Zirlai 15 "Sana bo thu" (lost-watch honesty story), Zirlai 16 "Sazâltepa leh Bâkvawmtepu" (fox/bear fable)
- PDF pages 95–114 (book pp. 81–100): Zirlai 16 exercises, Zirlai 17 "Lalpa mi vêngtu" (Psalm-23-style hymn), Zirlai 18 "Bawnghnute no khat" (poor boy/calf story), Zirlai 19 "Lal Solomona" (Bible story of King Solomon), Zirlai 20 "Glen Cunningham" (true story of an athlete who overcame a childhood burn injury)
- PDF pages 115–120 (book pp. 101–103 + back matter): closing exercises, a "road signs" reference page, and the back-cover/Childline page (no lesson content)

Coverage spans the full book — beginning, middle, and end — and every one of the 20 lessons was at least skimmed; the explicit "Thu pawimawhte" (key-words) boxes that most lessons include were treated as the highest-priority vocabulary source, since they are the book's own curated word lists rather than running prose.

## Extraction method
1. Read the PDF in 20-page batches (the maximum the tool allows) and visually scanned each page image rather than relying on any embedded text layer.
2. Prioritized: (a) each lesson's "Thu pawimawhte" key-word box, (b) labeled picture-vocabulary exercises (e.g. animal/occupation/color matching pages), and (c) lesson titles/topics, over dense narrative paragraphs.
3. For each candidate word, verified it was a standalone, curriculum-relevant vocabulary item (not a proper name, not a grammar/spelling drill artifact like "dim dem, dem dem", and not part of the handwriting-practice alphabet pages in Zirlai 2).
4. Wrote every `meaning_mizo`, `english_gloss`, and `example_mizo` from scratch in my own words — none of the story/poem sentences from the book were transcribed or paraphrased. Where a lesson's own "Thu pawimawhte" list supplied the headword, I still composed an original definition and an original example sentence rather than reusing any book sentence containing that word.
5. Deduplicated against Class I "obvious basics" (numbers 1–10, "hi/hei"-style greetings, primary-color reds/blues taught earlier) where those seemed like pure carry-overs; kept them where the Class II book meaningfully reintroduces or builds on them (e.g. the rainbow-lesson color set, which is presented as new vocabulary in this book).

## Output
- `/tmp/tq_content/kumtluang_class2_vocab.csv` — 134 distinct rows, all columns populated per the requested schema, `tq_level=K2`, `status=draft`, all review fields `pending`, `difficulty=2`.
- Categories used (`seed_category`): time, nature, plants, animals, body, colors, daily_life, values, school, occupations, verbs, adjectives, abstract, family, objects, food.
- `picture_match` was included in `game_modes` only for concrete, single, visually unambiguous nouns/actions (animals, plants, colors, body parts, hygiene actions, occupations-in-action, objects). It was withheld for abstract nouns, emotions, and verbs that don't reduce to one clean image (e.g. `khawngaih`, `lungngai`, `remruat`, `fing`).

## Words flagged VERIFY
A handful of entries carry a `VERIFY:` prefix in `notes` because I was not fully confident of exact tone-mark spelling or precise sense from the page image alone, and recommend a fluent-speaker check before these leave draft status:
- `thlal` (dry/cold season) — tone-mark placement on "thlâl"
- `maian` (banana plant) — confirm this is the book's intended modern spelling vs. a variant
- `savawm` (bear) — confirm this is the standard term used in this edition rather than a regional variant
- `ki` (horn) — flagged because the bare noun can be ambiguous out of context
- `pawl` (blue) — the book's rainbow-color exercise didn't spell out the full color name for every swatch, so the blue/blue-green boundary is my inference from the picture, not a labeled word

## Deliberately skipped or excluded
- **Proper/character names and biblical/proper nouns** — e.g. "Solomona," "Davida," "Zovi," "Dawnga," "Rama," "Nghepa/Ngheta," "Zara," "Fela," "Glen Cunningham." These are story characters or historical/biblical figures, not general vocabulary a game should teach as a "word."
- **Religious-specific terms from Zirlai 17 and 19** (the Psalm-23-style hymn and the King Solomon story) — I deliberately did **not** extract "Pathian" (God) or "Lalpa" (Lord) as headwords, even though they recur heavily in those two lessons. These carry religious weight and, similar to how earlier project work deferred a culturally loaded term like "Mizo" itself to a human reviewer, I judged that the right religious/theological framing for such words is a decision for a human content reviewer, not something to guess at in a vocabulary draft. I did pull the *non-religious* abstract vocabulary those lessons also introduce (e.g. `remhria` wisdom, `hausakna` wealth, `ropuina` glory, `rorel` to rule) since those are ordinary Mizo words with everyday use outside the religious context.
- **Disability-related terminology** from the good-manners lesson (Zirlai 6), specifically the passage on "rualbanlote" (persons with disabilities) and related phrasing about how to treat them with care. I left this out of the word list rather than risk an imprecise or stigmatizing gloss; this is a case where a human reviewer familiar with current respectful Mizo disability terminology should decide the right headword and definition, if the game wants to include it at all.
- **Pure handwriting/phonics drills** (Zirlai 2's cursive alphabet practice, and rhyming nonsense-syllable drills like "dim dem, dem dem" / "tap kerh kerh") — these are literacy mechanics, not vocabulary.
- **English loanwords already in the book as-is** (e.g. "motor," "TV," "table," "pencil," "classroom," "office," "chart paper") — these aren't distinct Mizo vocabulary items worth a dedicated flashcard entry.
- **Obvious Class I carry-overs** without new treatment (e.g. basic 1–10 counting, "chibai"-style greetings) since the book doesn't reintroduce them as new content in Class II.

## Totals
134 distinct candidate words extracted (target was 100–150). All rows deduplicated by `canonical_form`.
