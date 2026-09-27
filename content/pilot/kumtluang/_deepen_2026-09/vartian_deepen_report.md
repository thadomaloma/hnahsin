# Vartian (Ujaas Part-1) Vocabulary Extraction Report

**Source:** Ujaas (Vartian) Part-1, SCERT Mizoram, New India Literacy Programme adult-literacy primer (March 2023 printing). PDF: `/mnt/user-data/uploads/Vartian.pdf`, 61 pages (PDF page count confirmed with `pypdf`).

**Output:** `/tmp/tq_deepen/vartian_deepen.csv` — 91 rows.

## Page ranges examined

All 61 PDF pages were read with the Read tool in four batches (1–20, 21–40, 34–50 overlap check, 44–61), which covers the entire document including front matter. Printed page numbers run from the cover through printed page 54 (front matter pages 1–8 have no printed footer; the printed body runs roughly PDF-page-offset +7). Content actually starts at printed page 1 (Lesson 1 "Chhungkua leh ṭhenawm") and the book's last content page is printed page 54 (end of Lesson 3 "Khawtlang inrelbawlna" — assessment worksheet). No pages were skipped except the cover, copyright/imprint page, the Director's foreword ("Thuhmahruai"), the table of contents, and the "Ka lehkhabu" personal-details fill-in page, per instructions.

## Method

