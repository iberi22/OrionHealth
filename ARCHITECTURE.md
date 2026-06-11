# OrionHealth — Architecture Guide

> **Última actualización:** 2026-06-10 | **Versión:** 1.0.0+1 | **Features:** 25

## Tech Stack

| Componente | Tecnología | Versión |
|---|---|---|
| Framework | Flutter | ^3.7.0 (Dart 3.x) |
| DI | GetIt | 9.2.1 |
| State Management | BLoC | ^9.0.0 |
| Local DB | IsarDB | via isar_agent_memory |
| Medical Standards | ObjectBox | via medical_standards |
| Native Bridge | MethodChannel | AICore/Gemma |
| Testing | flutter_test + golden | 137 test files |

## Clean Architecture Layers

Cada feature sigue 4 capas:

```
lib/features/<feature>/
├── domain/           # Entidades, repositorios abstractos, casos de uso
├── application/      # Cubits/BLoCs, casos de uso específicos
├── infrastructure/   # Implementaciones de repositorios, servicios externos
└── presentation/     # Widgets, páginas, navegación
```

### Coverage

| Capa | Features con capa |
|------|------------------|
| Domain | 24/25 ✅ |
| Application | 25/25 ✅ |
| Infrastructure | 25/25 ✅ |
| Presentation | 25/25 ✅ |
| **4 capas completas** | **24/25 (96%)** |

**Único gap:** `calendar_import` — domain layer vacío (entidades inline en cubit)

## Feature Inventory (25 features)

| Feature | D | A | I | P | Tests | Goldens | Estado |
|---|---|---|---|---|---|---|---|
| about | 2 | 1 | 1 | 2 | 1 | 0 | 🟡 Needs golden |
| ai_assistant | 3 | 2 | 1 | 2 | 4 | 0 | 🟡 Needs golden |
| allergies | 4 | 2 | 1 | 1 | 7 | 3 | ✅ |
| appointments | 4 | 2 | 1 | 1 | 6 | 10 | ✅ |
| auth | 4 | 5 | 6 | 6 | 11 | 3 | ✅ |
| calendar_import | 0 | 1 | 2 | 1 | 2 | 0 | ⚠️ Gap: domain |
| dashboard | 3 | 2 | 1 | 1 | 4 | 2 | ✅ |
| doctor_verification | 7 | 2 | 5 | 3 | 6 | 4 | ✅ (legacy data/) |
| email-citas | 4 | 2 | 1 | 1 | 5 | 15 | ✅ |
| eps_connection | 1 | 2 | 1 | 1 | 6 | 4 | ✅ |
| health_data_import | 2 | 2 | 2 | 3 | 2 | 0 | 🟡 Needs golden |
| health_record | 6 | 2 | 4 | 3 | 5 | 6 | ✅ |
| health_sharing | 1 | 1 | 4 | 2 | 6 | 5 | 🟡 Bugs activos |
| home | 2 | 2 | 1 | 2 | 3 | 4 | ✅ |
| local_agent | 7 | 1 | 19 | 2 | 7 | 3 | ✅ |
| medical_assistant | 13 | 1 | 8 | 4 | 10 | 3 | ✅ |
| medical_research | 4 | 1 | 6 | 5 | 8 | 4 | ✅ |
| medications | 3 | 2 | 1 | 1 | 6 | 3 | ✅ |
| onboarding | 3 | 2 | 1 | 15 | 4 | 4 | ✅ |
| reports | 4 | 3 | 3 | 3 | 2 | 3 | ✅ |
| settings | 4 | 2 | 1 | 1 | 6 | 4 | ✅ |
| ssi | 8 | 2 | 11 | 2 | 9 | 10 | ✅ |
| sync | 6 | 2 | 6 | 1 | 7 | 1 | 🟡 Needs golden |
| user_profile | 4 | 2 | 1 | 1 | 5 | 1 | 🟡 Needs golden |
| vitals | 4 | 2 | 1 | 2 | 5 | 10 | ✅ |

## Known Bugs

| # | Feature | Bug | Severidad |
|---|---|---|---|
| 1 | health_sharing | BLE startAdvertising() es stub | 🟡 Medium |
| 2 | health_sharing | WiFi discoverDevices() retorna mock data | 🟡 Medium |
| 3 | health_sharing | NFC sharing sin setup nativo | 🟡 Medium |
| 4 | allergies | Unused equatable import | 🟢 Low |
| 5 | sync | Legacy data/ dir (5 files) | 🟢 Low |
| 6 | doctor_verification | Legacy data/ dir (4 files) | 🟢 Low |
| 7 | calendar_import | Domain layer vacío | 🟢 Low |

## Git Workflow

- **Main** → producción
- **Develop** → integración
- **Feature branches** → `feat/<nombre>`

## Testing Strategy

- **Unit tests**: domain + application logic (137 test files)
- **Golden tests**: UI screenshot comparison (86 PNGs)
- **Coverage goal**: >50% test/lib ratio
- **6 features sin golden tests**: about, ai_assistant, calendar_import, health_data_import, sync, user_profile

## Quick Links

- [Feature Audit (detailed)](docs/FEATURE_AUDIT.md)
- [Coverage Report](coverage_report.md)
- [GitHub Issues](https://github.com/iberi22/OrionHealth/issues)
- [gitcore Features](.gitcore/features.json)
