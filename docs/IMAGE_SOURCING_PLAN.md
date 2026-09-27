# Image Sourcing Plan

**Status:** Draft, 2026-09-16. Audio-independent, does not block or depend on
Phase 4C staging work.

## Current state (corrects an earlier assumption)

Picture Match does **not** render from a missing/empty image pipeline — it
already renders `WordEntry.emoji` directly:

```dart
// lib/src/games.dart, PictureMatchGame.build
Text(entry.emoji, style: const TextStyle(fontSize: 78))
```

`emoji` is a required field on `WordEntry` (`lib/src/data.dart`) and is
carried through the synced/delivered catalog too
(`QuestController.wordCatalog` in `lib/src/controller.dart` maps
`DeliveredWord.emoji` straight into it). So every word that has an emoji
assigned is already playable in Picture Match today, at zero engineering or
asset cost. This is a real, working MVP solution, not a placeholder that
silently does nothing.

**What it doesn't solve:**

- Culturally specific Mizo items have no Unicode emoji at all (traditional
  food, woven cloth, cultural concepts). These are the actual gap.
- Cross-platform emoji rendering is inconsistent (Apple/Google/Samsung draw
  emoji differently) — a brand-consistency problem for a "premium" feel.
- Some concepts (abstract feelings, in-law kinship terms, compound numbers)
  don't have a good 1:1 emoji at all; whatever's assigned is a rough
  placeholder.
- `image_asset_id` is already a defined field in Schema V2
  (`docs/CONTENT_SCHEMA_V2.md`) and `content/pilot/sample_word_item.json`,
  but nothing in the Flutter client or backend actually reads or serves it
  yet — it's unused today.

## What was just done (2026-09-16)

All 83 words in `content/pilot/diaspora_expansion_candidates.csv` now carry
an `emoji` column, so they're synced-catalog-ready as soon as they clear
review — same mechanism the existing 100-word set will presumably need too
(check whether `pilot_candidates.csv` already has emoji assignments
somewhere in the Editorial Studio backend; if not, it has the same gap).

**12 words had no usable single-emoji match** — this is the real, concrete
priority list for custom illustration, not a guess:

| Word | Gloss | Why no emoji |
|---|---|---|
| Bekang | Fermented soybean | Culturally distinctive food, no Unicode equivalent |
| Sawhchiar | Traditional rice dish | Culturally distinctive food, no Unicode equivalent |
| Puan | Traditional woven cloth | Culturally significant, no Unicode equivalent |
| Mizo | The people/identity | Identity term — a generic/flag emoji would misrepresent it; needs a deliberate, culture-reviewer-chosen visual |
| Sawmkhat | Eleven | No clean single glyph for compound numbers past 10 |
| Sawmhnih | Twenty | Same |
| Lu | Head | No isolated "head" glyph |
| Sam | Hair | No isolated "hair" glyph |
| U | Older sibling | Kinship term, not a picturable object |
| Makpa | Son-in-law | Kinship term, indistinguishable from generic "man" emoji |
| Monu | Daughter-in-law | Kinship term, indistinguishable from generic "woman" emoji |
| Awm | Stay/exist/be | Abstract verb — not really a Picture-Match candidate at all; keep it to listen_pick/spelling/word_chain and don't force an image |

A handful more got a "rough placeholder, consider upgrading" flag directly
in the CSV `notes` column (e.g. Hmai/face using a generic smiley, Chhuah/Lut
using approximate action emoji, Hmar/Chhim using plain arrows instead of a
compass) — lower priority than the 12 above, since they at least communicate
something reasonable today.

## Sourcing options

| Option | Best for | Trade-off |
|---|---|---|
| **A. Commission a Mizo/diaspora illustrator** | Highest-visibility cultural items: Culture Cards, app branding, Puan/Bekang/Sawhchiar, the "Mizo" identity visual | Most authentic, doubles as community economic support and a launch-communications story (`docs/MASTER_ROADMAP.md` mentions "reviewer credits"); slowest and has a real cost |
| **B. AI-generated illustration set with a locked style prompt** | Everything else that needs an upgrade past emoji | Fast and cheap; **must** go through the same culture-reviewer sign-off as text content before shipping — no unreviewed AI image ships, mirroring the existing no-self-review text policy |
| **C. Open-license flat-icon library** | Fully generic/universal items where cultural specificity doesn't matter (numbers, weather, basic shapes) | Fastest and free; wrong choice for anything Mizo-specific — would look like generic stock art exactly where authenticity matters most |

