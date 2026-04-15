# Medical Standards — OrionHealth Network

> Open medical standards repository for the OrionHealth decentralized healthcare network.

## 🎯 Purpose

This package contains **public medical knowledge** that powers the OrionHealth AI medical assistant. The standards are public because:

- Medical knowledge belongs to humanity
- Standards (ICD-10, SNOMED, LOINC, etc.) are international public goods
- AI grounded in real standards produces better medical insights
- Interoperability requires shared vocabulary

## 📚 Standards Included

| Standard | Description | Size |
|---------|-------------|------|
| **ICD-10** | International Classification of Diseases | ~20 MB |
| **SNOMED CT** | Clinical terminology (subset) | ~30 MB |
| **LOINC** | Laboratory observations | ~10 MB |
| **FHIR R4** | Health records resources | ~5 MB |
| **RxNorm** | Medications normalized names | ~10 MB |
| **Clinical Guidelines** | ADA, AHA, WHO references | ~5 MB |

## 🏗️ Architecture

```
medical_standards/
├── lib/
│   ├── core/              # Base models, constants
│   ├── icd10/             # ICD-10 disease classification
│   ├── snomed/            # SNOMED CT mappings
│   ├── loinc/             # LOINC laboratory codes
│   ├── fhir/              # FHIR resource builders
│   ├── medications/       # RxNorm drug data
│   └── guidelines/        # Clinical practice guidelines
├── data/                  # JSON/CSV standard files
└── doc/                   # Documentation
```

## 🔌 Usage

```dart
import 'package:medical_standards/icd10/diabetes.dart';
import 'package:medical_standards/loinc/common_labs.dart';
import 'package:medical_standards/fhir/observation.dart';

// Get ICD-10 codes for diabetes
final diabetesCodes = Icd10Diabetes.codes;

// Get LOINC code for Hemoglobin A1c
final hba1cCode = LoincCodes.hemoglobinA1c;

// Build FHIR Observation
final fhirObs = FhirObservationBuilder()
  .code(LoincCodes.hemoglobinA1c)
  .value(6.8, Unit.percent)
  .build();
```

## 🌐 Public Layer vs Private Data

```
┌─────────────────────────────────────────────────────┐
│  PUBLIC (This Package)     │  PRIVATE (User Wallet) │
├─────────────────────────────┼─────────────────────────┤
│ ICD-10 codes & names       │ User's actual diagnoses │
│ SNOMED CT mappings         │ User's lab results      │
│ LOINC codes                │ User's medications      │
│ RxNorm drug names          │ AI insights             │
│ Clinical guidelines refs   │ Doctor concepts         │
│ FHIR resource templates    │ Access logs             │
└─────────────────────────────┴─────────────────────────┘
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

## 🔗 Related

- [OrionHealth](https://github.com/iberi22/OrionHealth) — Main app
- [isar_agent_memory](https://github.com/iberi22/isar_agent_memory) — Private memory system
