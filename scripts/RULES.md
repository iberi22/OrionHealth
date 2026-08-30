# Scripts Directory — Rules

This directory contains **development tooling, build helpers, and CI scripts**.
**NOT part of the runtime app** — files here are NOT shipped with the APK/IPA.

## What belongs here

| Type | Examples |
|------|----------|
| Build helpers | `build_apk.ps1`, `coverage_checker.py` |
| Diagnostic scripts | `check_status.bat`, `close_issues.bat` |
| Benchmarking | `benchmark_embeddings.dart` |
| Orchestration | `add_hierarchy.py`, harness scripts |

## What does NOT belong here

- Application Dart code → `lib/`
- Flutter test code → `test/`
- Documentation → `docs/`
- Configuration files for app → root or `assets/`
- Debug/temp files → `docs/diagnostics/`

## Repo-wide GitCore rules

| Path | Purpose |
|------|---------|
| `lib/` | Flutter app source |
| `test/` | Flutter tests |
| `integration_test/` | E2E integration tests |
| `docs/` | Documentation + medical standards data |
| `packages/` | Local Dart packages (`health_wallet`, `isar_agent_memory`, `medical_standards`) |
| `scripts/` | Dev tooling (this directory) |
| `docs/diagnostics/` | Build/diagnostic outputs (gitignored content) |
| Root | ONLY canonical docs (README, CHANGELOG, LICENSE, etc.) |

See `.gitignore` for patterns excluded from tracking.

## Adding a new script

1. Make sure the script is genuinely dev-only (not runtime logic)
2. If it produces output files, ensure they're added to `.gitignore`
3. If it consumes sensitive data, document the security considerations
4. Update this file if a new category emerges

Last reviewed: 2026-08-29 (Wave 9)