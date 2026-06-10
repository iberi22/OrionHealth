# OrionHealth — Gap Report

> **Estado:** v0.8.1 → Preparación v1.0.0 | Commit: `67dc544`
> **Tests:** ✅ 34 passed, 2 skipped (network-dependent)

---

## Resumen Ejecutivo

| Métrica | Valor |
|---------|-------|
| Features totales | 25 |
| Clean Architecture completa (D→I→A→P) | 8 (32%) |
| Clean Architecture parcial | 17 (68%) |
| Con tests unitarios | 10 (40%) |
| Sin tests | 15 (60%) |
| Bugs conocidos | 2 (WiFi Direct protocol mismatch, user_profile hardcoded image URL) |
| Tests skipped | 2 (network-dependent) |

---

## Feature Breakdown

### ✅ Completo (4 capas + tests)
| Feature | D | I | A | P | Tests | Notas |
|---------|---|---|---|---|-------|-------|
| auth | ✅ | ✅ | ✅ | ✅ | ✅ | 21 files, 2 aplicación cubits |
| doctor_verification | ✅ | ✅ | ✅ | ✅ | ✅ | 16 files, Isar codegen |
| health_record | ✅ | ✅ | ✅ | ✅ | ✅ | 15 files, timeline + FHIR export |
| health_sharing | ✅ | ✅ | ✅ | ✅ | ✅ | 8 files, BLE/WiFi/NFC |
| local_agent | ✅ | ✅ | ✅ | ✅ | ✅ | 30 files, RAG + LLM adapters |
| medical_assistant | ✅ | ✅ | ✅ | ✅ | ✅ | 26 files, clinical reasoner |
| reports | ✅ | ✅ | ✅ | ✅ | ✅ | 13 files, Gemma integration |
| ssi | ✅ | ✅ | ✅ | ✅ | ✅ | 21 files, DID + Verifiable Credentials |

### ⚠️ Parcial (falta al menos 1 capa O tests)
| Feature | D | I | A | P | Tests | Capa faltante |
|---------|---|---|---|---|---|---|
| about | ✗ | ✗ | ✗ | ✅ | ✅ | D+I+A — solo presentación |
| ai_assistant | ✗ | ✗ | ✗ | ✅ | ✅ | D+I+A — solo presentación |
| allergies | ✅ | ✅ | ✗ | ✅ | ✗ | A + tests |
| appointments | ✅ | ✅ | ✗ | ✅ | ✗ | A + tests |
| calendar_import | ✅ | ✗ | ✅ | ✅ | ✗ | I + tests |
| dashboard | ✗ | ✗ | ✗ | ✅ | ✗ | D+I+A + tests |
| email-citas | ✅ | ✗ | ✗ | ✅ | ✗ | I+A + tests |
| eps_connection | ✅ | ✅ | ✗ | ✅ | ✗ | A + tests |
| health_data_import | ✅ | ✗ | ✅ | ✅ | ✗ | I + tests |
| home | ✅ | ✗ | ✅ | ✅ | ✗ | I + tests |
| medical_research | ✅ | ✅ | ✗ | ✗ | ✗ | A+P + tests |
| medications | ✅ | ✅ | ✗ | ✅ | ✗ | A + tests |
| onboarding | ✅ | ✗ | ✅ | ✅ | ✗ | I + tests |
| settings | ✅ | ✅ | ✅ | ✅ | ✗ | Tests |
| sync | ✗ | ✗ | ✗ | ✅ | ✗ | D+I+A (datos tiene archivos sin clean arch) |
| user_profile | ✅ | ✅ | ✅ | ✅ | ✗ | Tests |
| vitals | ✅ | ✅ | ✗ | ✅ | ✗ | A + tests |

### ❌ Capas faltantes por feature
- **Falta Application (A):** allergies, appointments, dashboard, email-citas, eps_connection, home, medications, sync, vitals
- **Falta Infrastructure (I):** calendar_import, dashboard, email-citas, health_data_import, home, onboarding, sync
- **Falta Domain (D):** about, ai_assistant, dashboard, sync
- **Falta Presentation (P):** medical_research

---

## Tickets para alcanzar 100%

### Prioridad Alta (afectan funcionalidad existente con bugs)

