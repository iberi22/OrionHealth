# OrionHealth — Feature Audit Report

> **Date:** 2026-06-10  
> **Status:** Post v1.0.0 preparation audit  
> **Total features:** 25 | **Full coverage (4-layer + tests):** 24/25 (96%)

## Coverage Summary

| Layer | Files | Lines |
|-------|-------|-------|
| Lib (production) | 298 | — |
| Tests | 137 | — |
| Golden PNGs | 86 | — |
| Test/lib ratio | 46% | — |

## Feature-by-Feature Breakdown

### ✅ FULL COVERAGE (24 features)

| Feature | D | A | I | P | Tests | Goldens | Notes |
|---------|---|---|---|---|-------|---------|-------|
| about | 2 | 1 | 1 | 2 | 1 | 0 | Needs golden tests |
| ai_assistant | 3 | 2 | 2 | 2 | 4 | 0 | **⚠️ FIXED**: chat_page imports (commit 05ba46f). 1 test duplicates removed |
| allergies | 4 | 2 | 1 | 1 | 7 | 3 | Warning: unused `equatable` import in entities/allergy.dart |
| appointments | 4 | 2 | 1 | 1 | 6 | 10 | ✅ Stable golden tests |
| auth | 4 | 5 | 6 | 6 | 11 | 3 | ✅ |
| dashboard | 3 | 2 | 1 | 1 | 4 | 1 | ✅ |
| doctor_verification | 7 | 2 | 1 | 3 | 6 | 4 | Has legacy `data/` (4 files). Infrastructure barrel re-exports from data/ |
| email-citas | 4 | 2 | 1 | 1 | 5 | 15 | ✅ MissingPluginException fixed |
| eps_connection | 1 | 2 | 1 | 1 | 6 | 3 | ✅ |
| health_data_import | 2 | 2 | 2 | 3 | 2 | 0 | Needs golden tests |
| health_record | 6 | 2 | 4 | 3 | 5 | 5 | ✅ |
| health_sharing | 1 | 1 | 4 | 2 | 6 | 4 | **⚠️ BLE startAdvertising is stub** (TODO). **⚠️ WiFi discoverDevices returns mock data** |
| home | 2 | 2 | 1 | 2 | 3 | 2 | ✅ |
| local_agent | 7 | 1 | 19 | 2 | 7 | 2 | ✅ Large infra layer (LLM models, download service) |
| medical_assistant | 13 | 1 | 8 | 4 | 10 | 2 | ✅ |
| medical_research | 4 | 1 | 6 | 5 | 8 | 3 | ✅ |
| medications | 3 | 2 | 1 | 1 | 6 | 2 | ✅ |
| onboarding | 3 | 2 | 1 | 15 | 4 | 2 | ✅ Presentation-heavy (many pages) |
| reports | 4 | 3 | 3 | 3 | 2 | 2 | ✅ |
| settings | 4 | 2 | 1 | 1 | 6 | 3 | ✅ |
| ssi | 8 | 2 | 11 | 2 | 9 | 10 | ✅ SSI heavy infra |
| sync | 6 | 2 | 1 | 1 | 7 | 0 | **⚠️ Has legacy data/ (5 files)**. Needs golden tests |
| user_profile | 4 | 2 | 1 | 1 | 5 | 0 | Needs golden tests |
| vitals | 4 | 2 | 1 | 2 | 5 | 10 | ✅ Stable golden tests |

### ⚠️ GAP — calendar_import (score: 75%)

| D | A | I | P | Tests | Goldens |
|---|---|--|---|-------|---------|
| 0 | 1 | 2 | 1 | 2 | 0 |

- Domain layer is **empty** (was migrated to application/ in commit b381e32)
- Domain should contain entities (CalendarImportState types are inline in cubit)
- ✅ All existing files compile clean
- No golden tests

## Issues Found & Fixed

### 🔴 FIXED (commit 05ba46f)
1. **app_links 7.1.1** — Incompatible with Dart SDK 3.10.0. Reverted to `^7.0.0`.
2. **ai_assistant chat_page.dart** — 20 compilation errors. Root cause: duplicate `AiRepositoryImpl` (one implementing `AiRepository`, the other `IAiRepository`). Removed duplicate, fixed import path.
3. **ai_assistant unreferenced types** — `AiAssistantState` and `AiAssistantStatus` not publicly exported from cubit. Added `export 'ai_assistant_state.dart'` to cubit.

### 🟡 TO FIX — Medium Priority
4. **allergies** — Unused `import 'package:equatable/equatable.dart'` in `entities/allergy.dart`.
5. **health_sharing BLE** — `startAdvertising()` is a stub (`// TODO: BLE peripheral mode requires platform-specific GATT server`).
6. **health_sharing WiFi** — `discoverDevices()` returns hardcoded mock devices.
7. **NFC sharing** — Uses `MethodChannel` requiring native Android setup.

### 🟢 KNOWN — Low Priority
8. **doctor_verification** — Legacy `data/` directory (4 files) but infrastructure barrel re-exports correctly.
9. **sync** — Legacy `data/` directory (5 files) with no infrastructure re-export.
10. **6 features without golden tests**: about, ai_assistant, calendar_import, health_data_import, sync, user_profile.

## Suggested Sprint Backlog

### Sprint 1 (pre-release)
- [ ] Fix `allergies` unused import
- [ ] Remove golden test failure dirs from gitignore
- [ ] Update coverage_report.md with real audit data

### Sprint 2 (post-v1.0.0)
- [ ] Migrate `sync` data/ → infrastructure/ (5 files)
- [ ] Implement real BLE advertising in health_sharing
- [ ] Implement real WiFi discovery in health_sharing
- [ ] Add golden tests for 6 features without

### Sprint 3
- [ ] Add domain entities to calendar_import
- [ ] Remove doctor_verification legacy data/
