# Sprint: OrionHealth Lint Cleanup — 50 issues restantes

**Fecha:** 2026-05-03
**Objetivo:** Reducir flutter analyze de 50 a 0 issues

## Issues restantes por categoría

### 1. Deprecated APIs (info) — ~15 issues
- `background`/`onBackground` → `surface`/`onSurface` (cyber_theme.dart)
- `withOpacity` → `withValues(alpha:)` (integration tests)
- `groupValue`/`onChanged` → `RadioGroup` (multiple share pages)
- `activeColor` → `activeThumbColor` (privacy_step.dart)
- `value` → `initialValue` (health_record_staging_page.dart)

### 2. Unused imports (warning) — ~8 issues
- `dart:ui` (reports_page, health_record_staging_page)
- `package:medical_standards.dart` (fhir, medical_context_categories — YA FIXED)
- Test file imports
- `package:flutter_bloc/flutter_bloc.dart` (settings, user_profile)

### 3. Unused fields/variables (warning) — ~10 issues
- `_pendingPackage` (ble_sharing_cubit, sharing_cubit)
- `_dio`, `_baseUrl` (medical_search_adapters)
- `_labInterpreter`, `_vitalAnalyzer`, `_riskCalculator` (medical_assistant_cubit)
- `chunk` (ble_sharing_service)
- `algorithm` (health_wallet encryption_service)

### 4. Other — ~10 issues
- `unnecessary_non_null_assertion` (medical_llm_adapter)
- `depend_on_referenced_packages` (bloc imported without dependency)
- `prefer_interpolation_to_compose_strings` (mock_llm_adapter, rag_llm_service)
- `use_build_context_synchronously` (medications_page, onboarding pages)

## Estrategia
- Fáciles (unused imports, fields) primero → ~18 issues
- Deprecated APIs → ~15 issues
- Dependencias (bloc) → ~5 issues
- Restantes → ~12 issues

## Agentes
- **Agent 1 (Codex):** Unused imports, unused fields, unnecessary this, prefer_interpolation
- **Agent 2 (Gemini):** Deprecated APIs, bloc dependencies, context issues
