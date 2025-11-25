# TASK.md

Gestión de Tareas: OrionHealth
_Última actualización: 2025-11-24_

## 🎯 Resumen Ejecutivo y Estado Actual

**Estado General:** [5% - Planificación Detallada]
Se ha definido la arquitectura y el flujo de trabajo CI/CD. Ahora nos enfocamos en la implementación de los módulos críticos en orden de dependencia y valor.

**Progreso por Componente:**

- [ ] 🏗️ Infraestructura Base: 10%
- [ ] 👤 Perfil y Datos: 0%
- [ ] 📥 Ingesta y Curación: 0%
- [ ] 🧠 IA Local (Chat/RAG): 0%
- [ ] 📊 Reportes y Planes: 0%

---

## 🏎️ Pistas de Trabajo Paralelo (Sprints)

Para evitar conflictos de merge, el trabajo se divide en 3 pistas independientes basadas en la arquitectura hexagonal. Cada agente debe trabajar **exclusivamente** en sus directorios asignados.

### 🛤️ Pista A: Core & Perfil de Usuario (Agente 1)

**Directorios Permitidos:** `lib/core/`, `lib/features/user_profile/`, `lib/main.dart`, `lib/injection.dart`

- [ ] **A-01**: Configuración inicial de Hexagonal Architecture y DI (`get_it`, `injectable`).
- [ ] **A-02**: Configuración base de Isar (Provider global).
- [ ] **A-03**: Feature `user_profile`: Entidad `UserProfile`, Repositorio y BLoC.
- [ ] **A-04**: UI: Pantalla de Onboarding y Edición de Perfil.

### 🛤️ Pista B: Ingesta y Registros Médicos (Agente 2)

**Directorios Permitidos:** `lib/features/health_record/`
**Nota:** No tocar `main.dart`. Crear widgets exportables.

- [ ] **B-01**: Feature `health_record`: Entidad `MedicalRecord` y `MedicalAttachment`.
- [ ] **B-02**: Servicio de Infraestructura: `FilePickerService` y `ImagePickerService`.
- [ ] **B-03**: Lógica de "Staging Area" (Bandeja de entrada de documentos).
- [ ] **B-04**: UI: Pantalla de carga de documentos y validación (Curación).

### 🛤️ Pista C: Inteligencia Artificial Local (Agente 3)

**Directorios Permitidos:** `lib/features/local_agent/`
**Nota:** Asumir interfaces genéricas si el Core no está listo.

- [ ] **C-01**: Feature `local_agent`: Entidad `ChatMessage` y `HealthInsight`.
- [ ] **C-02**: Servicio de Infraestructura: `LlmInferenceService` (Stub inicial o integración ONNX).
- [ ] **C-03**: Lógica RAG: Definir interfaz para búsqueda de vectores.
- [ ] **C-04**: UI: Chat Interface con soporte para Markdown y Streaming.

---

## 🔗 Puntos de Integración (Merge)

_Tareas que se realizan una vez las 3 pistas convergen._

- [ ] **I-01**: Registrar `HealthRecordRepository` y `LlmService` en el DI (`injection.dart`).
- [ ] **I-02**: Añadir rutas de navegación en `main.dart` o `app_router.dart`.
- [ ] **I-03**: Conectar el RAG (Agente C) con la base de datos de Registros (Agente B).

---

# TASK.md

Gestión de Tareas: OrionHealth
_Última actualización: 2025-11-24_

## 🎯 Resumen Ejecutivo y Estado Actual

**Estado General:** [5% - Planificación Detallada]
Se ha definido la arquitectura y el flujo de trabajo CI/CD. Ahora nos enfocamos en la implementación de los módulos críticos en orden de dependencia y valor.

**Progreso por Componente:**

- [ ] 🏗️ Infraestructura Base: 10%
- [ ] 👤 Perfil y Datos: 0%
- [ ] 📥 Ingesta y Curación: 0%
- [ ] 🧠 IA Local (Chat/RAG): 0%
- [ ] 📊 Reportes y Planes: 0%

---

## 🏎️ Pistas de Trabajo Paralelo (Sprints)

Para evitar conflictos de merge, el trabajo se divide en 3 pistas independientes basadas en la arquitectura hexagonal. Cada agente debe trabajar **exclusivamente** en sus directorios asignados.

### 🛤️ Pista A: Core & Perfil de Usuario (Agente 1)

**Directorios Permitidos:** `lib/core/`, `lib/features/user_profile/`, `lib/main.dart`, `lib/injection.dart`

- [ ] **A-01**: Configuración inicial de Hexagonal Architecture y DI (`get_it`, `injectable`).
- [ ] **A-02**: Configuración base de Isar (Provider global).
- [ ] **A-03**: Feature `user_profile`: Entidad `UserProfile`, Repositorio y BLoC.
- [ ] **A-04**: UI: Pantalla de Onboarding y Edición de Perfil.

### 🛤️ Pista B: Ingesta y Registros Médicos (Agente 2)

**Directorios Permitidos:** `lib/features/health_record/`
**Nota:** No tocar `main.dart`. Crear widgets exportables.

- [ ] **B-01**: Feature `health_record`: Entidad `MedicalRecord` y `MedicalAttachment`.
- [ ] **B-02**: Servicio de Infraestructura: `FilePickerService` y `ImagePickerService`.
- [ ] **B-03**: Lógica de "Staging Area" (Bandeja de entrada de documentos).
- [ ] **B-04**: UI: Pantalla de carga de documentos y validación (Curación).

### 🛤️ Pista C: Inteligencia Artificial Local (Agente 3)

**Directorios Permitidos:** `lib/features/local_agent/`
**Nota:** Asumir interfaces genéricas si el Core no está listo.

- [ ] **C-01**: Feature `local_agent`: Entidad `ChatMessage` y `HealthInsight`.
- [ ] **C-02**: Servicio de Infraestructura: `LlmInferenceService` (Stub inicial o integración ONNX).
- [ ] **C-03**: Lógica RAG: Definir interfaz para búsqueda de vectores.
- [ ] **C-04**: UI: Chat Interface con soporte para Markdown y Streaming.

---

## 🔗 Puntos de Integración (Merge)

_Tareas que se realizan una vez las 3 pistas convergen._

- [ ] **I-01**: Registrar `HealthRecordRepository` y `LlmService` en el DI (`injection.dart`).
- [ ] **I-02**: Añadir rutas de navegación en `main.dart` o `app_router.dart`.
- [ ] **I-03**: Conectar el RAG (Agente C) con la base de datos de Registros (Agente B).

---

## ✅ Hitos Principales Completados

- Hito 0: Configuración inicial y CI/CD (APK Build).

---

## 📝 Tareas Descubiertas Durante el Desarrollo

| ID    | Tarea                                        | Prioridad | Estado      | Responsable |
|-------|----------------------------------------------|-----------|-------------|-------------|
| T0-02 | Crear estructura de carpetas (Hexagonal)     | ALTA      | ✅ Completado | Antigravity |
| T0-03 | Configurar dependencias base (pubspec)       | ALTA      | ✅ Completado | Antigravity |
| -     | -                                            | -         | -           | -           |
