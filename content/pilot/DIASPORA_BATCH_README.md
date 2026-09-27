# diaspora_expansion_candidates.csv — scope note

83 AI-drafted candidate words, generated 2026-09-16, additional to the
existing 100 in `pilot_candidates.csv`. Same status/review columns and same
rule: **draft, unreviewed, not release-ready** until a qualified Mizo language
reviewer (and culture reviewer where noted) signs off, per
`docs/CONTENT_EDITORIAL_GUIDE.md`.

Weighted toward the diaspora/heritage-learner priority persona (Mika,
`docs/LEARNER_PERSONAS.md`): family, home, daily-life, food, greetings,
feelings, colors, body parts, numbers 4-100 — categories that were thin in
the original 100-word set.

Extra columns beyond the original schema: `english_gloss`, `meaning_mizo`,
`example_mizo`, `difficulty`, `game_modes` (pipe-separated: picture_match,
spelling, word_search, word_chain, thumal_kawp, sentence_builder) — carried
over from `content/pilot/sample_word_item.json`'s `learning.game_modes`
field, so a reviewer/engineer can see which games each word is meant for
without re-deriving it.

**17 of the 83 rows carry a `VERIFY:` note** in the `notes` column — genuine
uncertainty about spelling, exact sense, or register (mostly deeper kinship
terms, a few colors, and two or three abstract words). Treat those as lower
confidence than the unflagged rows. 3 rows are flagged
`cultural_review_required=true` (bekang, sawhchiar, puan) since they name
specific cultural items, not just generic vocabulary.

Fastest way to close the remaining VERIFY flags and grow past this batch: a
short structured session with one native speaker going row-by-row through the
`notes` column, rather than more AI-generated guesses.

This is the "diaspora-weighted, game-ready dataset" work item from the
project's own `professional-polish-plan.md` / `diaspora-dataset-plan.md`
(see the attached Claude project "Thumal Quest").
