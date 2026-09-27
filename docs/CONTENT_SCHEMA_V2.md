# Thumal Quest — Content Schema V2

**Status:** Proposed / Phase 0  
**Machine-readable schema:** `content/schema/content_item.schema.json`

## Goals

Schema V2-in content text chauh ni lovin a dikna, source, learner level, rights,
review leh release history a keng tûr a ni. Flutter app, Rails Editorial Studio
leh offline content pack-ten contract thuhmun an hmang ang.

## Design rules

- Stable opaque `id`; display text chu ID atan hmang lo
- Item edit tin immutable revision number thar
- Content language BCP-47 code; Mizo primary code `lus`
- Word sense hrang tin ID hran
- Review and publishing are separate
- Audio/image rights and provenance first-class fields
- Unknown field reject in release validation
- Dates ISO 8601 UTC

## Core entity

| Field | Type | Required | Note |
|---|---|:---:|---|
| `schema_version` | string | Yes | `2.0` |
| `id` | string | Yes | e.g. `word.in.house` |
| `revision` | integer | Yes | Starts at 1 |
| `type` | enum | Yes | word, sentence, question, spelling, audio, story, culture |
| `language` | string | Yes | `lus` for Mizo |
| `status` | enum | Yes | draft → approved/published etc. |
| `content` | object | Yes | Type-specific text/data |
| `learning` | object | Yes | TQ level, skills, age, tags |
| `variants` | array | Yes | Can be empty |
| `provenance` | object | Yes | Source, author, machine assistance |
| `rights` | object | Yes | License and consent |
| `reviews` | array | Yes | Approval records |
| `release` | object | No | Pack/version/active window |
| `created_at` | datetime | Yes | UTC |
| `updated_at` | datetime | Yes | UTC |

## Word content

```json
{
  "canonical_form": "In",
  "normalized_search": "in",
  "sense_key": "house",
  "part_of_speech": "noun",
  "definition_mizo": "Mihring chenna hmun.",
  "glosses": {"en": "house"},
  "examples": ["sentence.in.house.001"],
  "image_asset_id": "image.in.house.001",
  "audio_asset_ids": ["audio.word.in.house.001"]
}
```

## Learning metadata

```json
{
  "tq_level": "TQ0",
  "age_floor": 5,
  "age_ceiling": null,
  "skills": ["vocabulary", "reading", "listening"],
  "categories": ["home", "daily-life"],
  "difficulty": 1,
  "sensitive": false,
  "cultural_review_required": false,
  "game_modes": ["picture_match", "listen_pick", "spelling"]
}
```

## TQ level ladder

`tq_level` is an 8-tier enum, `TQ0` through `TQ7`. Since 2026-09-16 the ladder
is anchored to the SCERT Mizoram "Kumtluang" Class I-VII textbook series
(the official state curriculum), not an internally invented progression:

| `tq_level` | Anchor | Approx. vocab target | Note |
|---|---|---:|---|
| `TQ0` | Thumal Quest core / diaspora onboarding | — | Hand-curated starter tier for absolute-beginner and diaspora learners; predates the Kumtluang anchor and is kept separate on purpose (see below) |
| `TQ1` | Kumtluang Class I | ~800 | |
| `TQ2` | Kumtluang Class II | ~1000 | |
| `TQ3` | Kumtluang Class III | ~1300 | |
| `TQ4` | Kumtluang Class IV | ~1500 | |
| `TQ5` | Kumtluang Class V | ~2000 | |
| `TQ6` | Kumtluang Class VI | ~2500 | |
| `TQ7` | Kumtluang Class VII | ~3000 | |

`difficulty` (`learning.difficulty`) was widened from a 1-5 range to 1-7 to
stay aligned with the 8-tier ladder.

**Why `TQ0` is not folded into the Kumtluang tiers:** `TQ0` holds the
original hand-curated pilot/onboarding vocabulary (diaspora-facing, not
grade-bound) and is deliberately left as its own tier rather than merged
into `TQ1`. Every `TQ1`-`TQ7` item, by contrast, should eventually trace to
(or be cross-referenced against) a Kumtluang class word list.

**Reconciliation of pre-Kumtluang content (2026-09-16):** `pilot_candidates.csv`
and `diaspora_expansion_candidates.csv` predate the Kumtluang dataset and were
tagged `TQ0`-`TQ3` by hand. Each `TQ1`-`TQ3` row was cross-referenced
(case-insensitively) against the deduped Kumtluang master word list
(`content/pilot/kumtluang/kumtluang_vocab_master_deduped.csv`):

