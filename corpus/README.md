# Evidence corpus

Policy and data for the evidence corpus used by the RAG pipeline.

## Files

| Path | Owner | Purpose |
|---|---|---|
| `ALLOWLIST.json` | owner-only | Sources, hosts, acquisition, record licences and text policy |
| `FUNDERS.json` | owner-only | Funder name/alias (ROR, Crossref ID when verified) to class |
| `SCHEMA.json` | owner-only | JSON Schema (draft 2020-12) for entry records and the manifest |
| `MANIFEST.json` | generated | Output of `scripts/corpus/build-manifest.mjs`; empty at `2026.43.0` |
| `entries/<source>/<yyyy>/<safe-id>.json` | refresh bot | One record per file (data-only) |
| `screenshots/<source>/<safe-id>.png` | refresh bot | Provenance, first viewport only (data-only) |

## Who may edit what

- Owner-only via `.github/CODEOWNERS`: `corpus/ALLOWLIST.json`, `corpus/FUNDERS.json`, `corpus/SCHEMA.json`, `scripts/corpus/`, `.github/workflows/evidence-refresh.yml`, `.github/workflows/corpus-validate.yml`, `.github/jules/`.
- Jules and other autonomous agents are data-only: they may write `corpus/entries/**`, `corpus/screenshots/**` and regenerate `corpus/MANIFEST.json` through the build script. They must not touch any owner-only path.
- A PR that changes entries, screenshots or the manifest must change nothing else (validator rule 11).

## Allowlist

Only the sources in `ALLOWLIST.json` may enter the corpus. Vendor, sponsored, press-release and CME-sponsor pages are never allowed. MinSalud GPC and IETS stay off until their licences are checked.

## Funding admission

- `funding_class` is one of `public`, `nonprofit`, `mixed`, `industry`, `unknown`.
- `industry` is rejected.
- `mixed` is admitted with an amber badge and a rank penalty, and is flagged when it is the sole support for a sentence.
- `unknown` is admitted with a grey badge. Missing funding data is never labelled "independent".
- Funders map through `FUNDERS.json` by name, alias, ROR or Crossref ID. Do not invent IDs; leave them null until verified.

## content_sha256

`content_sha256` is the SHA-256 of the entry's canonical JSON: keys sorted, UTF-8, no whitespace. It is computed over the entry without `content_sha256`, `retrieved_at` and `screenshot`. When `text_policy` is `metadata_only`, `sections` must be `[]`.
