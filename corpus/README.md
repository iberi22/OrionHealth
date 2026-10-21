# Evidence corpus

Policy and data for the evidence corpus used by the RAG pipeline.

## Files

| Path | Owner | Purpose |
|---|---|---|
| `sources/registry.json` | owner-only | Source registry (replaces `ALLOWLIST.json`): id, country, issuer, hosts, ingest, licence, `storage_max`, priority, status |
| `sources/registry.schema.json` | owner-only | JSON Schema for the registry |
| `sources/expansions.json` | owner-only | Curated es/en/pt synonym and abbreviation groups for query expansion |
| `sources/state.json` | refresh bot | Per-source cursors (`{}` until the first run) |
| `FUNDERS.json` | owner-only | Funder name/alias (ROR, Crossref ID when verified) to class |
| `SCHEMA.json` | owner-only | JSON Schema (draft 2020-12), v2, for entry records and the manifest |
| `MANIFEST.json` | generated | Output of `scripts/corpus/build-manifest.mjs`; schema v2, empty at `2026.43.0` |
| `entries/<source>/<yyyy>/<safe-id>.json` | refresh bot | One record per file (data-only) |
| `screenshots/<source>/<safe-id>.png` | refresh bot | Provenance, first viewport only (data-only) |

## Who may edit what

- Owner-only via `.github/CODEOWNERS`: `corpus/sources/registry.json`, `corpus/sources/registry.schema.json`, `corpus/sources/expansions.json`, `corpus/FUNDERS.json`, `corpus/SCHEMA.json`, `scripts/corpus/`, `.github/workflows/evidence-refresh.yml`, `.github/workflows/corpus-validate.yml`, `.github/jules/`.
- Jules and other autonomous agents are data-only: they may write only `corpus/entries/**`, `corpus/sources/state.json` and `corpus/MANIFEST.json` (regenerated through the build script). They never edit the registry; new sources are proposed in the PR body as `propose-source | url | reason`. They must not touch any owner-only path.
- A PR that changes entries, screenshots or the manifest must change nothing else (validator rule 11).

## Source registry

Only sources in `sources/registry.json` may enter the corpus; entry `source` must match the id pattern `^(int|[a-z]{2})-[a-z0-9-]+$` and exist there. Each entry carries `country` (ISO-3166-1 alpha-2 or `INT`) and `issuer`. Vendor, sponsored, press-release, industry-funded and CME pages are never allowed (`status: blocked`). MinSalud GPC (`co-minsalud-gpc`) and IETS (`co-iets`) are included as `metadata_only` until their licences are verified. Effective text policy = min(`storage_max`, licence ceiling, NC gate); `text_policy` may be `fulltext`, `abstract` or `metadata_only`, and `extract` is a verbatim quote of at most 50 words or null.

## Storage: git vs Hugging Face

- **git** (`corpus/**`): registry, schemas, FUNDERS, expansions, state, MANIFEST and curated metadata entries (`storage.kind: git`). In git, `sections` is `[]` and `screenshot` is null.
- **HF** dataset `iberi22/orionhealth-evidence` (`storage.kind: hf`, with `repo` and `revision`): text sections, screenshots, bulk-source records and packs; manifest paths there look like `records/<source>/<yyyy>.jsonl.gz`.

## Funding admission

- `funding_class` is one of `public`, `nonprofit`, `mixed`, `industry`, `unknown`.
- `industry` is rejected.
- `mixed` is admitted with an amber badge and a rank penalty, and is flagged when it is the sole support for a sentence.
- `unknown` is admitted with a grey badge. Missing funding data is never labelled "independent".
- Funders map through `FUNDERS.json` by name, alias, ROR or Crossref ID. Do not invent IDs; leave them null until verified.

## content_sha256

`content_sha256` is the SHA-256 of the entry's canonical JSON: keys sorted, UTF-8, no whitespace. It is computed over the entry without `content_sha256`, `retrieved_at` and `screenshot`. In git, `sections` must be `[]`.
