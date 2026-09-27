# Kumtluang Bu Thumna (Class III) — Deeper Vocabulary Extraction Report

## Scope and method
- Source: `/root/.claude/uploads/57b88324-b90d-5086-b0d8-d066d67c4974/d43156ab-kumtluang-3.pdf`, official SCERT Mizoram Class III Mizo textbook.
- Pages examined: the full book was read page-by-page in five batches (pages 1–20, 21–40, 41–60, 61–80, 81–100, 101–120/end). The book runs front matter (pages 1–16: cover, DIKSHA instructions, copyright, committee lists, Constitution preamble/duties, Thuhmahruai foreword, table of contents) through 20 numbered lessons (Zirlai 1–20, book pages 1–117) plus a back cover/Childline notice. All 20 lessons and every exercise page were reviewed.
- Method: for each lesson I read the running text only far enough to understand topic/theme and to confidently gloss listed vocabulary — I did not transcribe or closely paraphrase any story, poem, or dialogue. I mined:
  - "Thu pawimawhte" (word-box) lists at the end of each lesson
  - "danglam bik" (odd-one-out) vocabulary sets
  - picture-labeled vocabulary (thlai/pangpar/body-part diagrams)
  - synonym/antonym and minimal-pair matching exercises
  - a few narrative nouns/verbs that were unambiguous and safely glossable in isolation (e.g. names of foods, animals, seasons) without reproducing any story sentence.
- Every word was checked, exact-match and case-sensitive, against both supplied exclude lists (the already-extracted "Thu pawimawhte" word-box list, and the app's existing core-vocabulary list) using a scripted diff rather than manual memory, to avoid false negatives/positives. Verified programmatically: zero rows in the final CSV match either exclude list.

## Output
- **91 new candidate rows** written to `/tmp/tq_deepen/kumtluang_class3_deepen.csv` (header + 91 data rows), covering nature, food, body parts, time/seasons, emotions/abstract qualities, verbs, and a handful of craft/hunting/folklore-adjacent terms.
- One canonical form (`hlâi`) appears twice deliberately, for two distinct senses found in different lessons (a tree species in the Lesson 8 school-garden description, and a bamboo/cane weaving strip in the Lesson 18 "Lawmtea" story) — each has its own candidate_id and a note flagging the possible homonym risk for a human reviewer.

## VERIFY list (uncertain meaning/spelling — flagged in the `notes` column of each row)
Most rows carry a VERIFY note because many of these words are grade-3-level items I could gloss with reasonable but not full confidence from limited story context (the book could not be transcribed to confirm nuance). Notable ones a reviewer should prioritize:
- **kâwng** — meaning genuinely ambiguous from the "Unau Fanghma ṭo Zawng" folktale context (could be "neck" or "container/basket").
- **anṭam** (caterpillar) — diacritics/spelling should be confirmed against standard orthography.
- **ṭhui** — possible variant/typo of the already-excluded word "thui"; confirm whether it's genuinely distinct.
- **chhâwng** — animal identity uncertain (mithun vs. pig) in the New Year slaughter/feast description.
- **lungthu**, **nghalchang**, **hmusit** — hunting/warrior vocabulary from the Chawngbawla pasaltha story; glosses are reasonable but not certain.
- Several near-synonym pairs from matching exercises (nêm/thal, dai/chang, pua/hrai) where the book only pairs words without defining them — glosses are inferred from word roots and general Mizo usage.

## Culture-sensitive flags (routed to human culture reviewer, per instructions)
- **hmusit, nghalchang, sa bawp, phîn, lungthu, tah, hlâi (weaving sense)** — traditional pasaltha/hunting and bamboo-weaving craft vocabulary from Zirlai 10 ("Sakeibaknei leh Chaichim Thu" is the fable lesson; the pasaltha/hunting terms are from Zirlai 10 "Sual leh...", more precisely the Chawngbawla pasaltha lesson) and Zirlai 18 ("Lawmtea").
- **râl** — appears in the Zirlai 2 ("Unau Fanghma ṭo Zawng") mushroom-transformation folk tale.
- **chhâwng** — ceremonial/festive slaughter practice described in Zirlai 11 ("Mizo Hun Puite").
- No words from the Nuchhimi ogress folk tale (Zirlai 13) survived as *new* words — every word in that lesson's word box turned out to already be on the first-pass exclude list once checked exactly, so nothing from that lesson needed a fresh culture flag.

## Deliberately skipped / not included
- All 12 Mizo calendar month names (Pawlkût thla, Ramtuk thla, Vâu thla, Tâu thla, Ṭomir thla, Nikir thla, Vawkhniahzawn thla, Thlazîng, Mimkût thla, Khuangchawi thla, Sahmulphah thla, Pawltlâk thla) — already on the exclude list.
- The legendary hunter's name "Chawngbawla" (Zirlai 10) — a person's/legendary figure's name, excluded per the "no real people's names" rule.
- Several two-word idiomatic phrases from matching exercises (e.g. "kal pai", "paih darh", "hnawk nuai", "chho sâng kai", "val kalh") — too idiomatic/compound to gloss with genuine confidence; skipped rather than guessed.
- Specific insect names hidden in a missing-vowel puzzle (page 90–91, e.g. "pangr_m", "khapd_au") — the intended answer words could not be determined without an answer key, so they were skipped rather than guessed.
- English loanwords used as-is in Mizo text (e.g. "tomato", "rose", "bike", "balloon") — not Mizo vocabulary.
- Story/poem prose itself was never transcribed or paraphrased into `meaning_mizo`/`example_mizo`; every definition and example sentence in the CSV was written from scratch.

## Word count vs. curriculum target
The book's own stated target is ~1300 words for Class III; combined with the first pass (156 words) and this pass (91 words), total coverage is still well under that target. The remaining gap is mostly in extended narrative vocabulary embedded in the stories/poems (which per the copyright rules cannot be mined by transcription) and in exercise blanks whose intended answers aren't printed in the book (e.g. several picture-labeling exercises where the answer word is implied by the picture but not given as text). A further pass would need either an answer key or careful independent captioning of each unlabeled picture exercise.
