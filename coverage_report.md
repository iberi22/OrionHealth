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

## Coverage por Feature (layers)

| Feature | Domain | App | Infra | Pres | Tests | Cobertura |
|---------|--------|-----|-------|------|-------|-----------|
| about | N (2 files) | N (1) | N (1) | Y (2) | 1 | 25% |
| ai_assistant | Y (3) | Y (2) | Y (2) | Y (2) | 4 | **100%** ↑ |
| allergies | Y (4) | Y (2) | Y (1) | Y (1) | 7 | 100% |
| appointments | Y (4) | Y (2) | Y (1) | Y (1) | 6 | **100%** ↑ |
| auth | N (4) | Y (5) | Y (6) | Y (6) | 11 | 75% |
| calendar_import | Y (1) | — | — | N (1) | 2 | 50% |
| dashboard | N (3) | Y (2) | Y (1) | Y (1) | 4 | 75% |
| doctor_verification | Y (7) | N (2) | Y (1) | Y (3) | 6 | 75% |
| email-citas | Y (4) | Y (2) | Y (1) | Y (1) | 5 | 100% |
| eps_connection | N (1) | Y (2) | Y (1) | Y (1) | 6 | 75% |
| health_data_import | Y (2) | N (2) | N (2) | N (3) | 2 | 25% |
| health_record | Y (6) | Y (2) | Y (4) | Y (3) | 5 | 100% |
| health_sharing | Y (1) | Y (1) | Y (4) | Y (2) | 6 | 100% |
| home | N (2) | N (2) | N (1) | Y (2) | 3 | 25% |
| local_agent | N (7) | N (1) | Y (19) | Y (2) | 7 | 50% |
| medical_assistant | Y (13) | N (1) | Y (8) | Y (4) | 10 | 75% |
| medical_research | N (4) | Y (1) | Y (6) | Y (5) | 8 | 75% |
| medications | N (3) | Y (2) | Y (1) | Y (1) | 6 | 75% |
| onboarding | Y (3) | Y (2) | N (1) | Y (15) | 4 | 75% |
| reports | N (4) | N (3) | Y (3) | Y (3) | 2 | 50% |
| settings | Y (4) | Y (2) | Y (1) | Y (1) | 6 | 100% |
| ssi | N (8) | Y (2) | Y (11) | Y (2) | 9 | **75%** ↑ |
| sync | Y (6) | Y (2) | N (1) | Y (1) | 6 | 75% |
| user_profile | Y (4) | Y (2) | Y (1) | Y (1) | 5 | 100% |
| vitals | Y (4) | Y (2) | Y (1) | Y (2) | 5 | **100%** ↑ |

## Resumen

| Métrica | Valor |
|---------|-------|
| **Full coverage** | **9 / 25 (36%)** |
| **Partial coverage** | **16 (64%)** |
| **No coverage** | **0** |
| **Test files** | **154** |
| **Lib files** | **371** |
| **Test/lib ratio** | **42%** |

## Features con cobertura completa (9)

1. ai_assistant ↑
2. allergies
3. appointments ↑
4. email-citas
5. health_record
6. health_sharing
7. settings
8. user_profile
9. vitals ↑

## Features con gap más grande

1. **about** — 25% (solo presentation tiene tests, domain/app/infra sin tests)
2. **home** — 25% (solo presentation tiene tests)
3. **health_data_import** — 25% (solo domain tests, app/infra/pres sin tests)

## Notas

- **ssi**: Subió de 50% → 75% gracias a golden tests. Domain requiere atención (8 files sin tests dedicados en subcarpeta).
- **about**: PR #539 agregó capas domain/app/infra pero sin tests. Necesita unit tests nuevos.
- **health_data_import**: PR #544 agregó infraestructura pero sin tests. Solo tiene 2 domain tests pre-existentes.
- **email-citas**: Fix de MissingPluginException aplicado — golden tests ahora estables.
