# OrionHealth Coverage Report

**Fecha:** Jun 10, 2026
**Test status:** 325 pass, 2 fail (email-citas golden — MissingPluginException pre-existing)

---

## Coverage por Feature (layers)

| Feature | Domain | App | Infra | Pres | Cobertura |
|---------|--------|-----|-------|------|-----------|
| about | — | — | — | ✅ | 100% |
| ai_assistant | — | — | — | ✅ | 100% |
| allergies | ✅ | ✅ | ✅ | ✅ | 100% |
| appointments | ✅ | ✅ | ✅ | ✅ | 100% |
| auth | ⬜ | ✅ | ✅ | ✅ | 75% |
| calendar_import | ✅ | — | — | ⬜ | 50% |
| dashboard | ⬜ | ✅ | ✅ | ✅ | 75% |
| doctor_verification | ✅ | ⬜ | ✅ | ✅ | 75% |
| email-citas | ✅ | ✅ | ✅ | ✅ | 100% |
| eps_connection | ⬜ | ✅ | ✅ | ✅ | 75% |
| health_data_import | ✅ | ⬜ | — | ⬜ | 33% |
| health_record | ✅ | ✅ | ✅ | ✅ | 100% |
| health_sharing | ✅ | ✅ | ✅ | ✅ | 100% |
| home | ⬜ | ⬜ | ⬜ | ✅ | 25% |
| local_agent | ⬜ | ⬜ | ✅ | ✅ | 50% |
| medical_assistant | ✅ | ⬜ | ✅ | ✅ | 75% |
| medical_research | ⬜ | ✅ | ⬜ | ✅ | 50% |
| medications | ⬜ | ✅ | ⬜ | ✅ | 50% |
| onboarding | ✅ | ✅ | ⬜ | ✅ | 75% |
| reports | ⬜ | ⬜ | ✅ | ✅ | 50% |
| settings | ✅ | ✅ | ✅ | ✅ | 100% |
| ssi | ⬜ | ✅ | ✅ | ⬜ | 50% |
| sync | ✅ | ✅ | ⬜ | ✅ | 75% |
| user_profile | ✅ | ✅ | ✅ | ✅ | 100% |
| vitals | ✅ | ✅ | ✅ | ⬜ | 75% |

## Resumen

| Métrica | Valor |
|---------|-------|
| **Full coverage** | **9 / 25 (36%)** |
| **Partial coverage** | **16 (64%)** |
| **No coverage** | **0** |
| **Test files** | **143** |
| **Lib files** | **359** |
| **Test/lib ratio** | **40%** |

## Features con cobertura completa (9)

1. about
2. ai_assistant
3. allergies
4. appointments
5. email-citas
6. health_record
7. health_sharing
8. settings
9. user_profile

## Features con gap más grande

1. **home** — 25% (solo presentation tiene tests)
2. **health_data_import** — 33% (domain sí, app no existe, infra/pres no tienen tests)
3. **calendar_import** — 50% (domain sí, no tiene presentation tests)
4. **local_agent** — 50% (solo infra/pres)
5. **medical_research** — 50% (app sí, domain/infra no)
6. **medications** — 50% (app/pres sí, domain/infra no)
7. **reports** — 50% (infra/pres sí, domain/app no)
8. **ssi** — 50% (app/infra sí, domain/pres no)

## Test Status

```
325 pass ✅ | 2 fail ⚠️ (email-citas golden — MissingPluginException, pre-existing)
```
