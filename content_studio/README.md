# Hnahsin content Sheet

The app's words, Tawng Upa questions, Sentence Builder sentences and game
text are edited in a Google Sheet. **Hnahsin → 🚀 Chhuah** checks every row
and publishes the content pack to GitHub Pages, where the app downloads it
(same pack format as before: `docs/API_CONTENT_PACK_V1.md`). There's no server
or database to run.

- `Pack.js`: checks the rows and builds the pack. Problems are written in Mizo
  with their row number. No Google services, so it's tested in Node.
- `Code.js`: the Hnahsin menu, reading the sheet, pictures from Drive, the
  upload to GitHub, and **Sheet siam ṭha** (headings, dropdowns, checkboxes).
- `appsscript.json`: the Apps Script manifest.

Tests: `node --test content_studio/test` (run it with `UPDATE_FIXTURE=1` after
changing the pack format, then `flutter test test/sheet_pack_test.dart`).

## One-time setup (developer)

1. **Content repo.** Create a public GitHub repo (e.g. `hnahsin-content`) with
   one commit on `main`, and turn on Pages for `main` / root. Packs land at
   `https://<owner>.github.io/hnahsin-content/api/v1/content_packs/latest`.
2. **Token.** On GitHub go to Settings → Developer settings → Fine-grained
   tokens. Give the token access to that repo only, with
   *Contents: Read and write*.
3. **Sheet.** Signed in as the content account, open a blank Google Sheet
   and import the content (File → Import → Replace spreadsheet). The live
   sheet was made this way on 2026-10-01 from the retired Rails Studio's
   export; a backup of that database is outside the repo.
4. **Pictures.** After step 6, put the picture files (PNG, JPEG or WebP,
   512 KB at most) into the `Hnahsin thlalak` Drive folder that setup makes
   next to the sheet. Drag the files in, not a folder.
5. **Script.** In the sheet, open Extensions → Apps Script. Make the files
   `Pack.gs` and `Code.gs` and paste in `Pack.js` and `Code.js`. Paste the
   manifest into `appsscript.json` (turn on *Show "appsscript.json"* in
   Project Settings). Save, then reload the sheet.
6. **Hnahsin → ⚙️ Developer → Sheet siam ṭha**: this asks for permissions
   once, then adds checkboxes, dropdowns and pink highlights for empty
   required cells.
7. **Hnahsin → ⚙️ Developer → GitHub settings**: enter `owner/hnahsin-content`
   and the token.
8. **Hnahsin → 🚀 Chhuah** once, then build the app with
   `--dart-define=HNAHSIN_API_BASE_URL=https://<owner>.github.io/hnahsin-content`.

The editor's how-to is the sheet's **Kaihhruaina** tab (in Mizo).

## Rollback

Every publish also keeps `api/v1/content_packs/<version>.json`. To go back,
restore an earlier sheet version (File → Version history) and publish again.
In an emergency you can instead copy an older `<version>.json` over `latest`
in the repo.
