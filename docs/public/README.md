# `docs/public/` — Static Assets Only

**Status:** Active (PWA assets + Astro static directory)

This directory contains static files served by the Astro docs site at:
- `https://iberi22.github.io/OrionHealth/`

## Contents

| File/Dir | Purpose |
|----------|---------|
| `.nojekyll` | Disables Jekyll processing on GitHub Pages |
| `robots.txt` | SEO crawler directives |
| `favicon.svg`, `apple-touch-icon.png`, `android-chrome-*.png` | PWA icons |
| `hero-image.png` | Landing page hero |
| `screenshots/` | Screenshots used in marketing/docs pages |

## What does NOT belong here

Previously this directory also contained `*.json` medical-standards data files
(`icd10.json`, `loinc.json`, `rxnorm.json`, `snomed.json`, etc.) that were
duplicated with `docs/src/data/medical-standards.json`.

In Wave 9 (issue #1670), those duplicates were moved to
`docs/legacy/public-deprecated/` because the Astro build now reads exclusively
from `docs/src/data/`.

If you need to add new medical standards:
1. Update `docs/src/data/medical-standards.json` (source of truth)
2. Run `npm run build` in `docs/` to regenerate the static site
3. Do NOT add new JSON files to this directory

Last reviewed: 2026-08-29 (Wave 9)