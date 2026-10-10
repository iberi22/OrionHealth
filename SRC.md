# SRC.md — Source Code Reference & Repository Structure

## Overview
**OrionHealth** is a Flutter mobile application (Android, iOS, Windows) paired with backend services for privacy-first personal health intelligence.

---

## Complete Repository Structure (100%)

### Root Directory
- `lib/` — Main Flutter application source code (Clean Architecture)
- `backend/` — Node.js/Express backend server for FHIR data integration & sessions
- `src-astro/` — Astro 7 + Svelte 5 web PWA (`orionhealth-web`, Cloudflare Workers)
- `functions/` — Cloud & serverless utility functions
- `packages/` — Local Dart/Flutter packages
  - `packages/health_wallet/` — Self-Sovereign Identity (SSI) / DID & Verifiable Credentials wallet
  - `packages/health_contract/` — Immutable Dart models, transports and validator for the swal.health/v1 contract
  - `packages/isar_agent_memory/` — Graph + Vector local database for AI agent memory (Isar)
  - `packages/medical_standards/` — ICD-10, LOINC, RxNorm, SNOMED CT, FHIR mappings
- `docs/` — Documentation & SRS specifications
  - `docs/SRS/` — Software Requirements Specification files (`01-functional-requirements.md`, `REQUIREMENTS.md`, etc.)
  - `docs/architecture/` — Architecture & Clean Architecture guidelines
  - `docs/features/` — Feature specifications & documentation
- `.gitcore/` — GitCore & SWAL standards metadata
  - `.gitcore/docs/` — SWAL_GOAL.md canonical document
  - `.gitcore/features.json` — Feature catalog (schema v2)
  - `.gitcore/harness/` — Harness scan reports
- `android/` — Native Android platform code and `AicorePlugin.kt`
- `ios/` — Native iOS platform code
- `windows/` — Native Windows desktop platform runner
- `assets/` — Application assets (images, icons, medical reference data)
- `test/` — Unit and widget test suite
- `test_driver/` — Drivers for integration tests
- `integration_test/` — End-to-end integration test scenarios
- `golden/` — Reference golden images for visual regression tests
- `scripts/` — Build and analysis utility scripts
- `web/` — Flutter Web target (PWA build published to Cloudflare Pages via `wrangler.toml`)

---

## Application Architecture (`lib/`)

OrionHealth follows Clean Architecture with feature-first modularization:

```
lib/
├── main.dart / main_web.dart   # App entry points (mobile/desktop, Flutter Web)
├── l10n/                       # Localization ARB files
├── core/                       # Shared infrastructure & utilities
│   ├── config/                 # Environment & build configs (dev/staging/prod)
│   ├── di/                     # Dependency Injection (GetIt + injectable)
│   ├── logging/, audit/, network/, medical/, responsive/  # Cross-cutting infra
│   ├── services/               # Core services (Audio, TTS, SecureStorage, AppLogger)
│   ├── theme/                  # Theme definitions (CyberTheme dark mode)
│   ├── utils/                  # Cache, error handling, lazy router
│   └── widgets/                # Reusable widgets & ErrorBoundary
└── features/                   # 29 Feature modules
    ├── auth/                   # Authentication & biometrics
    ├── dashboard/              # Centralized health dashboard
    ├── health_record/          # FHIR medical records & history
    ├── local_agent/            # Local RAG AI agent
    ├── voice_chat/             # Offline AI voice assistant
    └── ...                     # (See .gitcore/features.json for full feature list)
```

---

## Build & Test Commands

- `flutter pub get` — Install dependencies
- `dart run build_runner build --delete-conflicting-outputs` — Run code generation
- `flutter analyze` — Run static analysis
- `flutter test` — Run unit and widget test suite
- `flutter build apk` — Build Android release APK
