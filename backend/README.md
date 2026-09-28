# Hnahsin Editorial Studio

Rails 8.1 + PostgreSQL backend for Mizo content editing, independent review,
immutable publishing, rollback and pack delivery. (Audio upload, review and
audio packs were removed on 2026-09-27.)

## Local setup

Install Ruby 3.3+, Bundler and PostgreSQL 16. From the repository root:

```bash
export EDITORIAL_ADMIN_EMAIL="you@example.org"
export EDITORIAL_ADMIN_PASSWORD="a-password-manager-generated-secret"
./run_backend.command setup
./run_backend.command
```

Open `http://localhost:3000`. Run the complete local gate with:

```bash
./run_backend.command check
```

Railway routes traffic only after `/ready` confirms PostgreSQL;
`/up` is liveness only. See `../docs/STAGING_DEPLOYMENT_RUNBOOK.md`.

Never commit `.env`, `master.key`, database dumps or reviewer passwords.

## Editing game content

Everything the mobile games show is edited in **Content → New draft** with
plain forms (no JSON needed):

- **Word** — word, Mizo meaning (the clue), English meaning, example sentence,
  category, level 1–7, which games use it, and its **picture**: an emoji or an
  uploaded PNG/JPEG/WebP (≤ 512 KB, stored in PostgreSQL). Picture Match and
  Thumal Kawp use the uploaded picture first.
- **Tawng Upa question** — question, four options, correct answer, explanation.
- **Game text** — per-game title, how-to-play steps, question text, hint and
  the shared “A dik e!” / “Tum leh rawh” feedback (`{word}`, `{gloss}`,
  `{answer}`, `{first}` placeholders). Empty fields keep the app defaults.
- **Sentence** — Sentence Builder sentences.

Open any item to change it with the same form (a new revision is created);
reviewers see a “What learners see” preview, including the picture, before
approving. Changes reach the app in the next published content pack.

**Which words each game uses.** A word's “Games that use this word” boxes
decide where it appears (no boxes = every game), and every game honours
them. In **Content**, the *Game* filter lists the words a game can actually
use (same rules as the app: Picture Match needs a picture, Crossword 3–7
letters, Word Chain single words…), *Picture → Words without a picture* finds words to illustrate, and
the bar above the list adds or removes a game for all selected words (each
gets a new revision for review). **Coverage** shows how many live items every
game has at each level and flags levels with fewer than five.

`bin/rails editorial:import_game_content` imports the app's built-in game
text, Tawng Upa questions, sentences and bundled pictures as drafts for review.

## Roles

- `editor`: creates immutable revisions and submits them.
- `language_reviewer`: decides language approval.
- `culture_reviewer`: decides cultural approval where required.
- `publisher`: releases approved revisions or publishes a rollback.
- `admin`: emergency/full operational role; self-review is still prohibited.

The public read-only API is described in `../docs/API_CONTENT_PACK_V1.md`.
