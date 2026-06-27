# OrionHealth — Feature Audit Report

> **Date:** 2026-07-15
> **Status:** Final v1.0.0 Release Audit
> **Total features:** 26 | **Full coverage (4-layer + tests):** 25/26 (96%)

## Coverage Summary

| Layer | Files | Lines |
|-------|-------|-------|
| Lib (production) | 497 | — |
| Tests | 531 | — |
| Golden PNGs | 177 | — |
| Test/lib ratio | 106% | — |

## Feature-by-Feature Breakdown

| Feature | Files | Tests | Goldens | Status |
|---------|-------|-------|---------|--------|
| about | 9 | 11 | 0 | ✅ |
| allergies | 13 | 12 | 0 | ✅ |
| appointments | 16 | 15 | 0 | ✅ |
| auth | 20 | 26 | 0 | ✅ |
| calendar_import | 14 | 14 | 4 | ⚠️ (75%) |
| dashboard | 14 | 13 | 0 | ✅ |
| doctor_verification | 38 | 38 | 4 | ✅ |
| email-citas | 11 | 15 | 0 | ✅ |
| eps_connection | 17 | 19 | 0 | ✅ |
| health_data_import | 17 | 19 | 0 | ✅ |
| health_record | 15 | 15 | 0 | ✅ |
| health_sharing | 16 | 20 | 6 | ✅ |
| home | 16 | 14 | 0 | ✅ |
| local_agent | 35 | 36 | 0 | ✅ |
| medical_research | 16 | 22 | 1 | ✅ |
| medications | 11 | 10 | 0 | ✅ |
| meditation | 18 | 20 | 2 | ✅ |
| network | 21 | 25 | 0 | ✅ |
| onboarding | 22 | 25 | 0 | ✅ |
| reports | 13 | 14 | 0 | ✅ |
| settings | 18 | 23 | 0 | ✅ |
| sync | 21 | 21 | 3 | ✅ |
| user_profile | 11 | 11 | 0 | ✅ |
| vitals | 13 | 16 | 0 | ✅ |
| voice_chat | 14 | 15 | 0 | ✅ |

## Issues Found & Fixed

### 🔴 FIXED
1. **app_links 7.1.1** — Incompatible with Dart SDK 3.10.0. Reverted to `^7.0.0`.
2. **ai_assistant chat_page.dart** — Compilation errors fixed. Duplicate `AiRepositoryImpl` removed.
3. **ai_assistant unreferenced types** — `AiAssistantState` and `AiAssistantStatus` publicly exported from cubit.
4. **allergies** — Unused `equatable` import in `entities/allergy.dart` removed.
5. **MissingPluginException** in `email-citas` fixed.

### 🟡 TO FIX — Post v1.0.0
1. **health_sharing BLE** — `startAdvertising()` is a stub.
2. **health_sharing WiFi** — `discoverDevices()` returns hardcoded mock data.
3. **NFC sharing** — Uses `MethodChannel` requiring native Android setup.
4. **Data Encryption** — Isar database encryption (128-bit AES) not yet enabled in `database_module.dart`.

### 🟢 KNOWN — Low Priority
1. **doctor_verification** — Legacy `data/` directory (4 files) but infrastructure barrel re-exports correctly.
2. **sync** — Legacy `data/` directory (5 files).
3. **Golden tests** — Coverage increased but still missing for several features.