- A match at a **different** grade was moved to that grade, with a
  `notes` entry recording the old and new `tq_level` and the date.
- A match at the **same** grade got a `notes` entry confirming it.
- A **non-match** kept its existing number but was flagged in `notes` as
  "Provisional: not yet grade-verified against Kumtluang curriculum" —
  these still need a native-speaker/curriculum pass before they can be
  treated as grade-confirmed.
- `TQ0` rows were left untouched entirely; `TQ0` is not part of the
  Kumtluang cross-reference.

See `content/pilot/kumtluang/README.md` and
`content/pilot/CHANGELOG_TQ_RECONCILIATION_2026-09-16.md` for the full
word-level detail and rationale.

## Variant model

```json
{
  "form": "...",
  "kind": "accepted",
  "register": "colloquial",
  "region": null,
  "note_mizo": "...",
  "reviewed": true
}
```

`kind` values:

- `accepted`: Correct alternative accepted in answers
- `display`: Preferred form for a learner segment/register
- `search_alias`: Search/typing aid, not taught as canonical
- `common_error`: Not accepted; feedback explanation available

## Provenance model

| Field | Meaning |
|---|---|
| `source_type` | council, dictionary, curriculum, author, oral, machine_draft |
| `source_title` | Human-readable source |
| `source_locator` | Page/entry/recording reference; not necessarily public URL |
| `contributor_id` | Internal contributor ID |
| `machine_assisted` | Boolean |
| `machine_service` | e.g. `google_cloud_translation`, nullable |
| `machine_checked_at` | UTC datetime, nullable |
| `notes` | Editorial context |

Machine-assisted content cannot validate to `approved` unless two qualifying
human approval records are present.

## Review record

```json
{
  "stage": "language",
  "decision": "approved",
  "reviewer_id": "reviewer.language.001",
  "reviewed_revision": 1,
  "reviewed_at": "2026-09-13T00:00:00Z",
  "note": ""
}
```

Required stages:

- Ordinary word/sentence/question: `language` + `learning`
- Culture/sensitive item: `language` + `learning` + `cultural`
- Audio: `language` + `audio`; linked text revision must match

## Rights model

```json
{
  "license": "project-owned",
  "copyright_holder": "Thumal Quest contributor",
  "consent_record_id": null,
  "commercial_use_allowed": true,
  "derivatives_allowed": true,
  "attribution": null,
  "expires_at": null
}
```

Empty/unknown rights cannot publish. Public-domain claim also requires source.

## Release pack manifest

```json
{
  "pack_id": "core.tq0.en-support",
  "version": "2026.09.1",
  "schema_version": "2.0",
  "minimum_app_version": "0.4.0",
  "created_at": "2026-09-13T00:00:00Z",
  "item_count": 100,
  "sha256": "<generated digest>",
  "signature": "<server signature>",
  "items": ["word.in.house@1"]
}
```

Client update algorithm:

1. Download manifest
2. Verify supported schema/minimum app version
3. Download to temporary location
4. Verify size, SHA-256 and signature
5. Validate every item and dependency
6. Transactionally activate new pack
7. Keep previous known-good pack for rollback

## Mapping from current prototype

| V0.3 field | V2 destination | Migration note |
|---|---|---|
| `id` | `id` | Prefix type and sense |
| `word` | `content.canonical_form` | Preserve Unicode |
| `meaningMizo` | `content.definition_mizo` | Human review |
| `englishGloss` | `content.glosses.en` | Sense-specific |
| `exampleMizo` | Linked sentence entity | Separate revision/review |
| `emoji` | Image/semantic asset | Do not treat as canonical image |
| `category` | `learning.categories` | Controlled vocabulary |
| `difficulty` | `learning.difficulty` + `tq_level` | Recalibrate |
| `review` | `status` + `reviews` | No automatic approval migration |

All existing `prototypeChecked` and `reviewRequired` items migrate to `draft`.
There is no grandfathered public approval.

## Rails/Flutter contract

- Rails owns authoring, review, revision, pack publication and audit.
- Flutter owns cached read model, session use and local learner progress.
- JSON Schema validates interchange; domain models use generated/manual typed
  adapters.
- API never serves draft content to a production learner channel.
- Content IDs are stable across corrections; revision identifies exact text.

## Validation gates

- JSON Schema valid
- Referenced sentence/audio/image IDs exist
- Status/review invariants valid
- Rights complete
- Language `lus` content not empty
- TQ level and at least one skill assigned
- Approved question has exactly one correct answer
- Release pack contains only approved/published revisions

