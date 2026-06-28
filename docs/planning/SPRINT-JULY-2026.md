# Sprint Plan — July 2026

> **Goal:** Preparar OrionHealth para open beta (v0.9.x) — CI verde, tests actualizados, landing page pulida.
> **Repositorio:** https://github.com/iberi22/OrionHealth
> **Reglas:** Max 1-3 archivos por issue. Un issue por feature/task. Label `jules` activa Jules.

---

## Phase 1: Infrastructure & Cleanup (CRÍTICO — hacer primero)

Estos issues preparan el terreno. Sin estos, los tests no pasan y el CI no sirve.

### #1.1 🔧 Add untracked generated files to .gitignore
**Archivos:** `.gitignore`
**Qué hacer:**
- Agregar al `.gitignore` los patrones de archivos generados que no deben trackearse:
  - `injection.config.dart`
  - `*.g.dart`
  - `*.freezed.dart`
  - `*.mocks.dart`
- Verificar que estos archivos no estén ya trackeados en git (si lo están, git rm --cached con confirmación)

### #1.2 🔧 Commit generated files as source of truth
**Alternativa a #1.1 (elegir cualquiera):**
- Si la decisión es mantener archivos generados en el repo (build_runner como step de build):
  - Hacer git add de todos los untracked: `lib/**/*.g.dart`, `lib/**/*.freezed.dart`, `injection.config.dart`, `test/**/*.mocks.dart`
  - Commit: `chore: commit generated files from build_runner`

### #1.3 🔧 Fix flutter analyze — 1,108 errors
**Archivos:** Múltiples archivos de test (`test/**/*.dart`)
**Qué hacer:**
- Ejecutar `flutter analyze` y capturar output completo
- Identificar TODOS los errores de test que referencian parámetros `dateTime`, `id`, `timestamp` que ya no existen en la API actual
- Corregir parámetros para que coincidan con la API actual de las entities
- NO borrar tests — solo actualizar las referencias
- Verificar con `flutter analyze` después de cada lote de correcciones

### #1.4 🔧 Regenerate golden reference PNGs for updated UI
**Archivos:** `test/golden/reference/*.png`
**Qué hacer:**
- Ejecutar golden tests: `flutter test test/widgets/golden_screenshots_test.dart --update-goldens`
- Confirmar que las nuevas referencias coinciden con el UI actual
- Verificar que los PNGs de `test/golden/reference/` estén actualizados con el theme/layout actual

### #1.5 🔧 Remove golden test failure directories from gitignore
**Archivos:** `.gitignore`
**Qué hacer:**
- Verificar si hay directorios de fallos de golden tests (test/golden/failures) en el gitignore
- Si existen, removerlos para tracking
- Agregar documentación sobre golden test workflow

---

## Phase 2: Screenshots & Landing Page (COMPLETAR)

### #2.1 🖼️ Replace remaining mock screenshots with real UI screenshots
**Archivos:**
- `docs/public/screenshots/06_upload_buttons.png`
- `docs/public/screenshots/07_profile_form.png` a `10_flow_04_reports.png`
- `integration_test/screenshot_flow_e2e_test.dart`
**Qué hacer:**
- Las screenshots `06` a `10` en `docs/public/screenshots/` aún usan mock UI (del 21 Jun)
- Ejecutar `screenshot_flow_e2e_test.dart` en emulador para generar screenshots reales
- Reemplazar los 8 mock PNGs con los nuevos screenshots reales
- Verificar que las screenshots estén en alta calidad y representen el UI actual

### #2.2 🖼️ Sync integration_test screenshots with real UI
**Archivos:**
- `integration_test/screenshots/*.png` (13 archivos)
**Qué hacer:**
- Los screenshots en `integration_test/screenshots/` son del 21 Jun (mock UI)
- Reemplazar con capturas del UI real generadas por `screenshot_flow_e2e_test.dart`
- O borrarlos si ya no se usan y `screenshot_flow_e2e_test.dart` genera en `docs/public/screenshots/`