1. Read all 61 pages via the Read tool's `pages` parameter (≤20 pages/call).
2. Skipped front matter and the personal-details page.
3. Went through all three lessons' picture-labeled vocabulary pages, phonics/letter-drill word lists (A–Z consonant clusters), the animal-name page, the kitchen/food word table, the fairground/market spread, and the two riddle pages, page by page.
4. Cross-checked every candidate word against (a) the app's core exclude list (exact match, case- and diacritic-sensitive) and (b) the Kumtluang Class I word list (case-insensitive, first-token match for compounds), programmatically, to avoid duplicates. Three initially-drafted words were caught and removed this way: **Sakawr** (horse) and **Dum** (black) are exact matches already in the core exclude list; **Ser** (iron/metal) matches Kumtluang Class I's "ser". Two compound words (**Tui um** "water pot", **Au rinna** "microphone") share a first token with a Kumtluang Class I root (tui, au) but are distinct multi-word lexical items, so they were kept.
5. Wrote one CSV row per new word, with all `meaning_mizo` and `example_mizo` sentences composed from scratch (nothing copied or paraphrased from the book's own sentences/exercises).

## Word count

**91 rows** in the final CSV — smaller than a full Kumtluang grade book, as expected for a 3-lesson, 54-printed-page absolute-beginner literacy primer. A large share of the primer's page count is arithmetic drills (addition/subtraction, money counting, number tracing) and comprehension questions rather than new vocabulary, so no attempt was made to force extra words out of those pages.

## VERIFY list (words flagged for human language review, with reason)

- **Mipui** — exact nuance ("the public" vs. "a crowd") not fully confirmed from context.
- **Ipte** — exact craft/weave term for the woven bag unconfirmed.
- **Diar** — exact style/occasion of headscarf wear unconfirmed.
- **Bulbawk** — exact species/local variety of radish unconfirmed.
- **Sazuk** vs **Sakhi** — two deer words appear on the same animal page; kept both but flagged to confirm the sakhi/sazuk distinction (barking deer vs. sambar/antlered deer).
- **Hauhuk** — asked for confirmation this is the standard term for hoolock gibbon.
- **Uchang, Perek, Tengte, Belthleng, Zikhlum, Phengphehlep, Chhuatphah, Chhang** — food/plant words pulled from a phonics word list (pp. 28, 46, 47) or kitchen-items table (p. 46) with no picture; exact species/translation not confirmed. Phengphehlep and Chhuatphah in particular I could not confidently translate at all — flagged strongly.
- **Thirbel, Tui um, Berul, Chawtani, Dawhkan, Kawi, Emping, Kawtthler, Nawlhbawk, Zawrhna, Tuikhur** — object words with translations inferred from context/compound structure (or, for Chawtani and Dawhkan, inferred from riddle answers on p. 27) rather than a direct picture label; flagged for confirmation.
- **Fu** — possible overlap/confusion with Kumtluang Class I's "fû" (chaff/husk); the primer's own diacritic on this word was not legible enough to be certain it means "flour."
- **Zâwngte** — flagged to confirm this is the standard noun for "monkey" and to distinguish it from the unrelated verb "zawng" (to search).
- **Hlimhla** — flagged heavily. This word only appears as a riddle answer ("I always follow you but you cannot catch me"); I have guessed "shadow" but this is genuinely uncertain and could be wrong.
- **Lawngpar** — a flowering plant appearing only in an isolated phonics list; exact species unconfirmed.
- **Intihhlimna, Lirthei, Tawlailir, Inkawm, Au rinna** — fairground/communication compound words where the general sense is fairly clear from the accompanying picture, but the precise scope of the translation (e.g., "vehicle" vs. specifically "car"; "microphone" vs. "megaphone/loudspeaker") is not certain.

No word was found to require a **culture-sensitive** flag (chieftainship, pasaltha/warrior culture, khuavang/spirit-folklore, ceremonial/craft practice, or death/mourning customs). One image on p. 43 that I initially worried might be a traditional hunting snare turned out to be captioned "Ṭhi," which is an exact match to Kumtluang Class I's "ṭhi" and was excluded as a duplicate before any meaning judgment was needed.

## Deliberately skipped / not glossed

- **Unlabeled matching-exercise pictures** (pp. 16, 18, 22, 23) where the book leaves the answer blank for the student to fill in (e.g., an eagle, a powder horn, a traditional headdress, a hat, a hula-hoop, a fish, a tongs, a wristwatch/clock, several fruits/vegetables). Since the book itself does not provide the intended word, I could not verify what word was intended and did not fabricate one, per the copyright/safety rules.
- **Pure English loanwords** used as-is in the book (Radio, Television, Telephone, Computer, Calculator, Balloon, e-mail, Pen, Pencil, Jam, Ball, Grep/grape, Bag, Apple, Toothpaste, Tomato, "mobile phone") were left out of the vocabulary set as a quality choice — they are not meaningfully distinct Mizo vocabulary for a language-learning app, even though they appear as picture-labeled items in the book.
- **Words already in the app's core exclude list or the Kumtluang Class I list** were skipped even where the book's spelling used a different diacritic than the exclude list (e.g., "Chhungkua" vs. excluded "Chhûngkua"; "Ngun" vs. Kumtluang's "ngûn"; "Rul" vs. Kumtluang's "rûl"; "Savawm" is an exact Kumtluang Class I match; "Awle," "Beng," "Phiat," "Su," "No" are exact Kumtluang Class I matches; "Van" vs. excluded "Vân"; "Bawng" vs. Kumtluang's "bâwng") — treated as the same underlying word with inconsistent typesetting rather than a genuinely new word.
- **Plural/suffixed forms of already-known roots** (e.g., "Naupangte," which is just "Naupang" + plural suffix, and "Naupang" is already core vocabulary) were skipped rather than counted as new words.
- **A handful of very low-confidence single tokens** from isolated phonics word lists with no image, translation, or usable context at all (e.g., a short list including tokens I could not even confidently identify as real standalone Mizo nouns from context) were left out entirely rather than guessed, to avoid seeding the database with fabricated meanings — this is a small, deliberately conservative cut, distinct from the VERIFY-flagged words above (which I was reasonably able to place a plausible meaning on).
- **Narrative/exercise sentences** (the "Berampu leh chinghne thu" wolf-fable story, the personal letter to "Pa," the riddle prompts, the comprehension questions) were read only to identify vocabulary tokens (e.g., "beram" = sheep, "chinghne" = wolf) — no sentence or phrasing from the book was copied or paraphrased into any `meaning_mizo` or `example_mizo` field.
