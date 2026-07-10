# 🏥 OrionHealth — Plan de Preparación para Open Beta

> **Versión:** v0.9.0 → v1.0.0  
> **Fecha:** Julio 2026  
> **Repo:** iberi22/OrionHealth  
> **Score Actual:** 100% (26/26 features)

---

## 📊 Estado Actual

| Métrica | Valor | Status |
|---------|-------|--------|
| Features | 26/26 al 100% | ✅ |
| Score global | 100% | ✅ |
| Ramas | Solo `main` | ✅ |
| PRs abiertos | 0 | ✅ |
| CI en main | Failure en últimos runs | ❌ |
| Issues abiertos (jules) | 8 (documentación + gitcore) | 🟡 En progreso |
| Archivos en raíz | 14 estándar | ✅ Limpio |
| SRS formal | Pendiente (Jules #1447) | 🟡 |
| PREPRODUCTION_CHECKLIST.md | Creado | ✅ |

---

## 📋 Plan de Acción — 6 Fases

### FASE 1 ✅ COMPLETADA — Limpieza de Repositorio
- [x] Score 100% (26/26 features)
- [x] Todas las ramas eliminadas (solo `main`)
- [x] PRs mergeados (#1444, #1445, #1446, #1447, #1448)
- [x] PREPRODUCTION_CHECKLIST.md creado
- [x] Limpieza de raíz: de 50 → 14 archivos estándar
- [x] `.gitignore` actualizado (*.dill, docs/diagnostics/, .metadata, .git-core-protocol-version)
- [x] `isar.dll` removido de tracking git
- [x] Archivos espurios (`nul`, `null`) eliminados
- [x] Scripts movidos a `scripts/`
- [x] `.md` extra movidos a `docs/`
- [x] Outputs de diagnóstico movidos a `docs/diagnostics/`

⚠️ **CORRECCIÓN NECESARIA EN FASE 1:**
- `features.json` fue movido a `docs/diagnostics/` — **DEBE VOLVER a la raíz**. Es archivo crítico para SRS y score.
- `.git-core-protocol-version` fue movido a `docs/` — debería estar en `.gitignore`, no versionado en docs.
- Verificar que `docs/diagnostics/` esté en `.gitignore` como se planeó.

### FASE 2 🟡 EN PROGRESO — SRS + Documentación (Jules)
| # | Tarea | Issue | Estatus |
|---|-------|-------|---------|
| 1 | SRS Core Document (docs/SRS.md) — IEEE 830 | #1447 | 🟡 |
| 2 | Offline AI Agent docs (local_agent) | #1448 | 🟡 |
| 3 | SURA + Colombia Health Data API plan | #1449 | 🟡 |
| 4 | Non-functional Requirements (seguridad, compliance) | #1450 | 🟡 |
| 5 | Full Project Audit (feature vs tests vs docs vs SRS) | #1451 | 🟡 |
| 6 | Roadmap Alignment con SRS | #1452 | 🟡 |
| 7 | Docs Site Sync (Astro) | #1453 | 🟡 |
| 8 | GitCore housekeeping (scripts/RULES.md, .gitignore) | #1455 | 🟡 |

### FASE 3 🔜 — Corrección de Fase 1
- [ ] **Restaurar `features.json` a la raíz** — mover `docs/diagnostics/features.json` → `features.json`
- [ ] **Mover `.git-core-protocol-version` a archivo ignorado** — no docs
- [ ] **Verificar `docs/diagnostics/` en `.gitignore`**
- [ ] **Commit + push** de correcciones
- [ ] **Cerrar issue #1455** (GitCore cleanup)

### FASE 4 🔜 — CI/CD y Testing
- [ ] **Reparar CI** — investigar por qué falla en main (últimos 5 runs todos failure)
- [ ] **Ejecutar PREPRODUCTION_CHECKLIST** script de verificación
- [ ] **Verificar tests pasando** (687 test files)
- [ ] **Asegurar coverage gate 80%** funcional
- [ ] **Dependabot configurado** (.github/dependabot.yml)
- [ ] **Build Android funcional** (flutter build apk --release)
- [ ] **Build Web funcional** (flutter build web --web-renderer canvaskit)

### FASE 5 🔜 — Seguridad y Compliance
- [ ] **Verificar SSI (health_wallet) implementado** en todas las características
- [ ] **Verificar offline-first** en features críticos (local_agent, health_record, sync)
- [ ] **Verificar cifrado AES-256-GCM** en datos sensibles
- [ ] **Documentar compliance regulatorio Colombia** (Ley 1581/2012, Ley 2015/2020)
- [ ] **Política de privacidad** clara (qué datos se comparten vs qué queda on-device)

### FASE 6 🔜 — Open Beta Launch
- [ ] **Tag semántico** — `git tag v1.0.0-beta`
- [ ] **Release notes** en GitHub Releases
- [ ] **Changelog actualizado** con v1.0.0 entries
- [ ] **SRS v1.0 finalizado** y accesible desde docs site
- [ ] **Score documentation** ≥90%
- [ ] **PREPRODUCTION_CHECKLIST** score ≥27/29
- [ ] **Anuncio de Open Beta** en GitHub Discussions

---

## 📈 Timeline Estimado

```
Semana 1 (Jul 6-12) — FASE 1 ✅ + FASE 2 🟡
  |-- Jules procesando SRS y documentación
  |-- Correcciones de raíz
  
Semana 2 (Jul 13-19) — FASE 3 + FASE 4
  |-- Merge PRs de Jules
  |-- CI/CD reparado
  |-- Tests verificados

Semana 3 (Jul 20-26) — FASE 5
  |-- Seguridad y compliance
  |-- Auditoría final

Semana 4 (Jul 27-31) — FASE 6
  |-- Tag, release, anuncio
  |-- 🚀 OPEN BETA
```

---

## 🔍 Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|---------|------------|
| Jules tarde en completar issues | Media | Medio | Dividir issues más pequeños si es necesario |
| CI sigue fallando | Media | Alto | Investigar logs y reparar antes de release |
| Coverage gate falle en CI | Baja | Medio | Ya mergeado PR #1444, verificar en main |
| features.json no restaurado | Alta | Bajo | Corregir inmediatamente — es crítico para SRS |
| Compliance Colombia incompleto | Media | Alto | Documentar requisitos regulatorios en SRS |

---

## 🏆 Objetivo Final

**OrionHealth v1.0.0-beta — Open Beta ready**

Con:
- ✅ Score 100% features
- ✅ SRS formal documentado
- ✅ Documentación completa (local_agent, SURA, offline AI, compliance)
- ✅ CI/CD verde
- ✅ Tests pasando con coverage ≥80%
- ✅ Seguridad verificada (SSI, cifrado, offline-first)
- ✅ Repo limpio y profesional
- ✅ Checklist pre-producción score ≥27/29

---

*Documento creado: Julio 2026 | Próxima revisión: al completar FASE 2*