### #2.3 🖼️ Final verification of landing page links and stats
**Archivos:**
- `docs/TASK_LANDING.md`
- `docs/src/pages/index.astro`
**Qué hacer:**
- Verificar que todos los links en el landing page funcionen
- Actualizar stats (test count, golden refs, features) con valores reales del código
- Verificar que el build de Astro compile clean: `cd docs && npm run build`

---

## Phase 3: Code Quality & Technical Debt

### #3.1 🔧 Fix unused import in allergies entity
**Archivos:** `lib/features/allergies/domain/entities/allergy.dart`
**Qué hacer:**
- Remover `import 'package:equatable/equatable.dart'` si no se usa directamente
- Verificar que compile: `flutter analyze lib/features/allergies/`

### #3.2 🔧 Add golden tests for 6 features missing them
**Archivos:**
- `test/features/about/presentation/pages/about_page_golden_test.dart` (actualizar)
- `test/features/ai_assistant/presentation/pages/` (crear golden test)
- `test/features/calendar_import/presentation/pages/goldens/` (crear golden test)
- `test/features/health_data_import/presentation/pages/` (crear golden test)
- `test/features/sync/presentation/pages/goldens/` (crear golden test)
- `test/features/user_profile/presentation/pages/` (crear golden test)
**Qué hacer:**
- Cazar patrones de golden tests existentes para copiar estructura
- Cada test: widget test que captura PNG de referencia
- Seguir el patrón de `test/core/golden_test_utils.dart`

### #3.3 🔧 Remove legacy data/ directories from doctor_verification and sync
**Archivos:**
- `lib/features/doctor_verification/data/` (4 archivos legacy)
- `lib/features/sync/data/` (5 archivos legacy)
**Qué hacer:**
- Verificar que infrastructure barrel re-exporta correctamente (sin apuntar a legacy data/)
- Migrar contenido útil de data/ a infrastructure/ si es necesario
- Eliminar directorios data/ legacy
- Verificar imports en toda la codebase

### #3.4 🔧 Add domain entities to calendar_import
**Archivos:**
- `lib/features/calendar_import/` (crear domain layer)
**Qué hacer:**
- Domain entities están inline en el cubit
- Extraer a `lib/features/calendar_import/domain/entities/`
- Actualizar imports en el cubit

### #3.5 🔧 Fix health_sharing BLE and WiFi stubs
**Archivos:**
- `lib/features/health_sharing/` (BLE + WiFi implementations)
**Qué hacer:**
- `startAdvertising()` es un stub con TODO
- `discoverDevices()` retorna mock data hardcoded
- Implementar real BLE peripheral mode (o agregar error claro si no hay soporte)
- Implementar real WiFi discovery
- Marcar en FEATURE_AUDIT.md si queda como known limitation

---

## Phase 4: CI/CD & Release

### #4.1 🔧 Verify CI passes after test fixes
**Archivos:** `.github/workflows/ci.yml`
**Qué hacer:**
- Después de #1.3 (flutter analyze fix), push y verificar que CI pase
- Si no pasa, iterar hasta verde
- Configurar badge en README.md

### #4.2 🔧 Create v0.9.x release checklist and verify
**Archivos:** (crear release tag)
**Qué hacer:**
- Revisar `docs/PRODUCTION_CHECKLIST.md`
- Verificar que todo está OK
- Crear tag v0.9.0 + push
- Verificar que GitHub Actions android_build.yml genere APK

### #4.3 🔧 Update FEATURE_AUDIT.md with current Sprint state
**Archivos:** `docs/FEATURE_AUDIT.md`
**Qué hacer:**
- Actualizar test counts, golden refs, feature status
- Marcar issues resueltos como FIXED
- Agregar sección con issues de este sprint

---

## Ejecución

**Orden recomendado:**
```
Phase 1 → Phase 2 → Phase 3 → Phase 4
```

**Cómo ejecutar:**
1. Jules: issues Phase 1 y Phase 3 (tasks de código)
2. Claude Code (Codex CLI): Phase 2 (screenshots + landing)
3. Manual: Phase 4 (release)
4. **Push siempre antes de asignar a Jules**

**Máximo 1-3 archivos por issue para Jules. Issues grandes = fallan.**
