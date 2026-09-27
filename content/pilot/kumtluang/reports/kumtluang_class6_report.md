# Kumtluang Class VI (SCERT Mizoram) — Vocabulary Extraction Report

## Source
`/root/.claude/uploads/57b88324-b90d-5086-b0d8-d066d67c4974/ab3235ba-Kumtluang_Class_VI.pdf` (164 PDF pages; printed page numbers run 4–150, offset ~14 from PDF page index).

## Pages examined
- PDF pages 18–37 (printed pp. 4–23) — Zirlai 2 "Mawitea Pa Silai", Zirlai 3 "Noun" (grammar), Zirlai 4 "Mi Vanduai Hlawhtlingte", Zirlai 5 "Sava leh a Notete" (start)
- PDF pages 38–57 (printed pp. 24–43) — end of Zirlai 5, Zirlai 6 "Thumal Danglam Ṭhin Dan" (word-form grammar), Zirlai 7 "Mother Teresa", Zirlai 8 "Birthday Lawm Ila"
- PDF pages 58–77 (printed pp. 44–63) — rest of Zirlai 8, Zirlai 9 "Zo Nun Mawi" (poem), Zirlai 10 "Ho Mai Mai" (essay), Zirlai 11 "Khuangchera" (Mizo legend)
- PDF pages 78–97 (printed pp. 64–83) — end of Zirlai 11, Zirlai 12 "Postposition" (grammar), Zirlai 13 "Kan Khua a Lo Changkang Ve Ta" (village sanitation essay), Zirlai 14 "Verona Khuaa Tui Lian" (flood story), Zirlai 15 "Aia Upate Zah Thiamin" (poem), start of Zirlai 16 "Tualvungi leh Zawlpala" (Mizo folk tale)
- PDF pages 98–117 (printed pp. 84–103) — rest of Zirlai 16, Zirlai 17 "Thli" (wind — essay/poems), Zirlai 18 "Nun Dan Ṭha" (road-safety etiquette), Zirlai 19 "Conjunction" (grammar), Zirlai 20 "Ka Ṭhiante" (friendship essay, start)
- PDF pages 118–137 (printed pp. 104–123) — rest of Zirlai 20, Zirlai 21 "Fur Khaw Thiang" (nature poem), Zirlai 22 "Interjection" (grammar), Zirlai 23 "Ṭawng Upa" (Mizo idioms), Zirlai 24 "Kungawrhi" (Mizo folktale, spirit/khuavang lore)
- PDF pages 138–157 (printed pp. 124–143) — end of Zirlai 24, Zirlai 25 "Mizo Thiamhnang" (traditional handicrafts, dialogue form), Zirlai 26 "Liansanga-te Unau" (family/sibling drama)
- PDF pages 158–164 (printed pp. 144–150) — Zirlai 27 "Aw Nang Mizoram Tlang Nuam" (patriotic poem), Zirlai 28 "Lehkhathawn leh Sawmna Ziah Dan" (letter-writing formats — end of book)

Coverage spans the entire book from front matter's end to the final page, sampling every lesson (Zirlai 2–28) rather than reading every exercise/answer-key page in exhaustive detail — lesson titles, narrative/expository prose, poems, vocabulary glossary boxes ("Thu Pawimawhte" / "Thu Har Hrilh Fiahna"), and grammar-term lists were prioritized, per instructions, over the "Tih Turte" (exercise question) pages, which were skimmed mainly for any additional vocabulary boxes.

## Extraction method
1. Read the PDF in ~20-page batches via the `pages` parameter, viewing each page's text/illustrations.
2. Identified candidate words/phrases from: lesson body prose, poem stanzas, the book's own end-of-lesson vocabulary glossary boxes (which list a word list only, not full sentences), and grammar-term lists (nouns, conjunctions, interjections, idioms).
3. For every candidate, wrote an entirely original English gloss, Mizo-language definition, and Mizo example sentence — none of the book's own sentences, story text, or poem lines were copied or lightly reworded. The book's glossary boxes gave only single Mizo synonym/definition words (e.g. "huaina — a nih dan..."), which were used only to confirm meaning, then re-expressed in new wording.
4. Deduplicated within the list (case-insensitive canonical form); a Python script assembled the final CSV with correct escaping.

## Output
- `/tmp/tq_content/kumtluang_class6_vocab.csv` — 149 distinct rows, all columns as specified (`candidate_id … emoji`), `tq_level=K6`, `difficulty=6`, `status=draft`, all review/audio fields `pending`.
- Category breakdown: abstract/values 52, nature 21, verbs 19, culture/folklore 15, idiom 13, adjectives 12, grammar-term 7, people 6, objects 4.
- `game_modes`: concrete/depictable items (animals, weather phenomena, tools, places — e.g. sakei "tiger", tui lian "flood", phûrpui "broom", khelmual "playground") got `picture_match` added; abstract values, idioms, and grammar-function words got `word_chain,spelling,word_search` only, per instructions.

## Items flagged VERIFY
Two kinds of VERIFY notes were used:
1. **Culture-sensitive / route to human reviewer** (per instructions) — applied to: `pasaltha`, `lalpa`, `khuavang`, `lamthuam`, `phaipheng`, `thlarau`, `boralsan`, `huaisen`, `tlawmngaihna`, `tlawmngai`, `râl kai rual`, and all 10 traditional-craft terms from "Mizo Thiamhnang" (`paikâwng`, `khumbeu`, `thûl`, `sisêp`, `chhihri`, `faikhiat`, `kho`, `siksil`, `aiâwt`, `hruikhau`, `buhtun`). These touch on traditional chieftainship, warrior/hero culture, spirit-folklore, respectful death terminology, and material culture that deserve a native-speaker/culture reviewer's confirmation rather than my own invented gloss.
2. **Uncertain precise nuance** — applied to the 9 idioms drawn from the "Ṭawng Upa" lesson (e.g. `a letlinga khai ang`, `kêlphûng tap chim hmu ang`, `thingchang var`) and a few figurative/poetic phrases (`harsatna thli`, `thlêmna thli`, `phurhhlân`, `pasawntlung`). Idiomatic and figurative language is hard to gloss with certainty from context alone; I gave my best sense-based interpretation but flagged these for a fluency check.

## Deliberately skipped
- All proper nouns / character names from the folk tales and legends (Khuangchera, Tualvungi, Zawlpala, Phunṭiha, Kungawrhi, Phawthira, Hrangchala, Liansanga, Mother Teresa's biographical names, etc.) — not vocabulary words per se.
- Full sentences, story dialogue, and poem lines from the book itself — never transcribed, only used to identify *which words* exist; every definition/example here is original.
- Exercise/answer-key filler pages (the many "Tih Turte" comprehension-question pages) — skimmed for vocabulary but their question text itself was not mined for vocabulary beyond words already appearing in the vocabulary boxes.
- Primary-grade-level basic common nouns already well covered by earlier grade books (e.g. simple animal/body-part nouns from the Noun-lesson example lists) were mostly left out in favor of more literary/abstract Class VI-appropriate vocabulary, per instructions.
- Single bare interjections with no real translatable content (e.g. "Awi!", "Uai!", "Eu!") were skipped except one representative example (`E khai`) kept for completeness of the interjection grammar category.
