# OrionHealth - Development Status

> Last Updated: 2026-04-17

## Project Overview

**OrionHealth** is a Flutter-based personal health record (PHR) application for Latin American users. It emphasizes:
- **Local-first** health data storage with encryption
- **Medical standards compliance** (ICD-10, LOINC, SNOMED, RxNorm, FHIR)
- **AI-powered medical assistant** with on-device inference capabilities
- **P2P health data sharing** via BLE, NFC, and WiFi Direct
- **Offline-first** architecture with optional cloud sync

**Target Platform:** Android (primary), iOS, Windows, Linux, macOS, Web

**Language:** Dart/Flutter | **Min SDK:** 3.7.0+

---

## Architecture

### Layer Structure (Clean Architecture)

```
lib/
├── core/
│   ├── di/              # Dependency Injection (GetIt + Injectable)
│   ├── services/         # AI Core service (MethodChannel)
│   ├── theme/           # CyberTheme + AppTheme
│   └── widgets/         # Shared UI components (GlassmorphicCard)
├── features/            # Feature modules (14 features)
└── main.dart
```

### Feature Modules (14 total)

| Feature | Status | Description |
|---------|--------|-------------|
| `allergies` | ✅ Implemented | Allergy entity + repository (Isar) |
| `appointments` | ✅ Implemented | Appointment entity + repository |
| `auth` | 🟡 Partial | Biometric auth, secure storage, encryption |
| `ble_sharing` | 🟡 Stubs | NFC + WiFi Direct sharing (no real BLE) |
| `health_data_import` | ✅ Implemented | Import from external sources |
| `health_record` | ✅ Implemented | Medical records with OCR staging |
| `health_report` | ✅ Implemented | Report generation (mock) |
| `health_sharing` | 🟡 Stubs | BLE sharing (no real implementation) |
| `local_agent` | 🟡 Partial | RAG LLM with Gemma/Gemini adapters |
| `medical_assistant` | ✅ Implemented | AI medical insights + analysis |
| `medical_research` | ✅ Implemented | Web search + medical scraper |
| `medications` | ✅ Implemented | Medication tracking |
| `onboarding` | ✅ Implemented | Multi-step user onboarding |
| `user_profile` | ✅ Implemented | User profile management |
| `vitals` | ✅ Implemented | Vital signs tracking |
| `about` | ✅ Implemented | Static content (blog posts) |

### Packages (3 local packages)

| Package | Path | Purpose |
|---------|------|---------|
| `health_wallet` | `packages/health_wallet` | Encrypted health data storage, P2P sync |
| `isar_agent_memory` | `packages/isar_agent_memory` | Vector memory + agent orchestration |
| `medical_standards` | `packages/medical_standards` | ICD-10, LOINC, SNOMED, FHIR, RxNorm |

---

## Dependencies

### Core Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_bloc` | ^8.1.0 | State management (Cubit/Bloc) |
| `get_it` | ^9.1.0 | Service locator |
| `injectable` | ^2.6.0 | DI code generation |
| `isar` | ^3.1.0+1 | Local NoSQL database |
| `dio` | ^5.0.0 | HTTP client |
| `google_generative_ai` | ^0.4.7 | Gemini API |
| `flutter_secure_storage` | ^9.2.4 | Encrypted key storage |
| `local_auth` | ^2.3.0 | Biometric authentication |
| `flutter_blue_plus` | ^1.35.2 | BLE communication |
| `permission_handler` | ^12.0.1 | Runtime permissions |
| `file_picker` | ^10.3.7 | File selection |
| `image_picker` | ^1.2.1 | Camera/gallery access |
| `path_provider` | ^2.1.5 | File system paths |
| `google_fonts` | ^6.3.2 | Space Grotesk font |
| `flutter_markdown` | ^0.7.7+1 | Markdown rendering |
| `equatable` | ^2.0.7 | Value equality |
| `uuid` | ^4.5.2 | ID generation |
| `intl` | ^0.20.2 | Internationalization |
| `cryptography` | ^2.7.0 | Encryption utilities |

### Dev Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `build_runner` | ^2.4.13 | Code generation |
| `isar_generator` | ^3.1.0+1 | Isar schema generation |
| `injectable_generator` | ^2.4.2 | DI code generation |
| `mocktail` | ^1.0.5 | Mocking for tests |

---

## What Works vs What is Mocked/Stubbed

### ✅ Working Features

