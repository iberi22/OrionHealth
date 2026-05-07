# OrionHealth Architecture

> **Privacy-First, Local-First Medical Intelligence Network**

## System Overview

OrionHealth is a decentralized medical intelligence network that empowers individuals to own and control their complete health data. It provides AI-powered health insights without compromising user privacy.

### Core Principles

| Principle | Implementation |
|-----------|----------------|
| **Privacy First** | AES-256-GCM encryption, data never leaves device unencrypted |
| **Local AI** | On-device inference with Gemma/Phi-3 via ONNX |
| **Offline Capable** | 100% functionality without internet |
| **Community Verifiable** | Public medical standards with Wikipedia links |
| **User Control** | Selective sync, export in standard formats |

---

## Architecture Patterns

### Hexagonal Architecture (Ports & Adapters)

```
┌─────────────────────────────────────────────────────────────┐
│                      PRESENTATION                            │
│  (Flutter Widgets, BLoC/Cubit, Pages)                      │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│                      APPLICATION                            │
│  (Use Cases, Cubits, Business Logic)                       │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│                       DOMAIN                                 │
│  (Entities, Repository Interfaces, Value Objects)          │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│                   INFRASTRUCTURE                             │
│  (Isar DB, BLE/NFC/WiFi, LLM Adapters, HTTP Clients)       │
└─────────────────────────────────────────────────────────────┘
```

### Feature Module Structure

```
lib/features/
├── auth/                    # Authentication
│   ├── domain/            # Entities, Repositories
│   ├── application/       # Auth Cubit
│   ├── infrastructure/    # PIN, Biometric, Google Sign-In
│   └── presentation/      # Auth pages
│
├── onboarding/            # 5-step profile setup
│   ├── domain/           # UserProfile, ProfileAnalyzer
│   ├── application/      # Onboarding Cubit
│   └── presentation/     # Step pages
│
├── health_record/         # Medical records CRUD
│
├── medical_assistant/    # AI health analysis
│   ├── confidence-based response system
│   ├── explains symptoms, never diagnoses < 90%
│   └── medical standards integration
│
├── health_sharing/       # P2P health data sharing
│   ├── BLE (default)     # Bluetooth Low Energy
│   ├── NFC               # Contactless
│   └── WiFi Direct       # Direct connection
│
└── local_agent/         # Chat with local AI
```

---

## Medical Standards Architecture

### Three-Layer Data System

```
┌─────────────────────────────────────────────────────────────┐
│                    REPO (GitHub)                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  medical-standards/          ← JSON API endpoints          │
│  ├── icd10.json             ← https://raw.githubusercontent.com/... │
│  ├── loinc.json             ← Machine-readable             │
│  ├── rxnorm.json            ← Versioned releases          │
│  └── snomed.json                                           │
│                                                             │
│  docs/medical-standards/      ← Public documentation        │
│  ├── icd10.md                ← Wikipedia links           │
│  │   └── icd10_reference.md  ← Human-readable             │
│  ├── loinc.md                                             │
│  └── rxnorm.md                                             │
│                                                             │
│  packages/medical_standards/  ← Dart code (parsers)        │
│  ├── data/                   ← Bundled JSON for APK       │
│  └── lib/                    ← Loaders (NOT hardcoded)   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼ [CI on push]
┌─────────────────────────────────────────────────────────────┐
│                 APP INSTALLED                               │
├─────────────────────────────────────────────────────────────┤
│  assets/data/               ← JSON embedded in APK         │
│  ├── icd10.json            ← Offline access               │
│  ├── loinc.json                                          │
│  └── ...                                                 │
│                                                             │
│  Local AI ← JSON without internet                          │
│  100% Offline inference                                   │
└─────────────────────────────────────────────────────────────┘
```

### Access Patterns

| Mode | URL | Use Case |
|------|-----|----------|
| **Raw API** | `https://raw.githubusercontent.com/.../icd10.json` | Runtime fetch |
| **Versioned** | `https://raw.githubusercontent.com/.../v1.0.0/icd10.json` | Pinned release |
| **Bundled** | `assets/data/icd10.json` | APK offline |
| **Local Storage** | App's documents dir | Selective sync |

### Selective Sync

Users download only relevant data based on their profile:

- **Diabetes patient** → ICD-10 (Endocrine), RxNorm (insulin, metformin), LOINC (glucose)
- **Cardiac patient** → ICD-10 (Circulatory), LOINC (lipid panel)
- **Healthy user** → Basic panels only

**Expected download: 150-500MB** (not 3GB)

---

## AI Medical Assistant Rules

```
┌─────────────────────────────────────────────────────────────┐
│                  CONFIDENCE THRESHOLD                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ≥ 90%  → "This could be X based on symptoms"              │
│            (with medical disclaimer)                        │
│                                                              │
│  70-89% → "This could be related, but need more data"      │
│            (suggest specific tests)                         │
│                                                              │
│  50-69% → List possibilities + recommend exams            │
│                                                              │
│  < 50%  → "Insufficient information.                       │
│            Consult a healthcare professional."               │
│                                                              │
│  ⚠️  AI ALWAYS explains, NEVER diagnoses below 90%        │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Response Format

```dart
class AiResponse {
  final double confidence;      // 0.0 - 1.0
  final String explanation;    // What symptoms could indicate
  final List<String> possibilities;
  final List<String> suggestedExams;
  final String disclaimer;     // Always included
  final String source;         // Medical standard reference
}
```

---

## Health Sharing Protocol

```
┌─────────────────────────────────────────────────────────────┐
│              SECURE HEALTH PACKAGE SHARING                  │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Channels:                                                   │
│  • BLE (default) - Bluetooth Low Energy                    │
│  • NFC - Contactless for quick sharing                      │
│  • WiFi Direct - High-bandwidth transfers                   │
│                                                              │
│  Security:                                                   │
│  • AES-256-GCM encryption                                  │
│  • 2-of-3 authentication:                                  │
│    - PIN code                                               │
│    - Biometric (fingerprint/face)                          │
│    - Google Sign-In                                         │
│  • Package expires after 3 minutes                         │
│  • Recipient sees preview before accepting                   │
│                                                              │
│  Data Types:                                                 │
│  • Health records (diagnoses, treatments)                   │
│  • Lab results (blood tests, imaging)                        │
│  • Medications list                                        │
│  • Vital signs history                                     │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| **Framework** | Flutter 3.x |
| **State Management** | flutter_bloc |
| **DI** | get_it + injectable |
| **Database** | isar (NoSQL + FTS) |
| **AI Inference** | Gemma/Phi-3 via ONNX |
| **Health Data** | health package (Apple HealthKit / Google Health Connect) |
| **Encryption** | AES-256-GCM (pointycastle) |
| **UI** | Material Design 3 |

---

## Data Models

### Core Entities

```dart
// Health Record
class HealthRecord {
  String id;
  DateTime date;
  String type;           // diagnosis, lab_result, prescription
  String title;
  String description;
  List<String> attachments;
  Map<String, dynamic> metadata;
}

// Vital Sign
class VitalSign {
  String id;
  DateTime timestamp;
  String type;           // blood_pressure, heart_rate, temperature
  double value;
  String unit;
  Map<String, dynamic> extra;
}

// Medical Document
class MedicalDocument {
  String id;
  DateTime date;
  String title;
  String filePath;
  String documentType;   // lab_report, prescription, imaging
  String summary;
  List<String> tags;
}
```

---

## CI/CD Pipeline

### Medical Standards CI

```
Push to docs/medical-standards/
        │
        ▼
.github/workflows/medical-standards-ci.yml
        │
        ▼
Parse Markdown → Extract structured data
        │
        ▼
Generate medical-standards/*.json
        │
        ▼
GitHub Release (optional)
        │
        ▼
JSON embedded in next APK build
```

### Build Pipeline

```
PR Merge → GitHub Actions
        │
        ▼
flutter analyze
        │
        ▼
flutter test
        │
        ▼
flutter build apk --release
        │
        ▼
Upload to GitHub Releases
```

---

## Security Considerations

1. **Encryption at Rest**: All health data encrypted with AES-256-GCM
2. **Key Management**: Keys stored in platform secure storage (Keychain/Keystore)
3. **Memory Safety**: Sensitive data cleared after use
4. **Network**: HTTPS only, certificate pinning for API calls
5. **Biometric Gate**: Optional biometric lock for app access

---

## License

**AGPL-3.0** - Health data ownership tools remain public goods forever.

---

*Last updated: 2026-04-15*
