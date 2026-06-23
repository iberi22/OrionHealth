# OrionHealth Code Review & Medical Protocol Verification
**Date:** 2026-06-18
**Auditor:** Jules (AI Senior Software Engineer)
**Scope:** Full codebase audit (lib/, test/, integration_test/, docs/)

---

## 1. Code Review (lib/)

### 1.1. Error Handling
- **Finding:** Widespread lack of explicit `try-catch` blocks in Repository implementations for database operations.
- **Impact:** Critical. If Isar operations fail (e.g., disk full, schema mismatch), the app might crash or enter an inconsistent state.
- **Recommendations:** Implement a consistent error handling strategy in `infrastructure/` layers. Use `Either<Failure, T>` pattern or at least catch Isar exceptions at the repository level.
- **Affected Features:** `vitals`, `health_sharing`, `settings`, `health_record`, `health_data_import`, `about`, `network`, `local_agent`, `calendar_import`, `email-citas`, `voice_chat`, `user_profile`, `auth`.

### 1.2. Dependency Injection (DI)
- **Finding:** Standard use of `GetIt` and `injectable`. Configuration in `lib/core/di/` is correct.
- **Issues:** None found in the core DI structure.

### 1.3. BLoC/Cubit State Management
- **Finding:** Most features follow the Cubit pattern consistently (`auth`, `sync`).
- **Issue:** `local_agent` (ChatPage) uses `StatefulWidget` for managing complex AI chat state instead of a Cubit. This deviates from the project's Clean Architecture standards defined in `ARCHITECTURE.md`.
- **Recommendation:** Refactor `ChatPage` to use `LocalAgentCubit` to separate UI from generation logic and facilitate testing.

### 1.4. Security: PII & Encryption
- **Finding:** **CRITICAL.** 128-bit AES encryption for the Isar database is NOT implemented in `DatabaseModule.dart`. The `Isar.open` call lacks the `encryptionKey` parameter.
- **Finding:** PII handling via `PromptScrubber` and `PiiDetector` is excellent. It covers 30+ entities and supports format-preserving masking and surrogates.
- **Recommendation:** Implement `encryptionKey` in `Isar.open` using a key derived from the user's PIN/Biometrics via `SecureStorageService`.

---

## 2. Test Verification (test/ & integration_test/)

### 2.1. Broken References
- **Finding:** 20+ test files have broken imports.
- **Cause:** Discrepancy between folder structures. Tests expect `infrastructure/` but many repositories moved to `data/`.
- **Affected:** `settings`, `health_data_import`, `onboarding`.

### 2.2. Coverage
- **Finding:** Coverage is generally good but gaps exist in critical paths:
    - `auth` domain layer has ❌ (0% or missing).
    - `health_data_import` application layer has ❌.
- **Recommendation:** Prioritize unit tests for `AuthRepository` and `HealthImportBloc`.

### 2.3. Golden Tests
- **Finding:** Significant discrepancy in Golden references.
- **Issue:** 80 unique references called in code, but only 45 PNG files exist in `golden/reference/`.
- **Impact:** Many UI tests are likely failing due to missing goldens.

---

## 3. Medical Protocol Verification

### 3.1. Data Integrity Discrepancy
- **Finding:** **MAJOR.** `medical-standards.json` claims to cover:
    - ICD-10: 278 codes
    - LOINC: 145 codes
- **Actual Data:** `public/icd10.json` only has **38 codes** and `public/loinc.json` has **7 codes**.
- **Impact:** The documentation site and local AI assistant are working with a severely truncated dataset compared to what is advertised.

### 3.2. Search Component
- **Finding:** `MedicalSearch.astro` correctly implements search by both code and name. Logic is sound but dataset is small.

---

## 4. E2E & Golden Reference Verification

### 4.1. E2E Tests (Playwright)
- **Status:** ✅ All selectors in `docs/e2e/landing.spec.ts` match the actual component structure.
- **Verification:** Verified `id="dashboard"`, `id="standards"`, and various `.arch-layer` classes.

### 4.2. Stale Goldens
- **Finding:** Potential stale files found in `golden/reference/` (e.g., `onboarding_step_0.png` through `onboarding_step_6.png`) because they are called via string interpolation in tests, which static analysis might miss. However, they seem to be used.

---

## Summary of Critical Issues

1. **Security:** Missing AES encryption for Isar DB.
2. **Data:** Truncated ICD-10 and LOINC datasets in docs.
3. **Architecture:** `local_agent` UI not using Cubit.
4. **Maintenance:** Broken imports in 20+ test files.
5. **Testing:** Missing ~35 golden reference images.

---
**References:**
- `ARCHITECTURE.md` - Clean Architecture compliance.
- `PROTOCOL.md` - Medical data standards.
- `SECURITY.md` - Encryption requirements.
