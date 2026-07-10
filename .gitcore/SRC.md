# SRC.md — Source Code Reference

## Overview
OrionHealth is a Flutter mobile application (Android/iOS) for privacy-first medical intelligence.

## Project Structure

### Root Level
- \lib/\ — Main application source code
- \packages/\ — Dart packages
  - \packages/health_wallet/\ — SSI/DID wallet implementation
  - \packages/medical_standards/\ — ICD-10, LOINC, RxNorm, SNOMED CT, FHIR
- \	est/\ — Root test suite
- \docs/\ — Documentation (including SRS/)
- \.github/\ — CI workflows
- \scripts/\ — Utility scripts (coverage_checker.py, etc.)

### lib/ Structure (Clean Architecture)
- \lib/app/\ — Application entry point, DI, routing
- \lib/presentation/\ — UI layer (pages, widgets, themes)
- \lib/domain/\ — Business logic (entities, use cases, repos interfaces)
- \lib/application/\ — Application services, state management
- \lib/infrastructure/\ — Data sources (Isar, APIs, BLE, NFC)

### Features (feature-first in lib/features/)
Each feature follows Clean Architecture internally:
\lib/features/<feature>/  - presentation/ (widgets, pages)
  - domain/ (models, use_cases)
  - application/ (providers, services)
  - infrastructure/ (repositories, data sources)

### Key Features (25 total, see features.json)
- auth, about, allergies, appointments, calendar_import, dashboard, data_sources,
  doctor_verification, email-citas, eps_connection, health_data_import, health_record,
  health_sharing, home, local_agent, medications, medical_research, meditation,
  network, onboarding, reports, settings, sync, user_profile, vitals, voice_chat

## Build Commands
- \lutter pub get\ — Install dependencies
- \lutter analyze\ — Static analysis
- \lutter test --coverage\ — Run tests with coverage
- \lutter build apk\ — Build Android APK
- \lutter build ios\ — Build iOS

## Documentation
- \docs/SRS/README.md\ — 6 SRS documents
- \docs/ORIONHEALTH-ROADMAP.md\ — Technical roadmap
- \docs/planning/PLANNING.md\ — Vision and planning
- \docs/features/*.md\ — Feature-specific docs
- \eatures.json\ — Feature catalog (26 features, source of truth)

## CI
- \.github/workflows/ci.yml\ — Flutter analyze + test + coverage
- Coverage threshold: \scripts/coverage_checker.py