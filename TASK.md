

# TASK.md

Gestión de Tareas: OrionHealth
_Última actualización: 2025-11-24_

## 🎯 Resumen Ejecutivo y Estado Actual

**Estado General:** [95% - Integración Completa]
Se han integrado los módulos en la aplicación principal. La navegación funciona y se ha verificado el build de Android.

**Progreso por Componente:**

- [x] 🏗️ Infraestructura Base: 100% (DI, Isar, Theme)
- [x] 👤 Perfil y Datos: 100% (Entidad, Repo, UI)
- [x] 📥 Ingesta y Curación: 100% (Entidad, Servicios, UI)
- [x] 🧠 IA Local (Chat/RAG): 90% (Chat UI, Mock LLM, Vector Interface)
- [ ] 📊 Reportes y Planes: 0%

---

## 🏎️ Pistas de Trabajo Paralelo (Sprints)

Para evitar conflictos de merge, el trabajo se divide en 3 pistas independientes basadas en la arquitectura hexagonal. Cada agente debe trabajar **exclusivamente** en sus directorios asignados.

### 🛤️ Pista A: Core & Perfil de Usuario (Agente 1)

**Directorios Permitidos:** `lib/core/`, `lib/features/user_profile/`, `lib/main.dart`, `lib/injection.dart`

- [x] **A-01**: Configuración inicial de Hexagonal Architecture y DI (`get_it`, `injectable`).
- [x] **A-02**: Configuración base de Isar (Provider global).
- [x] **A-03**: Feature `user_profile`: Entidad `UserProfile`, Repositorio y BLoC.
- [x] **A-04**: UI: Pantalla de Onboarding y Edición de Perfil.

### 🛤️ Pista B: Ingesta y Registros Médicos (Agente 2)

**Directorios Permitidos:** `lib/features/health_record/`
**Nota:** No tocar `main.dart`. Crear widgets exportables.

- [x] **B-01**: Feature `health_record`: Entidad `MedicalRecord` y `MedicalAttachment`.
- [x] **B-02**: Servicio de Infraestructura: `FilePickerService` y `ImagePickerService`.
- [x] **B-03**: Lógica de "Staging Area" (Bandeja de entrada de documentos).
- [x] **B-04**: UI: Pantalla de carga de documentos y validación (Curación).

### 🛤️ Pista C: Inteligencia Artificial Local (Agente 3)

**Directorios Permitidos:** `lib/features/local_agent/`
**Nota:** Asumir interfaces genéricas si el Core no está listo.

- [x] **C-01**: Feature `local_agent`: Entidad `ChatMessage` y `HealthInsight`. _(ChatMessage completado)_
- [x] **C-02**: Servicio de Infraestructura: `LlmInferenceService` (Stub inicial o integración ONNX). _(MockLlmService implementado)_
- [x] **C-03**: Lógica RAG: Definir interfaz para búsqueda de vectores.
- [x] **C-04**: UI: Chat Interface con soporte para Markdown y Streaming. _(ChatPage completado)_

---

## 🔗 Puntos de Integración (Merge)

_Tareas que se realizan una vez las 3 pistas convergen._

- [x] **I-01**: Registrar `HealthRecordRepository` y `LlmService` en el DI (`injection.dart`).
- [x] **I-02**: Añadir rutas de navegación en `main.dart` o `app_router.dart`.
- [ ] **I-03**: Conectar el RAG (Agente C) con la base de datos de Registros (Agente B).

---

## ✅ Hitos Principales Completados

- Hito 0: Configuración inicial y CI/CD (APK Build).
- Hito C1: Chat UI con LLM Mock y soporte para Markdown/Streaming (PR #2).
- Hito A1: Core Architecture & User Profile (DI, Isar, Theme, Profile UI).
- Hito B1: Ingestion & Medical Records (Entities, Services, Staging UI).
- Hito M1: Main Integration & Navigation (BottomBar, DI Wiring).

---

## 📝 Tareas Descubiertas Durante el Desarrollo

| ID    | Tarea                                        | Prioridad | Estado      | Responsable |
|-------|----------------------------------------------|-----------|-------------|-------------|
| T0-02 | Crear estructura de carpetas (Hexagonal)     | ALTA      | ✅ Completado | Antigravity |
| T0-03 | Configurar dependencias base (pubspec)       | ALTA      | ✅ Completado | Antigravity |
| TC-01 | Entidad ChatMessage con Isar                 | ALTA      | ✅ Completado | PR #2       |
| TC-02 | Interfaz LlmService y MockLlmService         | ALTA      | ✅ Completado | PR #2       |
| TC-03 | Chat UI con Markdown y Streaming             | ALTA      | ✅ Completado | PR #2       |
| TA-01 | Configuración DI y Theme                     | ALTA      | ✅ Completado | Antigravity |
| TA-02 | Módulo Database (Isar)                       | ALTA      | ✅ Completado | Antigravity |
| TA-03 | Feature UserProfile (Domain/Infra/UI)        | ALTA      | ✅ Completado | Antigravity |
| TC-03 | Chat UI con Markdown y Streaming             | ALTA      | ✅ Completado | PR #2       |
| TA-01 | Configuración DI y Theme                     | ALTA      | ✅ Completado | Antigravity |
| TA-02 | Módulo Database (Isar)                       | ALTA      | ✅ Completado | Antigravity |
| TA-03 | Feature UserProfile (Domain/Infra/UI)        | ALTA      | ✅ Completado | Antigravity |
| TB-01 | Feature HealthRecord (Domain)                | ALTA      | ✅ Completado | Antigravity |
| TB-02 | Servicios Ingesta (File/Image/OCR)           | ALTA      | ✅ Completado | Antigravity |
| TB-03 | UI Staging Area                              | ALTA      | ✅ Completado | Antigravity |
| TC-04 | Interfaz VectorStoreService (RAG)            | MEDIA     | ✅ Completado | Antigravity |
| -     | -                                            | -         | -           | -           |
