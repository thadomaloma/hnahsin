# Kumtluang Class VII — Deep Vocabulary Extraction Report

## Scope and method

- **Source:** *Kumtluang* Class VII (SCERT Mizoram), 180-page PDF, read directly page-by-page with the Read tool (`pages` parameter, ≤20 pages per call), covering the entire book from front matter through the final lesson (Zirlai 29, "Liandova-te Unau").
- **Pages examined:** All 180 pages. Pages 1–~14 are front matter / curriculum notes / grammar preface (skimmed, minimal vocabulary). Content lessons run from Zirlai 1 (page ~1 of the numbered body) through Zirlai 29 (ends at the book's final numbered page, 166 in-book / 180 PDF).
- **Method:** For each lesson, running text (poems, fables, essays, dialogues, a folk legend) was skimmed for topic/theme only — never transcribed. Vocabulary was pulled from:
  - Explicit lesson-end word boxes ("Thu pawimawhte") not caught by the first pass, including several that were phrased as open activity prompts ("Heng hi sawi fiah rawh: …") rather than boxed lists.
  - "Thu har hrilh fiahna" / "Hla thu hrilh fiahna" hard-word glossaries attached to poems and prose pieces — several lessons (the Reiek-trip zawlbûk-architecture lesson, the Chhûra poem, the Liandova-te Unau legend, the Siamtu Remruat poem, the patriotic essay "Mizoram hi ka ram a ni") carry dense glossaries of this kind that the first, word-box-only pass would have missed entirely.
  - Picture-labeled vocabulary: a cancer/anatomy diagram (Zirlai 10) and the traditional-instruments lesson (Zirlai 19), which has photographs of each instrument.
  - Context words from dialogue/narrative that could be confidently glossed without reproducing the story's sentences (e.g., animal names in the wolf fable, wildlife-dialogue vocabulary, essay abstractions).
  - A pronoun-lesson list of emphatic particles was seen but only partially mined (see "Deliberately skipped" below).
- Every `meaning_mizo` and `example_mizo` was freshly composed; none reproduces book sentences.

## Result

- **227 new candidate rows** written to `kumtluang_class7_deepen.csv` (distinct from all words in the provided exclude lists — checked programmatically against both lists, case- and diacritic-sensitive, zero collisions in the final file; one accidental collision, `hnahtum`, was caught and removed during a verification pass).
- Category spread: verbs 37, values 38, traditional_culture 39, idiom 34, nature 26, adjectives 14, animals 13, tools 12, community 7, body_parts 4, food 3.

## VERIFY-flagged items (uncertain meaning/spelling/species — 22 rows, non-culture)

Flagged with a specific reason in their `notes` field, for language-review follow-up:
- `hmatiang`, `sîrva` (bird species), `sakeibaknei` (species precision), `sazuk` (deer species), `khâu` (species), `choâk` (spelling), `siahthing` (tree species), `thlang` (directional sense vs. common "hillside" meaning), `virthli` (poetic usage), `phalhauh`, `chenchilhtu` (nuance), `namnûl`/`hlâng` were considered but dropped entirely (see below, not included) while `hleitling`, `insuknawr`, `inchhawn`, `indaikhalh`, `zualko`, `inphawi`, `kawtchhuah`, `tlangau` (traditional-wrestling/community terms inferred from limited narrative context, several also culture-flagged), `sûlsutu`, `chaldâr`, `tluk loh rim nam`, `kaiza veng`, `hahip` (Taitesena hunting-story terms, low-to-moderate confidence, inferred from context rather than an explicit gloss), `chhah` (paired opposite of an excluded word in a grammar list), `nâkalai`, `Farṭuah` (tree species), `kaina`, `pitar` (creature identity).

## Culture-sensitive flags (40 rows — route to human culture reviewer)

This class's material goes noticeably deeper into traditional culture than earlier grades' word boxes suggested, consistent with the note that Class VII would likely surface more items like "khuavang":

- **Spirit-folklore / khuavang-adjacent:** `sichangneii` (fairy/spirit maiden), `huai`, `ramhuai`, `chenchilhtu` (mountain/place guardian spirits, Reiek-trip lesson), `khuavang ri kham sa` (idiom for an eerie mountain sound attributed to a spirit), `saphâi` (mythical spirit-bird from the Liandova legend), `pitar` (a small creature tied to khuavang lore in the same legend).
- **Death/mourning customs:** `awmni kham` (a village rest-day declared for a death), `zualko` (a death-related community announcement custom), `ruang` (corpse), `piallei kara` (idiom for "in the grave").
- **Historical warfare / headhunting:** `ral lu aih` — a traditional victory celebration involving an enemy's severed head, from the musical-instruments lesson's closing glossary. This is the single most sensitive item found in this pass.
- **Chieftainship / pasaltha / ceremonial:** `mi hrâng` (pasaltha/warrior), `bahzâr`, `dawvân`, `âwkpakâ`, `bawhbel`, `sût`, `tap chep sût` (traditional zawlbûk and chief's-house architecture terms from a dedicated glossary), `khuang hlâng` (khuangchawi ceremonial carrying platform), `man leh mual` (bride price), `chawn leh lâm` (traditional feast/dance), `kûtni vângthla` (festival calendar).
- **Traditional craft/instrument practice:** `kângvâr` (pine torch), `rapchung`, `sum` (mortar), `kâwlkhuang`, `darmang`, `mau tawtawrawt` (traditional instruments), `liang` (defensive barricade), `sahmîm` (fur blanket), `sûlsutu` (torch-bearer), `chhiahhlawh` (a historical servant/hired-help social role).
- **Traditional wrestling (inbuan) custom:** `hleitling`, `insuknawr`, `inchhawn`, `indaikhalh`, `inphawi`, `kawtchhuah`, `tlangau` (village crier).

None of these are fabricated — each is drawn from an explicit word box, an explicit glossary entry, or a clearly identifiable narrative reference; where the book gave an explicit gloss (e.g., the zawlbûk-architecture and musical-instrument glossaries), that was used as the basis for the (independently written) `meaning_mizo`.

## Deliberately skipped / not glossable with confidence

- **Emphatic-particle list** (Zirlai 9, Pronoun lesson): `chauh, chiah, êm, ngawt, ngei, angiang, hial, lehzel, mawlh, riak, tak, takngial, tehlul, teivet, ve, zet`. These are grammatical emphasis particles rather than content words; only a couple have clean, standalone glosses usable in a vocabulary app, so the whole set was left out rather than force a partial, arbitrary selection.
- **Compound animal-name riddles** (Zirlai 9, exercise 7: `hnawmtinphurinu, thiamthainumawngtawlh, kawngkawrawi, ketaminu, vangvatsaiṭial, khawmualkaikuang`) — these are word-puzzle compounds meant to be decomposed by students, not standalone lexical items; skipped as ungloss-able without guessing.
- **`namnûl` and `hlâng`** (Inbuan/wrestling word box, Zirlai 12) — listed in the lesson's word box with no definition given and no usable context elsewhere in the lesson; dropped rather than guessed, per the "skip if truly cannot gloss" rule.
- **`favah` and `hachhek`** (a tool-usage exercise near the golden-axe fable) — likely traditional tool names, but with no context strong enough to responsibly gloss; skipped.
- **`sihal`, `pangang`, `sazupui`** — ambiguous fable/context words (wolf story and an animal-speed comparison list) that could not be parsed into a standalone word with confidence; skipped.
- Large blocks of purely grammatical content (pronoun paradigms, adjective-type explanations, direct/indirect speech rules, "tawngkam hman dik loh thenkhatte" usage-pair lesson) were treated as grammar instruction, not vocabulary, and only the handful of genuine content nouns embedded in them (e.g., `tarmit` was considered but is a fairly transparent compound of already-common words and was left out for being marginal) were extracted.

## Files produced

- `/tmp/tq_deepen/kumtluang_class7_deepen.csv` — 227 vocabulary rows, header included, schema as specified.
- `/tmp/tq_deepen/kumtluang_class7_deepen_report.md` — this report.
