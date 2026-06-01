# OrionHealth — Technical Roadmap & Architecture

> **Version:** 1.0.0 | **Last Updated:** 2026-04-15 | **Status:** Active Development

---

## Executive Summary

OrionHealth is a **decentralized medical intelligence network** that provides:
- Personal health data wallet (encrypted, private)
- AI medical assistant grounded in international standards
- Doctor verification and reputation system
- P2P secure data sharing between nodes
- Selective sync based on user profile

**Core Principle:** AI explains symptoms and suggests, NEVER diagnoses without 90%+ confidence.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         ORIONHEALTH NETWORK                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    LOCAL NODE (User Device)                         │   │
│  │                                                                      │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐     │   │
│  │  │  HEALTH      │  │   MEDICAL   │  │     AI MEDICAL          │     │   │
│  │  │  WALLET     │  │  STANDARDS  │  │     ASSISTANT           │     │   │
│  │  │  (Private)  │  │  (Local)    │  │     (Grounded AI)      │     │   │
│  │  │             │  │             │  │                         │     │   │
│  │  │ • Labs      │  │ • ICD-10    │  │ • Confidence-based      │     │   │
│  │  │ • Vitals    │  │ • SNOMED    │  │ • Symptom explanation   │     │   │
│  │  │ • Meds      │  │ • LOINC     │  │ • Lab interpretation   │     │   │
│  │  │ • Allergies │  │ • RxNorm    │  │ • Suggest next steps    │     │   │
│  │  │ • Documents │  │ • Guidelines│  │ • NEVER diagnoses      │     │   │
│  │  │             │  │             │  │                         │     │   │
│  │  │ AES-256     │  │ ~150-500MB  │  │ <90% = "consult doctor" │     │   │
│  │  └──────────────┘  └──────────────┘  └──────────────────────────┘     │   │
│  │                                                                      │   │
│  │  ┌──────────────────────────────────────────────────────────────┐    │   │
│  │  │              SELECTIVE SYNC ENGINE                           │    │   │
│  │  │  Profile Analyzer → Relevant Categories → On-Demand Download  │    │   │
│  │  └──────────────────────────────────────────────────────────────┘    │   │
│  │                                                                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                     │                                        │
│                                     │ P2P Sync (NFC/BLE/WiFi)                │
│                                     ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                      PUBLIC NETWORK LAYER                            │   │
│  │                                                                       │   │
│  │  • Medical Standards Repository (GitHub)                             │   │
│  │  • Doctor Verification Registry                                      │   │
│  │  • Clinical Guidelines Updates                                        │   │
│  │  • Evidence-Based Medicine Database                                  │   │
│  │                                                                       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Package Structure

```
OrionHealth/
├── packages/
│   ├── medical_standards/           # PUBLIC - Medical knowledge
│   │   ├── lib/
│   │   │   ├── icd10/             # Disease classification
│   │   │   ├── snomed/           # Clinical terminology
│   │   │   ├── loinc/            # Lab codes
│   │   │   ├── fhir/             # FHIR builders
│   │   │   ├── medications/       # Drug references
│   │   │   ├── guidelines/       # Clinical guidelines
│   │   │   ├── onboarding/        # Profile analyzer + selective sync
│   │   │   └── services/         # Context provider + sync
│   │   ├── data/                 # JSON standard files
│   │   └── bin/                  # Validation scripts
│   │
│   ├── health_wallet/             # PRIVATE - User health data
│   │   ├── lib/
│   │   │   ├── models/           # Health record models
│   │   │   └── services/         # Wallet + encryption + sync
│   │   └── ...
│   │
│   └── isar_agent_memory/         # Existing - Vector memory
│
├── lib/
│   └── features/
│       ├── medical_assistant/     # AI medical assistant
│       └── ...                    # Other features
│
└── docs/
    └── ORIONHEALTH-ROADMAP.md    # This document
```

---

## Implemented Features

### ✅ Phase 1 — Foundation (COMPLETE)

| Feature | Status | Details |
|---------|--------|---------|
| Medical Standards Package | ✅ | ICD-10, SNOMED, LOINC, RxNorm, Guidelines |
| Profile Analyzer | ✅ | Determines relevant context from user data |
| Selective Sync | ✅ | Downloads only relevant standards (~150-500MB) |
| Health Wallet Models | ✅ | Lab, Vital, Medication, Event, Document |
| Encryption Service | ✅ | AES-256-GCM for sensitive data |
| AI Medical Assistant | ✅ | Structure with confidence-based responses |
| GitHub Actions CI | ✅ | Flutter analyze + validation workflows |
| Standards Validation | ✅ | ICD-10, LOINC, SNOMED format checks |

