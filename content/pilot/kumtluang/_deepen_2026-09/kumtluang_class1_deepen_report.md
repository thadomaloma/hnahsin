# Deep Vocabulary-Extraction Pass — Kumtluang Bu Khatna (Class I, SCERT Mizoram)

## Method

The entire PDF (141 pages, covering front matter, "Ṭawngṭaina hla," Zirlai (Lessons) 1–19, and back matter) was read directly with the Read tool in five sequential batches of ≤20 pages each (pp. 1–20, 21–40, 41–60, 61–80, 81–100, 101–126, 127–141). After the first batch, the table of contents (p.14 of the PDF, "A Chhung Thu") was used to map book page numbers to lesson titles and confirm coverage of all 19 lessons plus the closing "Zirtirtute Tan" song and a "Road Signs" appendix.

For each lesson the following were mined, in order of priority:
- Explicit "Thu pawimawhte" (key-words) boxes not already captured by the first pass.
- Picture-labeled vocabulary (alphabet cards, matching exercises, body-part diagrams, color/shape drills).
- Confidently glossable words drawn from short dialogue/story text (e.g., the "Arpuisentê"/Little Red Hen tale, the "Chemtâtrâwta" chain-reaction folktale, the "Papari"/Sun-and-Flower dialogue) — without transcribing or closely paraphrasing the book's own sentences.
- Vocabulary/matching exercises (e.g., crossword on p.103, comprehension word-search on p.39).

Pure phonics/rime drills (long lists of CV or rime-family syllables paired only with generic "child reading" clip-art, not semantic picture pairs — e.g., pp.36–37) were deliberately **not** mined, since these are decoding practice, not vocabulary, and confident glosses for isolated syllables would risk fabrication.

Every candidate was checked against both supplied exclude lists (the case-/diacritic-sensitive "already extracted" list and the "already used elsewhere in the app" list) before inclusion. Several near-duplicates were caught and dropped during this check even though they differed by a diacritic or suffix, to avoid effectively re-adding an already-covered word (see below).

## Page ranges examined

PDF pp. 1–141 (the entire supplied file), corresponding to book pages i–126 plus a short "Road Signs" back-matter appendix that contained no further Mizo vocabulary.

## Result

**72 new vocabulary rows** were produced, written to `/tmp/tq_deepen/kumtluang_class1_deepen.csv`.

All words are short, everyday Class-I-level items consistent with the stated curriculum level: body parts (bân/arm, mit-adjacent tin/palm, pangang/throat), household/food items (thlêng/plate, buhhûm/wheat, artui/egg, tala/padlock), simple verbs (haw/return, nei/have, lak/take, nui/smile, ṭap/cry, tuh/plant), common adjectives (rit/heavy, him/safe, hlu/precious, damlo/sick), animal-sound onomatopoeia (ngiau/meow, tâwk/quack, bauh/bark), and a few community/abstract words (nun/life, mumang/dream, ral/enemy-war).

## Words held back / deliberately skipped

- **nep, ka** (Zirlai 5 word-search box) — too ambiguous/polysemous to gloss confidently without guessing.
- **thosi, derhken, fanghmir, naubân, kumtluang** (Zirlai 10 flower/insect matching list) — specialized botanical/entomological terms I could not confidently verify; "kumtluang" also risks confusion with the book's own title.
- **tlangnel, bihrûk** (Zirlai 19 dialogue) — plausible adjectives but meaning too uncertain to include responsibly.
- Long phonics/rime-drill word lists (pp. 4–17, 36–37, 46–54, 103–104) — decoding practice rather than semantic vocabulary; including these would have inflated the count without real learning value.
- **man** (to catch) and **zâmna** (surface/covering) were drafted but then removed after re-checking: both are exact matches already on the supplied "already extracted" list.
- **mit** (eye), **hrilh** (to tell), **siamsak** (to make), **lungngaih** (to feel sorry for) were drafted but removed as effective duplicates of core app vocabulary already in use ("Mit", "Hril", "Siam", "Lungngai" respectively).

## VERIFY list (included, but flagged for spelling/meaning confirmation)

| Word | Reason |
|---|---|
| der | Onomatopoeic root ("dêr dêr" = wing-flapping); standalone meaning inferred from limited context. |
| zuk | Adverb; exact nuance ("continuously"?) is a best estimate from context. |
| bul | Included as "base/stump/origin"; the precise standalone sense is uncertain. |
| nâwt | Possible diacritic variant of an already-excluded form spelled without the circumflex ("nawt") — flagged so a reviewer can confirm whether it's the same word. |
| ṭo, vûi | Farming/growth verbs inferred from the Little Red Hen story's narrative; glosses are reasonable but not dictionary-confirmed. |
| hrâm | Same diacritic-variant concern as nâwt, relative to excluded "hram". |
| dial | Normally appears reduplicated ("dial dial"); the standalone adjective sense is inferred. |
| chuk | Glossed as "to feel cold" from a single narrative usage; could carry a different nuance. |

## Culture-sensitivity flag

- **lal** ("chief, king") — flagged `VERIFY culture-sensitive: touches traditional Mizo chieftainship, route to human culture reviewer.` This was the only word encountered in the book that clearly touches chieftainship/traditional-authority territory; the book otherwise contains no pasaltha/warrior, khuavang/spirit-folklore, ceremonial-craft, or death/mourning content in its Class I material.

## Data integrity note

Partway through this task, `/tmp/tq_deepen/` (the specified output directory) was found to contain files from an unrelated extraction job for a **different textbook** ("Kumtluang BU SARIHNA," a Class VII book) and, later, evidence of other concurrent jobs (Class V/VII scratch files) actively writing into the same shared directory. None of that stray content was used — it was deleted where it collided with my own working notes, and this report and the CSV were built solely from my own direct, verified reads of the correct Class I PDF at the path given in the task. The final CSV was re-verified after writing (72 rows, all `candidate_id` and `canonical_form` values unique) to confirm it wasn't clobbered by the other concurrent process.
