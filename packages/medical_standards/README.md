# Medical Standards — OrionHealth Network

> Open medical standards repository for the OrionHealth decentralized healthcare network.
> **Key design: Full local data for AI inference — no streaming during runtime.**

## 🎯 Purpose

This package contains **public medical knowledge** that powers the OrionHealth AI medical assistant. The standards are public because:

- Medical knowledge belongs to humanity
- Standards (ICD-10, SNOMED, LOINC, etc.) are international public goods
- AI grounded in real standards produces better medical insights
- Interoperability requires shared vocabulary

## 🧠 Local-First AI Inference Strategy

**The core design principle:** AI inference happens entirely from **local cached data**. Sync is only for updates.

```
┌─────────────────────────────────────────────────────────────────┐
│                     INFERENCE time (LOCAL)                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐               │
│  │  full_icd10 │  │ full_loinc  │  │ full_snomed │  ...          │
│  │   (~20MB)   │  │  (~10MB)    │  │  (~30MB)    │               │
│  └─────────────┘  └─────────────┘  └─────────────┘               │
│          All loaded into MedicalContextProvider                  │
│                    ZERO network calls                            │
└─────────────────────────────────────────────────────────────────┘
                           │
                    Sync (background)
                           │
┌─────────────────────────────────────────────────────────────────┐
│                     UPDATE time (NETWORK)                        │
│  GitHub releases → Download → Cache locally → Done               │
│  Run: SyncService().syncAll()                                     │
└─────────────────────────────────────────────────────────────────┘
```

### Why Local-First?
1. **Privacy**: No patient-related queries leave the device
2. **Speed**: Instant lookups, no latency during inference
3. **Reliability**: Works offline, no dependency on external APIs
4. **Cost**: No per-query API costs for standard lookups

## 📚 Standards Included

| Standard | Description | Local File | License |
|----------|-------------|------------|---------|
| **ICD-10-CM** | International Classification of Diseases | `data/full_icd10.json` | WHO/CMS Public Domain |
| **LOINC** | Laboratory observations | `data/full_loinc.json` | LOINC License (free reg.) |
| **SNOMED CT** | Clinical terminology | `data/full_snomed.json` | SNOMED License Required |
| **RxNorm** | Medication normalized names | `data/full_rxnorm.json` | US Gov Public Domain |
| **FHIR R4** | Health records resources | `lib/fhir/` | HL7 |
| **Clinical Guidelines** | ADA, AHA, WHO references | `lib/guidelines/` | Public |

## 🏗️ Architecture

```
medical_standards/
├── lib/
│   ├── medical_standards.dart    # Core exports
│   ├── icd10/                     # ICD-10 Dart models
│   ├── snomed/                    # SNOMED CT Dart models
│   ├── loinc/                     # LOINC Dart models
│   ├── medications/               # RxNorm Dart models
│   ├── fhir/                      # FHIR resource builders
│   ├── guidelines/                # Clinical guidelines
│   └── services/
│       ├── sync_service.dart      # Background sync from GitHub
│       └── medical_context_provider.dart  # Local AI context lookup
├── data/
│   ├── full_icd10.json            # Full ICD-10 dataset
│   ├── full_loinc.json            # Full LOINC dataset
│   ├── full_snomed.json           # Full SNOMED CT dataset
│   └── full_rxnorm.json           # Full RxNorm dataset
└── doc/
    └── download_standards.ps1      # Script to download official sources
```

## 🔌 Usage

### Basic Dart API (compile-time constants)
```dart
import 'package:medical_standards/medical_standards.dart';

// ICD-10 codes
final diabetes = Icd10ChronicConditions.diabetesType2;

// LOINC codes
final hba1c = LoincCommonLabs.hemoglobinA1c;

// SNOMED concepts
final t2dm = SnomedCommonConcepts.diabetesType2;

// Medications
final metformin = MedicationCatalog.metformin;
```

### AI Context Provider (runtime local lookups)
```dart
import 'package:medical_standards/services/medical_context_provider.dart';

// Initialize once at app startup
final provider = MedicalContextProvider();
await provider.initialize();

// Inference-time lookups — ZERO network calls
final icd10 = provider.getIcd10ForCode('E11');
final loinc = provider.getLoincForCode('4548-4');
final guidelines = provider.getGuidelinesForCondition('E11');
final fullContext = provider.getFullContextForDiagnosis('E11');
```

### Sync Service (background updates)
```dart
import 'package:medical_standards/services/sync_service.dart';

// Check for updates (background)
final sync = SyncService();
final results = await sync.syncAll();

// Check sync status
final status = await sync.getSyncStatus();
final isReady = await sync.isDataAvailable();
```

## 🔄 Syncing Full Datasets

```bash
# Download official datasets from sources
./doc/download_standards.ps1

# Sync from GitHub releases (when new versions available)
dart run sync --all

# Check sync status
dart run sync --status
```

## 📥 Downloading Full Datasets

Run the download script to get official data from primary sources:

```powershell
./doc/download_standards.ps1
```

| Standard | Source | License Required |
|----------|--------|------------------|
| ICD-10-CM | CMS (cms.gov) | No — public domain |
| LOINC | Regenstrief (loinc.org) | Free registration |
| SNOMED CT | SNOMED International | **Yes — license required** |
| RxNorm | NLM/NIH (nih.gov) | No — public domain |

## 🌐 Public Layer vs Private Data

```
┌─────────────────────────────────────────────────────┐
│  PUBLIC (This Package)     │  PRIVATE (User Wallet) │
├─────────────────────────────┼─────────────────────────┤
│ ICD-10 codes & names       │ User's actual diagnoses │
│ SNOMED CT mappings          │ User's lab results      │
│ LOINC codes                 │ User's medications      │
│ RxNorm drug names           │ AI insights             │
│ Clinical guidelines refs   │ Doctor concepts         │
│ FHIR resource templates    │ Access logs             │
└────────────────────────────┴─────────────────────────┘
```

## 🤝 Contributing

This is an **open public good**. Contributions welcome:

1. Add missing ICD-10/SNOMED/LOINC mappings
2. Update clinical guidelines references
3. Add new language localizations
4. Report incorrect standard mappings

## 📄 License

- Standards data: respective standards organization licenses (IHTSDO, WHO, etc.)
- Code/Mappings: Apache 2.0
- SNOMED CT: Requires SNOMED International license

## 🔗 Related

- [OrionHealth](https://github.com/iberi22/OrionHealth) — Main app
- [isar_agent_memory](https://github.com/iberi22/isar_agent_memory) — Private memory system
