# PLANNING.md

## Vision

**OrionHealth** is a privacy-first, local-first health assistant application built with Flutter. It empowers individuals to own and control their complete health data history, creating a secure "Digital Health Sheet" that integrates with local sensors (Apple HealthKit, Google Health Connect) and uses on-device AI (Phi-3 Mini / Gemma 2B via ONNX) to provide health insights without compromising user privacy.

### The Greater Mission: Democratizing Personalized Medicine

**Today's Challenge:**
- Health data is fragmented across hospitals, clinics, and wearables
- Medical treatment follows "one-size-fits-all" protocols
- Patients lack access to their complete health history
- Clinical research relies on limited, incomplete datasets

**Tomorrow's Vision:**
- **Individual Empowerment**: Users own their complete, structured health timeline
- **Advanced AI Analysis**: Next-generation LLMs analyze entire health histories to identify patterns invisible to human physicians
- **Personalized Treatment**: Drug recommendations, dosages, and therapies tailored to individual profiles
- **Predictive Medicine**: AI models predict disease onset years in advance

---

## Medical Standards Architecture

### Data Philosophy

Medical standards data should be **PUBLIC, VERIFIABLE, and COMMUNITY ACCESSIBLE**. We avoid hardcoding medical data in Dart code — instead, we use structured JSON with proper attribution and links to authoritative sources.

### Three-Layer Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                     REPO (GitHub)                                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  medical-standards/          ← JSON endpoints (raw access)          │
│  ├── icd10.json                                              │
│  ├── loinc.json                                                │
│  ├── rxnorm.json                                               │
│  └── snomed.json                                                │
│                                                                     │
│  docs/medical-standards/      ← Markdown source with Wikipedia      │
│  ├── README.md                   links, official sources, licenses │
│  ├── icd10/                                                    │
│  ├── loinc/                                                     │
│  ├── rxnorm/                                                    │
│  └── snomed/                                                    │
│                                                                     │
│  packages/medical_standards/  ← Dart code (parsers, not data)     │
│  ├── data/                   ← Bundled JSON for APK               │
│  └── lib/                    ← Loaders that read from assets/     │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              ▼ [CI: on push to docs/]
┌─────────────────────────────────────────────────────────────────────┐
│                 APP INSTALLED (each device)                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  assets/data/                   ← JSON embedded in APK              │
│  ├── icd10.json                                                 │
│  ├── loinc.json                                                │
│  └── ...                                                         │
│                                                                     │
│  Local AI (Gemma/Ollama) ──────→ Accesses JSON without internet    │
│         │                                                             │
│         ▼                                                             │
│  Inference 100% OFFLINE with exact medical context                 │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Access Patterns

| Context | URL/Path | Use Case |
|---------|----------|----------|
| **Online/API** | `https://raw.githubusercontent.com/iberi22/OrionHealth/main/medical-standards/icd10.json` | Apps fetching latest data |
| **Versioned** | `https://raw.githubusercontent.com/iberi22/OrionHealth/v1.0.0/medical-standards/icd10.json` | Pinned releases |
| **Offline/Bundled** | `assets/data/icd10.json` | APK ships with data, zero network |
| **Local Storage** | App's documents directory | Selective sync per user profile |

### CI/CD Pipeline

```
Push to docs/medical-standards/
        │
        ▼
GitHub Actions: Parse Markdown → JSON
        │
        ▼
Output: medical-standards/*.json at repo root
        │
        ▼
GitHub Release (optional tag v1.0.0)
        │
        ▼
JSON embedded in next APK build
```

### Data Sources & Attribution

Each standard links to authoritative sources:

| Standard | Official Source | License | Wikipedia |
|----------|----------------|----------|-----------|
| ICD-10 | WHO/CMS (US) | Public Domain | [ICD-10](https://en.wikipedia.org/wiki/ICD-10) |
| LOINC | Regenstrief Institute | Free with registration | [LOINC](https://en.wikipedia.org/wiki/LOINC) |
| RxNorm | NLM/NIH (US) | Public Domain | [RxNorm](https://en.wikipedia.org/wiki/RxNorm) |
| SNOMED CT | SNOMED International | License required | [SNOMED CT](https://en.wikipedia.org/wiki/SNOMED_CT) |

### JSON Format Standard

```json
{
  "metadata": {
    "standard": "ICD-10",
    "version": "2024-1",
    "lastUpdated": "2026-04-15",
    "source": "WHO ICD-10-CM 2024",
    "sourceUrl": "https://www.cms.gov/medicare/coding-billing/icd-10-codes/icd-10-cm-codes",
    "license": "Public Domain",
    "wikipediaBase": "https://en.wikipedia.org/wiki/"
  },
  "data": [
    {
      "code": "E11",
      "displayName": "Type 2 diabetes mellitus",
      "category": "Endocrine",
      "wikipediaUrl": "https://en.wikipedia.org/wiki/Diabetes_mellitus_type_2",
      "searchTerms": ["diabetes", "DM2", "type 2"]
    }
  ]
}
```

### Selective Sync Strategy

Users don't download all 3GB of medical data. The onboarding flow analyzes user profile and downloads only relevant standards:

- **Diabetes patient** → ICD-10 (Endocrine), RxNorm (insulin, metformin), LOINC (glucose tests)
- **Cardiac patient** → ICD-10 (Circulatory), LOINC (lipid panel, cardiac markers)
- **Healthy user** → Basic panels only

Expected download: **150-500MB** depending on profile, not 3GB.

---

## Architecture

We follow **Hexagonal Architecture (Ports & Adapters)** to decouple the core domain logic from external tools.

### Directory Structure

```text
lib/
├── core/                   # Utilities, Config, Errors, Base UseCases
├── features/
│   ├── health_record/      # Feature: Medical History
│   │   ├── domain/         # Entities & Repositories (Interfaces)
│   │   ├── application/    # Use Cases (AddRecord, AnalyzeTrends)
│   │   ├── infrastructure/ # Implementation (Isar, HealthKit API)
│   │   └── presentation/   # BLoC & UI (Material 3)
│   │
│   ├── local_agent/        # Feature: AI Chat
│   │   ├── domain/         # Entities (Message, AgentAction)
│   │   ├── application/    # Use Cases (SendMessage, RetrieveContext)
│   │   ├── infrastructure/ # Implementation (FoundryService, OnnxService)
│   │   └── presentation/   # Chat UI
│   │
│   ├── medical_assistant/  # Feature: AI Medical Analysis
│   │   ├── confidence-based responses (90% threshold)
│   │   └── explains symptoms, never diagnoses below 90%
│   │
│   ├── health_sharing/     # Feature: BLE/NFC/WiFi P2P
│   │   ├── encryption (AES-256-GCM)
│   │   ├── 2-of-3 auth (PIN + Biometric + Google Sign-In)
│   │   └── 3-minute package expiry
│   │
│   └── onboarding/         # Feature: 5-step profile setup
│       └── selective sync based on profile
│
packages/
├── medical_standards/       # Dart parsers for JSON standards
│   ├── data/              # Bundled JSON (for APK)
│   └── lib/               # Loaders, not hardcoded data
│
└── health_wallet/         # Encrypted local health data
    └── models/            # HealthRecord, LabResult, etc.
```

## Tech Stack

1. **Framework:** Flutter (Latest Stable)
2. **State Management:** `flutter_bloc`
3. **Dependency Injection:** `get_it` + `injectable`
4. **Database:** `isar` (NoSQL + FTS)
5. **AI Inference:** Local models (Gemma/Phi-3 via ONNX)
6. **Health Data:** `health` package (Apple HealthKit / Google Health Connect)
7. **UI Design:** Material Design 3

## Constraints & Principles

| Principle | Implementation |
|-----------|----------------|
| **Local Privacy** | AES-256-GCM encryption, data never leaves device unencrypted |
| **Offline First** | App functions 100% without internet |
| **AI Never Diagnoses** | Confidence < 90% = explain symptoms only, recommend doctor |
| **Modular AI** | Model swappable without affecting UI |
| **Data Portability** | Export in JSON, FHIR formats |
| **Public Standards** | JSON at repo root with Wikipedia links, verifiable sources |

## AI Medical Assistant Rules

```
┌─────────────────────────────────────────────────────────────┐
│                  CONFIDENCE THRESHOLD                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ≥ 90% confidence  → "This could be X based on symptoms"   │
│                       (with medical disclaimer)             │
│                                                             │
│  70-89% confidence → "This could be related, but need      │
│                       more data. Consider these tests."     │
│                                                             │
│  50-69% confidence → List possibilities + suggest         │
│                       specific exams to narrow down         │
│                                                             │
│  < 50% confidence  → "Insufficient information. Please     │
│                       consult a healthcare professional."   │
│                                                             │
│  ⚠️  AI ALWAYS explains, NEVER diagnoses below 90%        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Health Sharing Protocol

```
┌─────────────────────────────────────────────────────────────┐
│              SECURE HEALTH PACKAGE SHARING                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Channels: BLE (default), NFC (contact), WiFi Direct        │
│                                                             │
│  Security:                                                  │
│  - AES-256-GCM encryption                                   │
│  - 2-of-3 authentication (PIN + Biometric + Google Sign-In)│
│  - Package expires after 3 minutes                          │
│  - Recipient sees preview before accepting                  │
│                                                             │
│  Data Types:                                                │
│  - Health records (diagnoses, treatments)                  │
│  - Lab results (blood tests, imaging)                       │
│  - Medications list                                         │
│  - Vital signs history                                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Development Phases

### Phase 1: Foundation ✅
- [x] Hexagonal architecture setup
- [x] Isar database configuration
- [x] User profile data model & UI
- [x] Authentication (PIN + Biometric)

### Phase 2: Data Ingestion ✅
- [x] File/Image Pickers
- [x] Medical record entities
- [x] Health wallet with encryption

### Phase 3: Medical Standards (In Progress)
- [ ] Refactor to use JSON files (not hardcoded Dart)
- [ ] Create public docs/medical-standards/ with Wikipedia links
- [ ] CI pipeline to generate JSON endpoints
- [ ] Bundle JSON in assets/ for offline access

### Phase 4: Local Intelligence 🔄
- [ ] LLM inference service (Gemma/Phi-3)
- [ ] Model management and downloads
- [ ] RAG (Retrieval-Augmented Generation) with medical standards
- [ ] Chat UI with medical assistant

### Phase 5: Sharing & Sync
- [ ] BLE/NFC/WiFi P2P sharing
- [ ] Selective sync per user profile
- [ ] Cloud backup (optional, encrypted)

### Phase 6: Community & Interoperability
- [ ] App Intents (Siri/Gemini)
- [ ] FHIR export
- [ ] Telegram support bot

## Licensing Philosophy

**AGPL-3.0** ensures health data ownership tools remain public goods forever.

**What You Can Do:**
- ✅ Use OrionHealth for personal health management
- ✅ Fork and modify for your own needs
- ✅ Contribute improvements back to the project
- ✅ Use in academic/research settings

**What You Cannot Do:**
- ❌ Sell OrionHealth or charge users for access
- ❌ Create proprietary versions with closed-source features
- ❌ Use in commercial health apps without open-sourcing derivative work

---

*Last updated: 2026-04-15*
