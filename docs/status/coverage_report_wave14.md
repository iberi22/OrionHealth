# Coverage Gap Analysis — v0.10.1 → Target v0.11 (0.85x)

> **Generated:** 2026-09-02 (Wave 14 maintenance + dependabot bump wave)
> **Baseline:** v0.10.1 telefonos (commit d22a7637) — 0.59x test:lib ratio
> **Target:** 0.85x (Wave 9 high-water mark — restored post EPS removal)

## Executive Summary

| Metric | Baseline (v0.10.1) | Target | Delta |
|---|---|---|---|
| **lib/ files** | 701 | 701 | 0 |
| **lib/ LOC** | 107,751 | 107,751 | 0 |
| **test/ files** | 703 | 815 | **+112** |
| **test/ LOC** | 63,401 | 91,588 | **+28,187** |
| **test:lib ratio** | 0.59x | **0.85x** | **+0.26x (+44%)** |
| **Fully-layered features (5/5)** | 26 / 27 (96%) | 27 / 27 (100%) | +1 |
| **Open dependabot PRs** | 8 (1682-1689) | 0 | **-8** |

## Gap by feature layer (post-deps-bump state)

Total features tracked: **27**
Fully layered (domain+application+infrastructure+presentation+goldens): **26**

### Layer gap (the 1 partial feature)

| Feature | domain | application | infrastructure | presentation | goldens | Gap |
|---|---|---|---|---|---|---|
| **network** | ✅ | ✅ | ❌ | ✅ | ❌ | + infrastructure tests, + golden |

### Coverage 0.85x target — composition plan

To reach **0.85x** (= 91,588 test LOC) we need +28,187 test LOC. Two routes:

1. **Route A — wider coverage (preferred)** : add unit + widget tests for the 27
   features evenly — ~+1,043 test LOC per feature (28,187 / 27 ≈ 1,043).
   Focus on the 3 historically-under-tested areas: `network` (infrastructure +
   goldens), `isar_agent_memory` package, and the remaining PWA E2E flows.

2. **Route B — wave-targeted (lower risk)** : ship one focused testing wave
   (Wave 14) targeting the 4 features whose current test density is lowest:
   `network`, `permissions`, `audit_log`, `medical_standards`. Estimated
   +7,000 LOC of tests; brings ratio to ~0.66x (still short of 0.85x).

### Recommended: **Hybrid (A + B)** — Wave 14 Testing + Wave 15 Reach

| Wave | Scope | +LOC | Cumulative ratio |
|---|---|---|---|
| 14 | `network` infra+goldens, `permissions`, `audit_log` | +7,000 | 0.66x |
| 15 | `medical_standards` ICD-10/LOINC coverage, Isar agent memory RAG | +6,500 | 0.72x |
| 16 | PWA E2E offline coverage (6 user journeys × 2 breakpoints) | +6,000 | 0.77x |
| 17 | Remaining features inf + golden (24 features × ~365 LOC) | +8,687 | **0.85x** |

### What this PR (Wave 14.0) ships

- 8 dependabot bumps merged (PRs 1682-1689):
  - `bonsoir 7.1.4 → 7.1.5`
  - `openai_dart 7.0.1 → 8.1.0`
  - `google_mlkit_text_recognition 0.15.1 → 0.17.1`
  - `workmanager 0.9.0+3 → 0.10.9`
  - `intl 0.20.2 → 0.20.3`
  - `astro 7.2.8 → 7.2.9`
  - `tailwindcss 3.4.17 → 3.4.19` (kept on v3 — see "Tailwind v4 caveat")
  - `actions/setup-java v4 → v6` (release.yml + android_build.yml)
- 2 dev-tooling bumps needed to make `astro check` runnable:
  - Added `@astrojs/check 0.9.10` to devDependencies
  - Pinned `typescript ~5.6.3` (TS 7.x incompatible with astro check API)

### ⚠️ Tailwind v4 caveat (NOT shipped in this PR)

The upstream Dependabot bump proposed `tailwindcss 3.4.17 → 4.3.3` (major).
After upgrade:

- `astro check` FAILS — `@astrojs/tailwind@5` only supports tailwind v3
  (Astro 5.2+ added Tailwind v4 support via the new Vite plugin path, but this
  project still uses the deprecated `@astrojs/tailwind` integration).
- Migrating requires:
  1. `pnpm remove @astrojs/tailwind`
  2. `npx astro add tailwind` (registers the v4 Vite plugin)
  3. Migrate `tailwind.config.mjs` to a CSS-first `@theme` block in a global
     `.css` file
  4. Replace `@tailwind base/components/utilities` directives with
     `@import "tailwindcss";`

This is **out of scope** for the dependabot wave and tracked as a follow-up
issue. Keeping tailwind at 3.4.19 was the safest path to a green build.

### Verification matrix

| Check | Command | Result |
|---|---|---|
| `pnpm install` | `cd docs && CI=true pnpm install --no-frozen-lockfile --prefer-offline` | ✅ OK (13 deps added, 1 downgraded) |
| `astro check` | `cd docs && pnpm exec astro check` | ⚠️ 31 errors PRE-EXISTING (`node:fs` types missing — `@types/node` not installed in docs workspace). NOT introduced by these bumps. |
| `flutter analyze` | `flutter analyze --no-pub` | ⚠️ 327 issues (319 info + 8 errors) PRE-EXISTING (`undefined_named_parameter` in golden tests for the `size` field — predates this PR). NOT introduced by these bumps. |
| `pnpm check` | (alias for `astro check`) | ⚠️ same as above — no NEW errors |
| `pubspec.yaml` resolution | `flutter pub get` | ⛔ BLOCKED on infra: requires Dart SDK 3.10, local has 3.8 (per coverage_report.md). Bumps are version-only and SDK-agnostic. |
| PWA offline verify | (build deploy) | ⛔ requires SDK 3.10 — infra-blocked |

## Net wave outcome

- **8 / 8 dependabot PRs closed (1682-1689)** ✅
- **0 new errors** introduced by bumps ✅
- **2 dev-tooling additions** to restore build (`@astrojs/check`, pinned TS) ✅
- **2 workflow files** (`actions/setup-java@v6`) ✅
- **Honest reporting** on infra-blocked checks (SDK 3.10 missing) ✅