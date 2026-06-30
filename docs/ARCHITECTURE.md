# OrionHealth - Architecture

## System Architecture

OrionHealth is a Flutter mobile application built with **clean architecture** principles, designed for privacy-first, offline-capable health data management.

### Layer Structure

```
lib/
├── core/                    # Shared utilities, DI, theming, widgets
│   ├── di/                  # Dependency injection (Isar, memory modules)
│   ├── theme/               # AppTheme, CyberTheme
│   └── widgets/             # Reusable UI components (GlassmorphicCard)
├── features/                # Feature modules (allergies, auth, vitals...)
│   ├── <feature>/
│   │   ├── domain/          # Entities, repositories (abstract), use cases
│   │   ├── application/     # Business logic orchestration
│   │   ├── infrastructure/ # Repository implementations, data sources
│   │   └── presentation/   # UI screens, widgets, BLoC/state
├── l10n/                    # Localization (20+ languages)
└── main.dart
```

### Core Principles
- **Domain-Driven Design**: Each feature is self-contained with clear boundaries
- **Dependency Injection**: `get_it` + `injectable` for loose coupling
- **State Management**: BLoC pattern per feature
- **Database**: Isar (local-first, encrypted NoSQL)
- **AI**: On-device LLM via ONNX Runtime (Phi-3 Mini / Gemma 2B)

---

## Data Flow

```
User Input
    ↓
Presentation Layer (Screens / Widgets / BLoC)
    ↓
Application Layer (Use Cases)
    ↓
Domain Layer (Entities / Repository Interfaces)
    ↓
Infrastructure Layer (Repository Implementations / Data Sources)
    ↓
Isar Database (on-device encrypted storage)
```

### Key Data Flows

**Health Record Ingestion**
1. User uploads PDF/image document
2. OCR extracts text from document
3. Structured data (lab results, prescriptions) is parsed and stored in Isar
4. RAG pipeline indexes content for AI retrieval

**AI Health Insights**
1. User queries the local AI assistant
2. RAG retrieves relevant context from health records
3. On-device LLM generates contextual response
4. Response surfaced in chat UI

**Sensor Sync**
1. App syncs with Apple HealthKit (iOS) or Google Health Connect (Android)
2. Vitals data (heart rate, steps, sleep) imported and stored locally
3. Dashboard aggregates all data sources

---

## Security Model

### Encryption
- **Data at Rest**: Isar database with AES encryption enabled
- **No cloud storage**: All data stays on-device
- **Biometric/pin**: App access protected by biometric or pin authentication

### Privacy
- **Zero telemetry**: No analytics, no crash reporting to third parties
- **GDPR Compliance**: Data export (JSON) and right-to-be-forgotten deletion implemented
- **Privacy consent**: Shown during onboarding before any data collection

### Authentication Flow
```
App Launch → pin/Biometric Check → Authenticated Session
                                ↓
                        Session token stored in
                        SecureStorage (flutter_secure_storage)
```

---

## Module Responsibilities

Currently, the project contains 25 feature modules. Clean Architecture Completion: 72%

| Module | Responsibility | Clean Arch Status |
|--------|---------------|-------------------|
| `core/di` | Dependency injection container setup | N/A |
| `core/theme` | Visual theming (light/dark, cyber aesthetic) | N/A |
| `core/widgets` | Shared UI components (GlassmorphicCard) | N/A |
| `features/about` | Static content | Partial |
| `features/ai_assistant` | AI Assistant UI | Partial |
| `features/allergies` | Allergy tracking | Partial |
| `features/appointments` | Appointment scheduling and reminders | Partial |
| `features/auth` | Authentication, pin/biometric, session management | Full |
| `features/calendar_import` | Import appointments from calendar | Partial |
| `features/dashboard` | Home screen with health summary | Partial |
| `features/doctor_verification` | Doctor verification flow | Full |
| `features/email-citas` | Parse appointments from email | Partial |
| `features/eps_connection` | Connect to health providers | Partial |
| `features/health_data_import` | Import data from Apple Health / Google Fit | Partial |
| `features/health_record` | Document upload, OCR, structured storage | Full |
| `features/health_sharing` | Unified P2P sharing (BLE, NFC, WiFi) | Full |
| `features/home` | Home orchestration | Partial |
| `features/local_agent` | Local LLM management (ONNX Runtime) | Full |
| `features/medical_assistant` | On-device AI chat with RAG | Full |
| `features/medical_research` | Web search and evidence processing | Partial |
| `features/medications` | Medication list and reminders | Partial |
| `features/onboarding` | First-run experience, privacy consent | Partial |
| `features/reports` | Health report generation (PDF export) | Full |
| `features/settings` | App and LLM settings | Partial |
| `features/ssi` | Verifiable Credentials | Full |
| `features/sync` | Decentralized network node sync | Partial |
| `features/user_profile` | User profile and preferences | Full |
| `features/vitals` | Vitals tracking, sensor integration | Partial |
---

## Platform Integration

- **iOS**: Apple HealthKit integration, biometric auth via LocalAuthentication
- **Android**: Google Health Connect, BiometricPrompt API
- **Shared**: Flutter platform channels for native integrations

---

## Documentation

- `README.md` — Overview and feature list
- `PLANNING.md` — Project roadmap and planning
- `TASK.md` — Task breakdown
- `SECURITY.md` — Security policy
- `APK_BUILD_STATUS.md` — Build status tracking
- `docs/ORIONHEALTH-ROADMAP.md` — Detailed roadmap
- `docs/PRODUCTION_CHECKLIST.md` — This file — release checklist