### ✅ Phase 2 — Core Intelligence (COMPLETE)

| Feature | Status | Details |
|---------|--------|---------|
| Confidence Thresholds | ✅ | 90% minimum for any diagnosis |
| Symptom Explanation | ✅ | Explains what symptoms COULD mean |
| Lab Interpretation | ✅ | Normal ranges + guidelines |
| Doctor Recommendation | ✅ | Always recommends professional consult |
| Safe Response Templates | ✅ | Low/Med/High confidence responses |

### 🔄 Phase 3 — P2P Sharing (IN PROGRESS)

| Feature | Status | Details |
|---------|--------|---------|
| NFC Receiving | 🔄 | Receive packages from other Orion nodes |
| BLE Transfer | 🔄 | Bluetooth Low Energy P2P |
| WiFi Server | 🔄 | Local HTTPS server with PIN |
| Encrypted Packages | 🔄 | AES-256 + ECDH key exchange |
| Consent Flow | 🔄 | User approves before receiving |

### 📋 Phase 4 — Doctor Verification (TODO)

| Feature | Status | Details |
|---------|--------|---------|
| Doctor Profile | 📋 | Public profile with credentials |
| License Verification | 📋 | Integration with medical boards |
| Patient Ratings | 📋 | 1-5 stars + comments |
| Vouching System | 📋 | Doctors validate other doctors |
| Reputation Badges | 📋 | Bronze/Silver/Gold/Platinum |

### 📋 Phase 5 — Medical Concept (TODO)

| Feature | Status | Details |
|---------|--------|---------|
| Medical Concept Model | 📋 | Doctor's notes + recommendations |
| Timeline View | 📋 | Chronological medical history |
| External Data Import | 📋 | Receive from other apps |
| FHIR Export | 📋 | Standard format for EHR systems |
| Second Opinion | 📋 | Multiple doctor reviews |

### 📋 Phase 6 — Network Expansion (TODO)

| Feature | Status | Details |
|---------|--------|---------|
| Node Discovery | 📋 | Find nearby Orion nodes |
| Distributed Cache | 📋 | IPFS/Filecoin for standards |
| Governance Token | 📋 | DAO for network decisions |
| Incentive System | 📋 | Rewards for data contribution |

---

## AI Medical Assistant — Confidence Rules

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        CONFIDENCE-BASED RESPONSE                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  CONFIDENCE ≥ 90%                                                   │   │
│  │  "Based on your data, it is LIKELY that..."                        │   │
│  │  + Full disclaimer + Recommend doctor anyway                        │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  70% ≤ CONFIDENCE < 90%                                            │   │
│  │  "This COULD be related to..., but I need more data."              │   │
│  │  + Suggest specific additional tests/exams                         │   │
│  │  + Always recommend doctor consultation                            │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  50% ≤ CONFIDENCE < 70%                                            │   │
│  │  "Your symptoms could indicate several things. The most important  │   │
│  │   thing to check is..."                                           │   │
│  │  + List possible causes ranked by likelihood                       │   │
│  │  + Recommend specific exams to narrow down                        │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  CONFIDENCE < 50%                                                   │   │
│  │  "I don't have enough information to determine the cause."         │   │
│  │  + List general categories of possible causes                      │   │
│  │  + Recommend: 1) See doctor, 2) Get these basic exams            │   │
│  │  + NEVER guess or speculate                                        │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ╔═════════════════════════════════════════════════════════════════════╗   │
│  ║  ABSOLUTE RULE: AI ALWAYS ends with doctor recommendation         ║   │
│  ║  "This information is educational. Consult a healthcare professional"║   │
│  ╚═════════════════════════════════════════════════════════════════════╝   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Data Privacy Model

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          DATA CLASSIFICATION                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  PUBLIC (No Encryption Needed)                                              │
│  ════════════════════════════════════                                       │
│  • Medical Standards (ICD-10, SNOMED, LOINC, etc.)                        │
│  • Clinical Guidelines (ADA, AHA, WHO, etc.)                              │
│  • Public medical knowledge                                                 │
│  • Stored: Local node (~150-500MB)                                         │
│  • Sync: From GitHub/network when needed                                   │
│                                                                              │
│  PRIVATE (AES-256-GCM Encryption)                                        │
│  ════════════════════════════════════════                                   │
│  • Lab results (personal values)                                           │
│  • Vital signs (personal measurements)                                     │
│  • Medications (personal regimen)                                          │
│  • Diagnoses/conditions (personal health)                                  │
│  • AI insights (derived from private data)                                 │
│  • Doctor concepts (professional notes)                                     │
│  • Stored: Encrypted locally in Isar                                        │
│  • Key: User's PIN + biometric + Google Sign-In                           │
│                                                                              │
│  SHARED (Explicit Consent Required)                                         │
│  ══════════════════════════════════                                        │
│  • Medical packages sent to other Orion nodes                              │
│  • Encrypted with recipient's public key                                    │
│  • Requires: PIN + biometric + Google Auth                                  │
│  • Auto-expires after 3 minutes                                            │
│  • Audit log maintained                                                    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Selective Sync — How It Works

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      PROFILE-BASED CONTEXT SELECTION                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. USER COMPLETES ONBOARDING                                               │
│     ├── Age: 45, Sex: M                                                   │
│     ├── Conditions: None                                                    │
│     ├── Family History: Diabetes (father)                                   │
│     ├── Medications: None                                                   │
│     └── Symptoms: Occasional fatigue                                         │
│                                                                              │
│  2. PROFILE ANALYZER IDENTIFIES RELEVANT CONTEXT                           │
│     ┌─────────────────────────────────────────────────────────────────┐    │
│     │ [✓] Preventive (all users)                                     │    │
│     │ [✓] Diabetes (family history)                                   │    │
│     │ [✓] Cardiovascular (age 45 + diabetes risk)                      │    │
│     │ [✓] Hematology (fatigue + possible anemia)                     │    │
│     │ [ ] Oncology (no risk factors)                                  │    │
│     │ [ ] Mental Health (no indicators)                               │    │
│     │ [ ] Respiratory (no indicators)                                 │    │
│     └─────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  3. SELECTIVE SYNC DOWNLOADS (~150MB)                                     │
│     ├── ICD-10: E10-E14, I10-I11, D50-D53                                 │
│     ├── LOINC: HbA1c, Glucose, Iron studies, Lipids                       │
│     ├── Medications: Metformin class, Statins, Iron supplements             │
│     └── Guidelines: ADA Diabetes, AHA Cardiovascular, CLSI Labs            │
│                                                                              │
│  4. AI HAS RELEVANT CONTEXT FOR THIS USER                                  │
│     └── Future questions about fatigue → instant offline response            │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Technical Specifications