| # | Feature | Ticket | Esfuerzo |
|---|---------|--------|----------|
| 1 | **health_sharing** | Arquitectura de red: HTTP server ↔ Socket connect incompatible. `sendData` usa `Socket.connect(targetIp, kDefaultPort)` pero el servidor es `HttpServer`. Arreglar protocolo. | 3h |
| 2 | **user_profile** | URL de imagen hardcodeada (`lh3.googleusercontent.com`) en `_ProfileHeader`. Debe ser configurable o usar asset placeholder. | 1h |
| 3 | **wifi_direct_service_test** | 2 tests skipped (`skip: true`) por depender de red real. Si se arregla #1, des-skippear. | 2h |

### Prioridad Media (capas faltantes — implementación)

| # | Feature | Tickets | Esfuerzo |
|---|---------|---------|----------|
| 4 | **sync** | Crear capa Domain (entities + repositorios). Actualmente es todo `data/` sin clean architecture. | 4h |
| 5 | **home** | Agregar Infrastructure layer para `HomeCubit` + servicios. | 2h |
| 6 | **onboarding** | Agregar Infrastructure layer para persistencia de onboarding. | 3h |
| 7 | **dashboard** | Feature entera: solo tiene Presentation. Crear D+I+A. | 4h |
| 8 | **email-citas** | Agregar Infrastructure + Application layers. Actualmente D+P. | 2h |
| 9 | **eps_connection** | Agregar Application layer (bloc). | 1h |
| 10 | **health_data_import** | Agregar Infrastructure layer. | 2h |
| 11 | **medical_research** | Agregar Application + Presentation layers. | 3h |

### Prioridad Baja (tests faltantes)

| # | Feature | Tests que faltan | Esfuerzo |
|---|---------|-----------------|----------|
| 12 | **allergies** | Unit tests para domain entities + cubit | 2h |
| 13 | **appointments** | Unit tests para domain entities + cubit | 2h |
| 14 | **calendar_import** | Unit tests para calendar_parser + cubit | 2h |
| 15 | **dashboard** | Sin código que testear aún | — |
| 16 | **email-citas** | Tests para email_service, reminder_service | 2h |
| 17 | **eps_connection** | Tests para oauth + cubit | 2h |
| 18 | **health_data_import** | Tests para parser + cubit | 2h |
| 19 | **home** | Tests para HomeCubit, HomeState, icd10_catalog | 2h |
| 20 | **medical_research** | Tests para research services + scrapers | 3h |
| 21 | **medications** | Tests para entities + repository + cubit | 2h |
| 22 | **onboarding** | Tests para onboarding cubit + services | 3h |
| 23 | **settings** | Tests para LLM config + settings cubit | 2h |
| 24 | **sync** | Tests para sync_cubit + node_discovery_service | 3h |
| 25 | **user_profile** | Tests para user_profile_cubit + repository_impl | 2h |
| 26 | **vitals** | Tests para v_calculator + repository | 2h |
| 27 | **about** | Ya tiene tests (presentación). Need D+I+A | — |
| 28 | **ai_assistant** | Ya tiene tests (presentación). Need D+I+A | — |

---

## Estado de Documentación

| Documento | Estado | Notas |
|-----------|--------|-------|
| `docs/ORIONHEALTH-ROADMAP.md` | ⚠️ Desactualizado | Dice v1.0.0, el proyecto está en v0.8.1 |
| `docs/ARCHITECTURE.md` | ✅ Actualizado | Referencias a `reports` corregidas |
| `docs/PRODUCTION_CHECKLIST.md` | ✅ Existe | 15 items |
| `docs/medical/MEDICAL_DATA_GAPS.md` | ✅ Existe | Lacunas de datos médicos |
| `docs/PRIVACY.md` | ⚠️ No verificado | — |

---

## Resumen de Bugs Activos

| Bug | Feature | Impacto | Archivo |
|-----|---------|---------|---------|
| HTTP ↔ Socket protocol mismatch | health_sharing | Funcional — `sendData` no puede comunicarse con `startServer` | `wifi_direct_service.dart` |
| Hardcoded image URL | user_profile | Golden test falla por NetworkImageLoadException | `user_profile_page.dart` |
| Sync cubit no mockeado en golden tests | sync, home | Golden screenshots requieren mock adicional | `main_navigation_page_golden_test.dart` |

---

## Esfuerzo Total Estimado para 100%

| Categoría | Items | Esfuerzo |
|-----------|-------|----------|
| 🐛 Bugs críticos | 3 | 6h |
| 🏗️ Capas faltantes (features sin clean arch) | 8 | 21h |
| 🧪 Tests faltantes | 14 | 25h |
| 📚 Docs desactualizados | 2 | 3h |
| **Total** | **27 tickets** | **~55h (2 semanas)** |

---

*Generado: 2026-06-09 | OrionHealth v0.8.1 → target v1.0.0*
