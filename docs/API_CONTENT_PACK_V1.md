# Thumal Quest Content Pack API V1

**Status:** Phase 4A core contract  
**Base path:** `/api/v1`  
**Audience:** Flutter content downloader; no learner account required

## Endpoints

| Method | Path | Result |
|---|---|---|
| `GET` | `/content_packs/latest` | Most recently published immutable pack |
| `GET` | `/content_packs/:public_id` | One published pack by public UUID |

Draft, in-review, approved-but-unpublished and unknown packs return `404`.
Editorial mutation endpoints are not part of this public API.

## Response

```json
{
  "id": "2f4e...",
  "version": "1.0.0",
  "checksum": "sha256...",
  "published_at": "2026-09-13T12:00:00Z",
  "manifest": {
    "schema_version": "1.0",
    "language": "lus",
    "pack_version": "1.0.0",
    "generated_at": "2026-09-13T12:00:00Z",
    "items": []
  }
}
```

The server sends `ETag`, `Last-Modified`, `X-Content-Checksum` and a short public
cache policy. Clients should send `If-None-Match`; `304 Not Modified` means the
active local pack remains valid.

## Client activation rule

1. Download to a temporary location.
2. Compute SHA-256 over the canonical manifest and compare the declared
   checksum.
3. Validate `schema_version`, `language == lus`, stable IDs and item checksums.
4. Atomically activate only after every validation succeeds.
5. If the network, checksum or schema fails, keep the last valid offline pack.

Phase 4A does not upload learner progress, identifiers or answers. Backend
outage must therefore never block lessons or games already available offline.

## Mobile word contract (Phase 4B)

For `content_type: "word"`, learner runtime fields live in `body`: `word`,
`meaning_mizo`, `english_gloss`, `example_mizo`, `emoji`, `category`, and an
integer `difficulty` from 1–5. Supported categories are `chhungkua`, `sikul`,
`nungcha`, `khawvel`, `nunphung`, and `thiltih`. The client switches from its
bundled fallback only when a reviewed pack provides at least 20 valid words,
including five beginner (`difficulty: 1`) words.