### Minimum Storage Requirements

| Component | Size | Notes |
|----------|------|-------|
| Medical Standards (selective) | 150-500 MB | Based on profile |
| Medical Standards (full) | 2-3 GB | Optional |
| User Health Data | 50-200 MB | Growing with history |
| AI Model (distilled) | 50-100 MB | For offline inference |
| **Total Minimum** | **250-800 MB** | |
| **Total with Full Standards** | **2.5-3.5 GB** | Optional |

### Security

| Aspect | Implementation |
|--------|---------------|
| Data at Rest | AES-256-GCM (Isar encryption) |
| Data in Transit | TLS 1.3 + ECDHE |
| Key Derivation | Argon2id (for PIN) |
| Biometric Auth | Platform-native (Android/iOS) |
| External Auth | Google Sign-In (OAuth2 + 2FA) |
| Multi-Factor | 2 of 3: PIN + Biometric + Google |

### Compliance

| Standard | Status |
|----------|--------|
| HIPAA | Architecture supports compliance |
| LGPD (Brazil) | Data minimization via selective sync |
| GDPR (EU) | User controls all data |
| FHIR R4 | Full resource builders included |
| HL7 | Standards mapping complete |

---

## Development Status

### Subagent Tasks — In Progress

| Task | Agent | Status |
|------|-------|--------|
| Expand ICD-10/SNOMED/LOINC | OpenCode | Running |
| AI Medical Assistant (confidence rules) | OpenCode | Running |
| Full Local Data + Sync Service | OpenCode | Running |

### Subagent Tasks — Complete

| Task | Agent | Status |
|------|-------|--------|
| GitHub Actions CI | OpenCode | ✅ Complete |
| Health Wallet Package | OpenCode | ✅ Complete |
| Smart Onboarding | Me | ✅ Complete |

### Remaining Tasks

| Task | Priority |
|------|----------|
| NFC/BLE Receiving Infrastructure | High |
| Doctor Verification System | High |
| Medical Concept Timeline | Medium |
| FHIR Import/Export | Medium |
| Network Node Discovery | Low |

---

## Contributing

1. Fork the repository
2. Create a feature branch
3. Run validation: `dart run bin/validate_*.dart`
4. Run tests: `flutter test` / `dart test`
5. Submit PR with medical evidence references

---

## License

- **Code:** Apache 2.0
- **Medical Standards Data:** Respective organization licenses (WHO/IHTSDO/Regenstrief/HL7)

---

## Contact

- **CEO:** Sebastián Belalcazar (iberi22)
- **Project:** OrionHealth
- **Organization:** SouthWest AI Labs

---

*This document is updated continuously as features are implemented.*
