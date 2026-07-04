# Jules + Harness Integration — OrionHealth

## Cómo Funciona

El cron `orionhealth-harness-scan` corre cada 4h y resuelve gaps **ligeros** (crear READMEs, placeholders).
Jules resuelve gaps **pesados** que requieren >300s: golden tests reales, arquitectura completa, tests complejos.

## Reparto de Gaps

| Gap | Tamaño | Responsable | Tiempo |
|-----|--------|-------------|--------|
| READMEs faltantes | ✅ Pequeño | Cron | ~10s |
| Golden tests (0→2 refs) | 🟡 Mediano | **Jules** | ~2-5min por feature |
| Tests < 15 | 🟡 Mediano | **Jules** | ~2-3min por feature |
| network architecture incompleta | 🔴 Grande | **Jules** (1 issue completo) | ~10min |
| CI/CD workflows | 🟡 Mediano | **Jules** | ~5min |
| PWA docs expansion (#1017) | 🔴 Grande | Jules | ~15min |
| E2E tests faltantes | 🟡 Mediano | **Jules** | ~3min por feature |

## Pipeline Automático

```
Cada 4h (cron):
  1. Harness scan → detecta gaps
  2. Cron resuelve gaps ligeros (placeholders, READMEs)
  3. Si detecta gap pesado → crea GH issue con label `jules`
  4. Jules resuelve el issue → push a main
  5. Siguiente cron corre scan → detecta mejora → commitea

Issues para Jules siguen naming convention:
  "[jules-harness] <feature>: <tarea> — <detalle>"
```

## Features que Jules Debe Resolver (orden de impacto)

### Prioridad 1: Golden Tests (más impacto en score)
Cada golden test suma ~0.1% al score global. 18 features sin goldens = ~9% potencial.

Features que necesitan goldens: about, allergies, appointments, auth, dashboard, email-citas, eps_connection, health_data_import, health_record, home, local_agent, medications, network, onboarding, reports, settings, user_profile, vitals, voice_chat

### Prioridad 2: Tests Coverage < 15
about (12), dashboard (12), medications (12), user_profile (12)

### Prioridad 3: Arquitectura network
network solo tiene 3 capas (governance, incentives, network_health), necesita application + presentation.

### Prioridad 4: E2E tests
Faltan en 14 features.

## Script de Disparo Automático

El script `.gitcore/jules-trigger.ps1` analiza `.scan-latest.json` y crea issues automáticamente:
- Si encuentra features con goldenCount=0 → crea issue "Add golden tests for X"
- Si encuentra features con testCount<15 → crea issue "Increase test coverage for X"
- Si encuentra features con hasFullArch=false → crea issue "Complete architecture for X"

Ver `.gitcore/jules-trigger.ps1` para el trigger automático.

## Score Esperado Después de Jules

| Paso | Score |
|------|-------|
| Actual (solo READMEs) | 86.5% |
| + Golden tests (18 features) | ~93% |
| + Tests coverage (4 features) | ~95% |
| + Network architecture | ~96% |
| + E2E tests | ~98% |
| = **Máximo automático** | **~99%** (humano da feedback final) |
