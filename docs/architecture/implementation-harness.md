# ============================================================================
# OrionHealth Implementation Harness — Goal-Driven Architecture
# ============================================================================
# Dependencias: PowerShell 7+, git, gh CLI, flutter
# Ubicación: .gitcore/orionhealth-harness.ps1
#
# Ciclo de Vida:
#   1. SCAN → Escanea el proyecto real (features, tests, goldens, docs, CI/CD)
#   2. REPORT → Genera reporte con % de implementación ponderado
#   3. DETAILS → Crea/actualiza .gitcore/features.details/<feature>.json
#   4. UPDATE → Actualiza .gitcore/features.json con estado global
#   5. AGENT → Jules/OpenCode toma los gaps y ejecuta implementación
#   6. E2E → Scripts automatizados validan coverage y tests
#   7. HUMAN → 1% de review humano en cada feature
#
# Ponderación (%):
#   Architecture (25%)  — 4 capas clean architecture
#   Tests (30%)         — >=20 tests por feature
#   Golden Tests (10%)  — >=2 golden references visuales
#   E2E/Integration (10%) — Feature cubierta en integration tests
#   Documentation (10%) — README + i18n translations
#   CI/CD (5%)          — Workflows, builds, deploy
#   Human Review (1%)   — Feedback humano (no automatizable)
#
# Loop Goal-Driven:
#   Mientras haya features < 100%:
#     1. Invocar scan
#     2. Identificar gaps prioritarios
#     3. Asignar a Jules (label jules en issues)
#     4. Integrar PRs automáticamente
#     5. Re-scanear para actualizar %
#     6. Reportar al humano
#
# ============================================================================