**Recommendation:** blend the three rather than pick one — C for the
universal filler, B as a fast first pass for the broad "upgrade from emoji"
work with mandatory culture-reviewer approval per image, A reserved for the
dozen highest-visibility cultural/identity items where it matters most.

## Rollout order

1. **Now / zero-cost:** finish emoji-tagging the rest of the pilot corpus
   (the original 100 words, if they don't already have emoji in the backend)
   so the whole reviewed set is playable in Picture Match without waiting on
   any art.
2. **Next, highest leverage:** commission or AI-generate the 12-item
   no-emoji list above, since those are actual gaps emoji cannot fill —
   start with Puan, Bekang, Sawhchiar and the Mizo identity visual (Option A
   candidates), then the kinship/number/abstract items (Option B).
3. **Later, full polish pass:** once the reviewed catalog is larger (see
   `diaspora-dataset-plan.md`), consider replacing emoji broadly with a
   consistent custom illustration set for full brand consistency
   (`docs/ui_design_system.md` tokens: Midnight/Navy/Indigo/Teal/Gold). This
   is genuinely nice-to-have, not blocking — emoji already works.

## Rights and schema

Reuse the same rights/provenance discipline the audio pipeline already
requires (`docs/CONTENT_SCHEMA_V2.md` `rights` object: license, consent
record, commercial-use flag) for every commissioned or AI-generated image —
don't invent a separate lighter-weight process for images just because
they're not language content. Wire the currently-unused `image_asset_id`
field through the delivery/sync pipeline once there's real art to point it
at; until then, `emoji` remains the correct, already-working mechanism.

## Execution log — 2026-09-16

First pass done. 7 of the 12 no-emoji words got a real custom flat-illustration
(SVG source + 192x192 PNG export), following the rollout order above:

- `assets/illustrations/word.{sawmkhat,sawmhnih,lu,sam,bekang,sawhchiar,puan}.{svg,png}`
- Wired into the client: `lib/src/data.dart` gained `wordIllustrations`
  (normalized-word -> asset path map), and `PictureMatchGame._pictureFor()`
  in `lib/src/games.dart` now shows the illustration when one exists,
  falling back to `entry.emoji` otherwise (zero new dependencies — plain
  `Image.asset`, no `flutter_svg`). Registered in `pubspec.yaml`.
- `Puan`'s illustration deliberately shows the textile's own real
  striped-weave pattern (not a generic cloth icon, not a depicted person) —
  **this one specifically should get a look from an actual Mizo
  reviewer/community member before it ships**, given it represents a
  culturally significant object. The other 6 are lower-stakes generic/food
  shapes.
- The remaining 5 of the original 12 were **not** illustrated, on purpose:
  - `Mizo` — still deferred to the culture reviewer, per this plan's own
    recommendation. Building an "identity" visual unilaterally would be the
    wrong way to close this gap.
  - `Awm` — confirmed not a Picture Match concept at all (abstract
    existential verb); left on listen_pick/spelling/word_chain only.
  - `U`, `Makpa`, `Monu` — on inspection, a picture genuinely can't
    distinguish "older sibling" / "son-in-law" / "daughter-in-law" from a
    generic person or from each other. `game_modes` for these three was
    corrected in `content/pilot/diaspora_expansion_candidates.csv` to drop
    `picture_match` rather than ship a misleading image.

Net: 7 illustrated + 3 correctly excluded from Picture Match + 2 correctly
deferred, rather than 12 forced illustrations of uneven quality.

## Execution log — 2026-09-27

- Every live word's emoji was checked against its English gloss.
  `content/pilot/emoji_corrections_2026-09-27.json` holds 99 fixes (wrong
  emoji replaced, missing-but-obvious emoji added, and misleading ones such as
  puan types shown as 🧣 or silhfen as 👘 removed). Applied with
  `bin/rails editorial:apply_emoji_corrections` (display-only change: prior
  approvals re-recorded) and shipped in content pack 1.0.3; source CSVs were
  updated to match.
- The client no longer shows a category symbol for words without a picture;
  `WordPicture` shows illustration → emoji → neutral initial-letter tile, and
  Picture Match only uses words with a real picture (`hasWordPicture`).
- 21 open-licence icons (game-icons CC BY 3.0, Tabler MIT, MDI Apache 2.0)
  were added for concrete, non-culture-specific words with no emoji (gong,
  sickle, table, scarecrow, fishing net…), keyed by stable id in
  `wordIllustrationsById`. Sources/licences: `assets/illustrations/ATTRIBUTION.md`.
- Still no good open art for Mizo-specific items (puan types, hornbill,
  bamboo traps and baskets, winnowing tray, granary) — these remain for
  option A/B above with culture-reviewer sign-off.
