# Kumtluang Class VI — Deeper Vocabulary Extraction Report

## Pages examined
Whole book read via the PDF `pages` parameter in ~20-page chunks, covering all 164 PDF
pages (front matter + 150 numbered textbook pages, Lessons 1–28):
- PDF pp. 1–20 (front matter, TOC, Lessons 1–2 start)
- PDF pp. 21–46 (Lessons 2–7: grammar exercises, "Mi vanduai hlawhtlingte", Esopa fable,
  Thumal danglam, Mother Teresa)
- PDF pp. 47–60 (Lesson 8 "Birthday lawm ila" personified fruit/flower dialogue, Lesson 9
  "Zo nun mawi")
- PDF pp. 61–80 (Lessons 10–13: "Ho mai mai", "Khuangchêra", Postposition, "Kan khua a lo
  changkang ve ta")
- PDF pp. 81–100 (Lessons 14–19: "Verona khuaa tui lian", "Aia upate zah thiamin",
  "Tualvungi leh Zawlpala", "Thli", "Nun dan tha", Conjunction)
- PDF pp. 101–120 (Lessons 20–21: "Ka ṭhiante", "Fûr khaw thiang")
- PDF pp. 121–140 (Lessons 22–26: Interjection, "Tawng upa" idioms, "Kungawrhi",
  "Mizo thiamhnâng", "Liansanga-te unau")
- PDF pp. 141–160 (Lesson 26 continued, Lesson 27 "Aw nang Mizoram tlang nuam")
- PDF pp. 161–164 (Lesson 28 "Lehkhathawn leh sawmna ziah dan" — letter/invitation formats;
  book ends at printed page 150)

## Method
For each lesson, skimmed running narrative/poetry only for topic and gloss context (never
transcribing story text into output), and mined:
- explicit "Thu pawimawhte" / "Thu har hrilh fiahna" word-boxes and glossaries (several
  per lesson beyond the ones the first pass already pulled — e.g. the craft-vocabulary
  glossary in "Tualvungi leh Zawlpala", the idiom-with-definition list in "Tawng upa", the
  full glossary/dialogue in "Mizo thiamhnâng", and the "Kungawrhi" glossary)
- picture-labelled vocabulary (the personified fruit/vegetable/flower characters in
  "Birthday lawm ila")
- vocabulary-drill exercise lists that ask students to define specific words (e.g. "Zo
  nun mawi" and "Fûr khaw thiang" TIH TURTE sections)
- confidently glossable words from short dialogue/context

Every candidate was checked against BOTH exclusion lists (the exact first-pass Class VI
list and the cross-class/Vartian list) before inclusion. A large fraction of the word-box
items encountered had, in fact, already been captured by the first pass (e.g. most of the
"Thu pawimawhte" boxes in "Ho mai mai", "Fûr khaw thiang", and "Kan khua a lo changkang ve
ta" turned out to be ~90% already-excluded words) — only the remainder is reported here.

## Result
**68 new rows** written to `/tmp/tq_deepen/kumtluang_class6_deepen.csv`.

Category breakdown (approximate): traditional_culture/craft ~20, food (personified
fruit/veg characters) ~16, community ~11, idiom ~7, verbs ~5, adjectives ~5, nature ~4,
values ~4, tools ~2, body ~1.

## VERIFY list (spelling/meaning uncertainty, not culture)
- **Artukkhuan, Antam, Anthûr, Chingit, Behlawi, Sunhlu, Thingfanghmai, Anhling** — the
  personified fruit/flower/vegetable characters in "Birthday lawm ila". Glossed from the
  lesson's illustrations and descriptive dialogue; exact botanical species not confirmed
  against a dictionary for all of them (Chingit, Sunhlu, Thingfanghmai reasonably
  confident; the others less so).
- **Thing hâr, Pawhraw, Hlet** — appear as bare word-box items (Khuangchêra lesson) with
  no explicit definition given in the book; meanings inferred from surrounding narrative
  context only.
- **Losûl** — inferred meaning (a freshly cleared jhum field) from context; not explicitly
  defined in the book.
- **Mual liam** — a single line of poetry uses this phrase; exact idiomatic force is a
  best-effort reading.
- **Zufâng** — the book's own glossary entry for this word ("buh ban zû") was hard to
  parse precisely; kept the gloss general (a zu/rice-beer vessel).
- **Êmpâi** — also appears in the source spelled "pâiêm"; kept as a general "carrying
  basket" gloss.
- **Vaihrik** — given in the book only as a bracketed alternate name for "chhihri"
  (a sifting tool); no independent definition.
- **Hawrawppui** — a letter-format heading term; grammatical/precise classification kept
  general.

## Culture-sensitive flags (routed to human culture reviewer)
As expected at this grade level, two lessons ("Tualvungi leh Zawlpala" and "Mizo
thiamhnâng") are rich in traditional craft/attire/ceremony vocabulary beyond the
"khumbeu"/"paikâwng" items the first pass already found. Flagged with
`VERIFY culture-sensitive` in the CSV:
- **Traditional attire/craft items**: Thawmmâwl (waist pouch), Tlangbân (shoulder
  carrying-cord), Banglai (plain-brimmed hat), Bang kalh kim (evenly-woven bamboo hat
  quality), Tungchaw (headdress pin/peg), Hnâng, Êmpâi, Thlangrâ, Arbâwm, Paipêr, Vaihrik,
  Lamthlûk (woven bamboo basketry/tools from the "Mizo thiamhnâng" craft-teaching
  dialogue)
- **Traditional drink**: Zufâng (a container for zu / rice beer)
- **Farming custom**: Losûl (jhum/shifting-cultivation field)
- **Death/mourning customs**: Thlaichhiahna (grave-marking practice), Se hrân lu (mithun
  skull displayed in memorial rites), Zawlpuan (in this lesson specifically glossed in a
  funerary-shroud context, though it is broadly known as a ceremonial textile)

## Deliberately skipped / not included
- Many word-box and glossary items turned out to duplicate the first-pass exclusion list
  exactly or near-exactly (e.g. most of "Ho mai mai"'s and "Fûr khaw thiang"'s
  "Thu pawimawhte" boxes, most of the "Tawng upa" idiom list, "hnam pangpar"/"phurhhlân"/
  "ram riang tê" from "Zo nun mawi", "pasawntlung", "thengthaw", "rualrem", "lawilen",
  "hnâwm", "duap kai", "thangtha", "tladah", "ngaihsam", "vantlang" and its "pa vantlang"
  form, and "enghelh") — skipped to avoid duplicating the first pass.
- **"Ba rawh"** (a craft/marriage-custom glossary entry) was dropped entirely: the book's
  own gloss for it ("bapui vut dûra rawh hmin") could not be parsed into a confident
  meaning, so per instructions it was omitted rather than guessed.
- Grammar-lesson example word lists (Noun, Postposition, Conjunction, Interjection
  lessons) were skimmed but mostly skipped — they consist of extremely basic function
  words or generic example nouns (ui, vawk, bâwng, kêl, sikul, kawng, etc.) that are
  either grammatical function words, not meaningfully distinct vocabulary, or too
  commonplace/likely already core app vocabulary.
- Named ethnic/sub-group terms appearing in "Aw nang Mizoram tlang nuam" (Lusei, Hmâr,
  Râlte, Pawi) were skipped as identity-sensitive proper names rather than general
  vocabulary.
- Incomplete dialect word-pairs (Chhim/Hmar column exercise, p.31) were skipped — several
  blanks made confident glossing impossible for those items.
- No real person's name was included as vocabulary.

## Files written
- `/tmp/tq_deepen/kumtluang_class6_deepen.csv` (68 rows + header)
- `/tmp/tq_deepen/kumtluang_class6_deepen_report.md` (this file)
