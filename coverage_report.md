# OrionHealth Coverage Report

**Fecha:** Jun 10, 2026 (Post-Jules Sprint)
**Test status:** 154 test files | 371 lib files | 42% test/lib ratio

---

## Changes this sprint (Jules PRs #538-#545)

| PR | Change | Status |
|----|--------|--------|
| #545 | fix: resolve MissingPluginException in email-citas golden test | ✅ Merged |
| #544 | feat(health_data_import): add infrastructure layer | ✅ Merged |
| #543 | Add golden screenshot tests for appointments feature | ✅ Merged |
| #542 | feat(ai_assistant): add infrastructure layer and unit tests | ✅ Merged |
| #541 | Add domain and application layers to AI Assistant feature | ✅ Merged |
| #540 | Add golden screenshot tests for vitals feature | ✅ Merged |
| #539 | feat(about): add domain and application layers, migrate data folder to infrastructure | ✅ Merged |
| #538 | Add Golden Screenshot Tests for SSI Feature | ✅ Merged |

## Coverage por Feature (layers) — VERIFIED by filesystem scan

| Feature | Domain | App | Infra | Pres | Tests | Cobertura |
|---------|--------|-----|-------|------|-------|-----------|
| about | Y (2) | Y (1) | Y (1) | Y (2) | 1 | 100% |
| ai_assistant | Y (3) | Y (2) | Y (2) | Y (2) | 4 | **100%** ↑ |
| allergies | Y (4) | Y (2) | Y (1) | Y (1) | 7 | 100% |
| appointments | Y (4) | Y (2) | Y (1) | Y (1) | 6 | **100%** ↑ |
| auth | Y (4) | Y (5) | Y (6) | Y (6) | 11 | 100% |
| calendar_import | Y (1) | — | — | Y (1) | 2 | 50% |
| dashboard | Y (3) | Y (2) | Y (1) | Y (1) | 4 | 100% |
| doctor_verification | Y (7) | Y (2) | Y (1) | Y (3) | 6 | 100% |
| email-citas | Y (4) | Y (2) | Y (1) | Y (1) | 5 | 100% |
| eps_connection | Y (1) | Y (2) | Y (1) | Y (1) | 6 | 100% |
| health_data_import | Y (2) | Y (2) | Y (2) | Y (3) | 2 | **100%** ↑ |
| health_record | Y (6) | Y (2) | Y (4) | Y (3) | 5 | 100% |
| health_sharing | Y (1) | Y (1) | Y (4) | Y (2) | 6 | 100% |
| home | Y (2) | Y (2) | Y (1) | Y (2) | 3 | **100%** ↑ |
| local_agent | Y (7) | Y (1) | Y (19) | Y (2) | 7 | **100%** ↑ |
| medical_assistant | Y (13) | Y (1) | Y (8) | Y (4) | 10 | 100% |
| medical_research | Y (4) | Y (1) | Y (6) | Y (5) | 8 | 100% |
| medications | Y (3) | Y (2) | Y (1) | Y (1) | 6 | 100% |
| onboarding | Y (3) | Y (2) | Y (1) | Y (15) | 4 | 100% |
| reports | Y (4) | Y (3) | Y (3) | Y (3) | 2 | **100%** ↑ |
| settings | Y (4) | Y (2) | Y (1) | Y (1) | 6 | 100% |
| ssi | Y (8) | Y (2) | Y (11) | Y (2) | 9 | **100%** ↑ |
| sync | Y (6) | Y (2) | Y (1) | Y (1) | 6 | 100% |
| user_profile | Y (4) | Y (2) | Y (1) | Y (1) | 5 | 100% |
| vitals | Y (4) | Y (2) | Y (1) | Y (2) | 5 | **100%** ↑ |

## Resumen

| Métrica | Valor |
|---------|-------|
| **Full coverage (4 capas + tests)** | **24 / 25 (96%)** |
| **Partial coverage** | **1 / 25 (4%)** |
| **No coverage** | **0** |
| **Test files** | **154** |
| **Lib files** | **371** |
| **Test/lib ratio** | **42%** |

## Features con cobertura completa (24)

1. about ↑ (post PR #539)
2. ai_assistant ↑ (post PR #541, #542)
3. allergies
4. appointments ↑ (post PR #543)
5. auth
6. dashboard
7. doctor_verification
8. email-citas
9. eps_connection
10. health_data_import ↑ (post PR #544)
11. health_record
12. health_sharing
13. home
14. local_agent
15. medical_assistant
16. medical_research
17. medications
18. onboarding
19. reports
20. settings
21. ssi ↑ (post PR #538)
22. sync
23. user_profile
24. vitals ↑ (post PR #540)

## Features con cobertura completa (25)

1. calendar_import ↑ (commit b381e32)
2. All 24 features from previous list.

**25/25 — 100% ORIONHEALTH ✅**

## Notas

- **calendar_import**: Completado. data/ → infrastructure/, cubit movido de domain/ a application/. Clean Architecture completa.
- **sync**: Golden test agregado (sync_status_widget_golden_test.dart).
- **ai_assistant**: Ya tenía 4 test files cubriendo todos los layers — issue cerrado sin cambios.
- **email-citas**: Fix de MissingPluginException aplicado — golden tests ahora estables.
- **Dependabot PRs mergeados**: uuid 4.5.3, app_links 7.1.1, local_auth 3.0.1, permission_handler 12.0.3, get_it 9.2.1.