- **Isar Database** — All entities (UserProfile, MedicalRecord, Medication, VitalSign, etc.) stored locally
- **Dependency Injection** — Full GetIt+Injectable setup with generated config
- **Authentication** — Biometric (local_auth) + secure storage for credentials
- **Medical Standards** — ICD-10, LOINC, SNOMED, RxNorm, FHIR loaded from JSON data files
- **Medical Research** — Web search + scraper with bot bypass handling
- **Health Records** — File/image picking + OCR staging page
- **Health Reports** — Report generation (mock service, 2s delay simulation)
- **Onboarding** — Multi-step flow (7 steps: welcome → conditions → medications → family → privacy → basic info → complete)
- **User Profile** — CRUD operations with Isar persistence
- **Vitals/Allergies/Medications/Appointments** — Full CRUD repositories
- **Medical Assistant** — Lab interpreter, drug interactions, vital sign analyzer, risk calculator
- **Theme** — CyberTheme with neon green (#00FF85) + cyan (#00E0FF)
- **Navigation** — Bottom nav bar (4 tabs: Inicio, Citas, Archivos, Perfil)

### 🟡 Mocked/Stubbed Features

| Feature | Status | Notes |
|---------|--------|-------|
| **OCR Service** | Stub | `OcrServiceStub` — returns simulated text after 2s |
| **Report Generation** | Mock | `MockReportGenerationService` — returns hardcoded template |
| **BLE Sharing** | Stub | `BleSharingService` — comments only, no real flutter_blue_plus calls |
| **NFC Sharing** | Stub | `NfcSharingService` — MethodChannel exists but no real implementation |
| **WiFi Direct** | Stub | `WifiDirectService` — simulated discovery, real HTTP server |
| **LLM Adapters** | Partial | Gemma uses Gemini cloud (not local); MockLLMAdapter returns hardcoded text |
| **Embeddings** | Stub | `SimpleEmbeddingsAdapter` — pseudo-random hash, not real embeddings |
| **AI Core Service** | Stub | MethodChannel only — no actual Android/iOS native implementation |
| **Health Sharing** | Incomplete | `sharing_cubit.dart` line 337: `// TODO: Integrate with HealthWalletService` |
| **Vector Store Re-ranking** | Incomplete | `isar_vector_store_service.dart` line 46: `// TODO: Implement re-ranking when LLM adapter is configured` |

---

## Recent Changes and Fixes

Based on git history and file inspection:

1. **AICore ML Kit Removal** — `GemmaLlmAdapter` was updated to use Gemini cloud exclusively after `flutter_gemma: 0.12.6` was replaced by llama.cpp
2. **OcrServiceStub** — OCR was stubbed (previously may have been Google ML Kit or other)
3. **Memory Module** — Simple pseudo-random embeddings adapter added as placeholder
4. **Health Wallet Package** — Created with models for HealthRecord, LabResult, VitalSign, MedicationEntry, MedicalDocument, MedicalEvent
5. **BLE Sharing Service** — Comments indicate real flutter_blue_plus integration was planned but not implemented

---

## Key Patterns

### State Management
- **Cubit/Bloc** pattern for all stateful features
- States use `Equatable` for value comparison
- States define loading/success/error patterns

### Repository Pattern
- Domain layer defines repository interfaces
- Infrastructure layer implements with Isar
- DI wires implementations via `@LazySingleton`

### Dependency Injection
- All DI configured via `injection.config.dart` (generated)
- `getIt<Service>()` used throughout
- Environment-based model selection (mock/gemma/gemini)

### Medical Safety
- `MedicalLlmAdapter` enforces confidence thresholds:
  - <50%: needs more data
  - 50-80%: "could be related to"
  - 80-90%: high confidence explanation
  - ≥90%: diagnosis-capable (never actually diagnoses)

---

## Known Limitations

1. **No real BLE** — `BleSharingService` has no actual flutter_blue_plus calls
2. **No real NFC** — MethodChannel exists but no native implementation
3. **No real OCR** — Stub returns simulated text
4. **No real embeddings** — Simple pseudo-random hash (not semantic)
5. **No AI Core** — MethodChannel but no native Android/iOS code
6. **Report generation is mock** — Always returns same template
7. **Health wallet not integrated** — `sharing_cubit.dart` has TODO for HealthWalletService integration
8. **Re-ranking not implemented** — Vector store has TODO for when LLM configured
9. **Widget to main_preview naming** — Some features have both `main_preview.dart` and staging pages

---

## Build & Run

```bash
# Install dependencies
flutter pub get

# Generate DI code (after changes)
dart run build_runner build --delete-conflicting-outputs

# Run app
flutter run

# Build APK
flutter build apk --debug

# Build release
flutter build apk --release
```

---

## File Structure Summary

```
lib/
├── main.dart                          # App entry + MainNavigationPage
├── core/
│   ├── di/
│   │   ├── injection.dart             # configureDependencies()
│   │   ├── injection.config.dart      # GENERATED
│   │   ├── database_module.dart      # Isar setup
│   │   ├── memory_module.dart        # MemoryGraph + Embeddings
│   │   └── network_module.dart        # Dio + MedicalContextProvider
│   ├── services/
│   │   └── aicore_service.dart       # MethodChannel (stub)
│   └── theme/
│       └── cyber_theme.dart           # Dark neon theme
└── features/
    ├── about/                         # Static content
    ├── allergies/                     # Domain + Infrastructure
    ├── appointments/                 # Domain + Infrastructure
    ├── auth/                         # AuthCubit, biometric, encryption
    ├── ble_sharing/                  # NFC, WiFi (all stubs)
    ├── health_data_import/           # Import cubit + service
    ├── health_record/                # HealthRecordCubit + OCR staging
    ├── health_report/                # HealthReportBloc + mock service
    ├── health_sharing/               # BLE sharing (stub + TODO)
    ├── local_agent/                  # RAG LLM, Gemma/Gemini adapters
    ├── medical_assistant/            # AI analysis + response generation
    ├── medical_research/             # Web search + scraper
    ├── medications/                 # Medication entity + Isar repo
    ├── onboarding/                  # OnboardingCubit (7 steps)
    ├── user_profile/                # UserProfileCubit + Isar repo
    ├── vitals/                      # VitalSign entity + Isar repo
    └── main_preview.dart            # Alternative entry point
```