# AGENTS.md — OrionHealth Autonomous & AI Agent Guidelines

This document provides guidelines and system architecture context for AI coding agents operating on the **OrionHealth** repository under the **SWAL (SouthWest AI Labs)** standard.

---

## 🎯 SWAL Canonical Goal

**OrionHealth** is a sovereign, privacy-first personal health data sanctuary and medical intelligence platform.
- **100% On-Device & Offline-First**: All sensitive health data (PHI/PII) is processed and stored locally on the user's hardware.
- **Interoperable Standards**: Built-in support for FHIR R4, ICD-10, LOINC, RxNorm, SNOMED CT, and Self-Sovereign Identity (SSI) / Verifiable Credentials.
- **Sovereign Intelligence**: Local-first AI models (Gemma/Sherpa-ONNX) with local RAG agent memory (`isar_agent_memory`).

---

## 🗺️ PROJECT_MAP

```
OrionHealth/
├── lib/                        # Main Flutter mobile app (Clean Architecture)
│   ├── app/                    # App initialization, DI, routing
│   ├── core/                   # Shared services, themes, widgets, utilities
│   └── features/               # Feature modules (26 Clean Architecture features)
├── backend/                    # Node.js/Express FHIR integration backend
├── functions/                  # Cloud/Serverless functions
├── packages/                   # Dedicated local Dart packages
│   ├── health_wallet/          # SSI/DID & Verifiable Credentials wallet
│   ├── isar_agent_memory/      # Graph + Vector local DB for AI agent memory
│   └── medical_standards/      # Medical terminology mappings (ICD-10, LOINC, etc.)
├── docs/                       # Project documentation & SRS requirements
│   └── SRS/                    # Software Requirements Specifications (REQ-F-001 .. REQ-F-107)
├── .gitcore/                   # GitCore & SWAL metadata, harnesses, and schemas
│   ├── docs/                   # SWAL_GOAL.md canonical copy
│   └── features.json           # Canonical schema v2 feature status catalog
├── android/                    # Android platform runner & AICore Kotlin plugins
├── ios/                        # iOS platform runner
└── test/                       # Root unit & widget test suite
```

---

## 🌐 SWAL Ecosystem & Mesh Integration

- **Agent Routing & Service Mesh**: AI agents and services interface via standard protocol channels (e.g. `MethodChannel` for native AICore/Gemma bridge).
- **Xavier Namespace**: Core agent orchestration and multi-agent coordination components reference `apps/xavier` in the SWAL repository ecosystem.
- **GitCore Integration**: Repository metadata and feature tracking are maintained under `.gitcore/` following SWAL standards (`features.json` schema v2, `SRC.md`, `SWAL_GOAL.md`).

---

## 🤖 Agent Operating Rules

1. **Privacy & Security First**: Never output or transmit sensitive patient health information (PHI) or secret API keys.
2. **Clean Architecture**: Maintain standard layer separation (Presentation -> Application -> Domain <- Infrastructure).
3. **Targeted Tests**: Always verify code changes with tailored unit/widget test runs.
4. **Documentation Rules**:
   - Keep `features.json` in sync with actual implementation.
   - Follow SWAL documentation guidelines (English for code/docs artifacts, bilingual README allowed).

<!-- SWAL-ROUTING-START -->
## SWAL Routing Minimalista (SDD Hibrido F1)
> Antes de crear `.gitcore/sdd/` aplica routing organico (gentle-ai v2.3.0).
> - **Direct inline**: 1-3 files trivial -> inline sin delegar, sin SDD
> - **Delegated direct**: 4+ files o 2+ non-trivial -> delegate_task con Xavier skill search, sin SDD
> - **Optional SDD**: ambiguedad alta -> proponer SDD opcional, si SI crear `.gitcore/sdd/specs/###-feat/onepage.md` (1 pagina spec P1 + plan HOW minimo + tasks [P])
> Ver skill `sdd-hibrido` (`~/.hermes/skills/sdd-hibrido/references/routing.md`). `rm -rf .gitcore/sdd` limpia sin tocar features.json.
<!-- SWAL-ROUTING-END -->

<!-- SWAL-REGISTRY-START -->
## Skill Registry + Xavier Indexer (F1b)
> Skills viven FUERA de `.gitcore` (global `~/.hermes/skills` + proyecto `.skills/`). GitCore solo referencia via `.atl/skill-registry.md` + cache `.skill-registry.cache.json` y opcional `.gitcore/skill-registry.json`.
> - Refresh: `~/.hermes/scripts/skill-registry-refresh.sh --cwd <proyecto>`
> - Index: `~/.hermes/scripts/xavier-index-skills.sh --cwd <proyecto>` (Xavier tags [skill])
> - Antes de delegar: `xavier_search(tags=[skill]) -> skill_view(paths)`
> Ver skills `skill-registry` y `xavier-skill-indexer`.
<!-- SWAL-REGISTRY-END -->

<!-- SWAL-SDD-START -->
## SDD One-Page + SRS Mapping
> Spec efimero `.gitcore/sdd/specs/###-feat/onepage.md` referencia `REQ-xxx` durable de `docs/SRS/REQUIREMENTS.md` (IEEE 830 reduced). Drift detector `srs-src-drift-detector` mantiene traceabilidad. Docs humanos estables en `docs/`, specs AI en `.gitcore/sdd/` aislado.
<!-- SWAL-SDD-END -->
