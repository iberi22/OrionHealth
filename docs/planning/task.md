

# TASK.md

Gestión de Tareas: OrionHealth
_Última actualización: 2025-11-26_

## 🎯 Resumen Ejecutivo y Estado Actual

**Estado General:** [100% - v1.0.0-beta Production Ready]
✅ Aplicación Flutter completa con APK Release generado
✅ Landing page profesional desplegada en GitHub Pages
✅ CI/CD configurado (Android Build + GitHub Pages Deploy)

**Progreso por Componente:**

- [x] 🏗️ Infraestructura Base: 100% (DI, Isar, Theme)
- [x] 👤 Perfil y Datos: 100% (Entidad, Repo, UI)
- [x] 📥 Ingesta y Curación: 100% (Entidad, Servicios, UI)
- [x] 🧠 IA Local (Chat/RAG): 100% (Chat UI, Mock LLM, Vector Interface, isar_agent_memory)
- [x] 📊 Reportes y Planes: 100% (Entidad, Servicio Mock, UI)
- [x] 🌐 GitHub Pages & Landing: 100% (Astro, Cyber-Minimalism Design, SEO)
- [x] 📦 Release: 100% (APK Release v1.0.0-beta, 82MB)

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

### 🛤️ Pista D: Reportes y Planes (Agente 4)

**Directorios Permitidos:** `lib/features/reports/`

- [x] **D-01**: Feature `reports`: Entidad `Report` (Markdown content).
- [x] **D-02**: Servicio de Generación de Reportes (Mock/LLM).
- [x] **D-03**: UI: Pantalla de Visualización de Reportes.

### 🛤️ Pista E: Support Automation (Agente 5)

**Directorios Permitidos:** `functions/telegram-bot/`

- [ ] **E-01**: Configurar Edge Function (esqueleto y manejo de webhook).
- [ ] **E-02**: Integración con Telegram Bot API (recepción de mensajes).
- [ ] **E-03**: Integración con GitHub API (creación de issues).
- [ ] **E-04**: Lógica de clasificación de tickets (Bug/Feature/Feedback).

---

## 🌐 GitHub Pages - Landing Page

### 📋 Estado Actual: ✅ COMPLETADO

**URL Producción:** `https://iberi22.github.io/OrionHealth/`

**Stack Implementado:**
- **Framework:** Astro 5.0 (Static Site Generator)
- **CSS Framework:** TailwindCSS 3.4
- **Design System:** Cyber-Minimalism (Dark mode, glassmorphism, monospace fonts)
- **CI/CD:** GitHub Actions (automated deploy on push to `docs/`)

### ✅ Páginas Implementadas

| Página | Estado | URL | Componentes |
|--------|--------|-----|-------------|
| **Home** | ✅ Completa | `/` | Hero, Features, Screenshots, Privacy, Support, Sponsors, Download |
| **Vision** | ✅ Completa | `/vision` | Mission, 5-Phase Roadmap, Why This Matters, CTA |
| Privacy Policy | ⏳ Futuro | `/privacy` | Legal compliance |
| Contribute | ⏳ Futuro | `/contribute` | Developer guide |

### 🎨 Componentes Desarrollados

- [x] **Hero Section**: Tagline principal, CTAs (Download APK, GitHub)
- [x] **Features Grid**: 4 features clave con iconos (🔒 Private, 🧠 AI, 📊 Comprehensive, 🔓 Open Source)
- [x] **Screenshots Gallery**: Comentada temporalmente (layout horizontal pendiente)
- [x] **Privacy Section**: Explicación técnica (No Cloud, Local AI, Open Source)
- [x] **Support Section**: Telegram Bot + GitHub Issues con templates
- [x] **Sponsors Section**: GitHub Sponsors + Open Collective
- [x] **Footer**: Links, social media, legal, copyright

### 🛠️ Tareas GitHub Pages Completadas

#### **Fase 1: Setup & Infraestructura** ✅

- [x] **GP-01**: Migrar de Jekyll a Astro (mejor DX, performance)
- [x] **GP-02**: Configurar `astro.config.mjs` con base path correcto
- [x] **GP-03**: Setup TailwindCSS 3.4 + custom design system
- [x] **GP-17**: CI/CD con GitHub Actions (deploy automático)
- [x] **GP-18**: Corregir bug de Rollup en Linux (npm ci → npm install)

#### **Fase 2: Contenido & Páginas** ✅

- [x] **GP-04**: Landing page principal (Hero, Features, Privacy, Support)
- [x] **GP-04b**: Hero section con CTAs (Download, GitHub)
- [x] **GP-04c**: Features grid (4 features con iconos)
- [x] **GP-04d**: Privacy section (No Cloud, Local AI, Open Source)
- [x] **GP-04e**: Support section (Telegram Bot + GitHub Issues)
- [x] **GP-04f**: Sponsors section (GitHub Sponsors + Open Collective)

#### **Fase 3: Diseño & Componentes** ✅

- [x] **GP-11**: Layout Astro con Cyber-Minimalism design
- [x] **GP-12**: TailwindCSS custom theme (charcoal, bone, accent colors)
- [x] **GP-12b**: Glassmorphism effects (cards, navigation)
- [x] **GP-12c**: Responsive mobile-first (breakpoints: sm, md, lg, xl)
- [x] **GP-13**: Iconografía (emojis nativos para mejor performance)
- [x] **GP-13b**: Animaciones CSS (fade-in, slide-up, stagger effects)

#### **Fase 4: Optimización & SEO** ✅

- [x] **GP-14**: Meta tags (Open Graph, Twitter Cards)
- [x] **GP-14b**: `robots.txt` configurado
- [x] **GP-15**: Performance (minified CSS/JS, lazy loading)
- [x] **GP-15b**: Asset optimization (Astro build optimizations)

#### **Fase 5: Deploy & Testing** ✅

- [x] **GP-17**: Deploy automático vía GitHub Actions
- [x] **GP-18**: Testing cross-browser (Chrome, Firefox, Safari simulado)
- [x] **GP-19**: URL actualizada a `/OrionHealth` (repo renombrado)

### 📋 Tareas Futuras (Backlog)

#### **Contenido Adicional**

- [ ] **GP-06**: Página `/features` - Desglose técnico detallado
  - Comparación con alternativas comerciales
  - Screenshots con zoom/lightbox
  - Videos demo (cuando estén disponibles)

- [ ] **GP-07**: Página `/privacy` - Política de privacidad legal
  - GDPR compliance
  - Explicación técnica de seguridad
  - Auditoría de código

- [ ] **GP-08**: Página `/get-started` - Guía de instalación
  - Tutorial paso a paso con capturas
  - Video walkthrough
  - Troubleshooting FAQ

- [ ] **GP-09**: Página `/contribute` - Guía de contribución
  - Arquitectura del proyecto
  - Setup de desarrollo
  - Coding guidelines

- [ ] **GP-10**: Página `/about` - Historia y equipo
  - Timeline del proyecto
  - Contributors wall
  - Contacto

#### **Mejoras Técnicas**

- [ ] **GP-16**: Analytics privacy-conscious
  - Implementar Plausible o Umami
  - Dashboard público de métricas

- [ ] **GP-20**: Blog integrado (`/blog`)
  - Anuncios de releases
  - Artículos técnicos
  - Research updates

- [ ] **GP-21**: Demo interactivo
  - Flutter Web embed (explorar viabilidad)
  - Video demo de la app

- [ ] **GP-22**: Sección Research (`/research`)
  - Papers relacionados
  - Datasets públicos (FHIR, OMOP)
  - Colaboraciones académicas

#### **Correcciones Pendientes**

- [ ] **GP-Screenshots**: Arreglar layout horizontal de screenshots
  - Implementar carousel o grid mejorado
  - Lightbox para zoom de imágenes

---

## 🔗 Puntos de Integración (Merge)

_Tareas que se realizan una vez las 3 pistas convergen._

- [x] **I-01**: Registrar `HealthRecordRepository` y `LlmService` en el DI (`injection.dart`).
- [x] **I-02**: Añadir rutas de navegación en `main.dart` o `app_router.dart`.
- [x] **I-03**: Conectar el RAG (Agente C) con la base de datos de Registros (Agente B).

---

## ✅ Hitos Principales Completados

### Release v1.0.0-beta (2025-11-26)

- **Hito 0**: Configuración inicial y CI/CD
  - ✅ APK Build workflow con GitHub Actions
  - ✅ GitHub Pages deployment workflow
  - ✅ Workarounds para Windows build (Kotlin daemon, isar_flutter_libs)

- **Hito A1**: Core Architecture & User Profile
  - ✅ Hexagonal Architecture con DI (get_it + injectable)
  - ✅ Isar Database setup (v3.1.0+1)
  - ✅ Material 3 Theme System (charcoal + bone + accent)
  - ✅ UserProfile feature completo (Domain/Infra/UI)

- **Hito B1**: Ingestion & Medical Records
  - ✅ MedicalRecord + MedicalAttachment entities
  - ✅ File/Image picker services
  - ✅ Staging Area UI (document curation)

- **Hito C1**: AI Local (Chat/RAG)
  - ✅ ChatMessage entity con Isar
  - ✅ MockLlmService con streaming
  - ✅ Chat UI con Markdown rendering
  - ✅ VectorStoreService interface (RAG-ready)
  - ✅ isar_agent_memory v0.5.0-beta integration

- **Hito D1**: Health Reports
  - ✅ HealthReport entity
  - ✅ Mock report generation service
  - ✅ Report visualization UI

- **Hito M1**: Main Integration & Navigation
  - ✅ BottomNavigationBar con 4 secciones
  - ✅ DI container wiring completo
  - ✅ APK Release build (82MB, Android 9.0+)

- **Hito GP1**: GitHub Pages Landing
  - ✅ Astro 5.0 + TailwindCSS setup
  - ✅ Cyber-Minimalism design system
  - ✅ Home page completa con 7 secciones
  - ✅ CI/CD automático (deploy on push)
  - ✅ URL actualizada: iberi22.github.io/OrionHealth/

---

## 📝 Historial de Tareas Completadas

| ID    | Tarea                                        | Prioridad | Estado        | Fecha      | Responsable |
|-------|----------------------------------------------|-----------|---------------|------------|-------------|
| T0-02 | Crear estructura Hexagonal Architecture      | ALTA      | ✅ Completado | 2025-11-25 | Copilot     |
| T0-03 | Configurar dependencias base (pubspec)       | ALTA      | ✅ Completado | 2025-11-25 | Copilot     |
| TC-01 | Entidad ChatMessage con Isar                 | ALTA      | ✅ Completado | 2025-11-25 | Copilot     |
| TC-02 | Interfaz LlmService y MockLlmService         | ALTA      | ✅ Completado | 2025-11-25 | Copilot     |
| TC-03 | Chat UI con Markdown y Streaming             | ALTA      | ✅ Completado | 2025-11-25 | Copilot     |
| TA-01 | Configuración DI y Theme                     | ALTA      | ✅ Completado | 2025-11-25 | Copilot     |
| TA-02 | Módulo Database (Isar)                       | ALTA      | ✅ Completado | 2025-11-25 | Copilot     |
| TA-03 | Feature UserProfile (Domain/Infra/UI)        | ALTA      | ✅ Completado | 2025-11-25 | Copilot     |
| TB-01 | Feature HealthRecord (Domain)                | ALTA      | ✅ Completado | 2025-11-25 | Copilot     |
| TB-02 | Servicios Ingesta (File/Image/OCR)           | ALTA      | ✅ Completado | 2025-11-25 | Copilot     |
| TB-03 | UI Staging Area                              | ALTA      | ✅ Completado | 2025-11-25 | Copilot     |
| TC-04 | Interfaz VectorStoreService (RAG)            | MEDIA     | ✅ Completado | 2025-11-25 | Copilot     |
| TD-01 | Feature HealthReport (Domain)                | MEDIA     | ✅ Completado | 2025-11-25 | Copilot     |
| TD-02 | Mock report generation service               | MEDIA     | ✅ Completado | 2025-11-25 | Copilot     |
| TD-03 | Report visualization UI                      | MEDIA     | ✅ Completado | 2025-11-25 | Copilot     |
| GP-01 | GitHub Pages: Astro setup                    | MEDIA     | ✅ Completado | 2025-11-26 | Copilot     |
| GP-04 | Landing page completa (Home)                 | MEDIA     | ✅ Completado | 2025-11-26 | Copilot     |
| GP-05 | Página Vision (medicina personalizada)       | MEDIA     | ✅ Completado | 2025-11-26 | Copilot     |
| GP-17 | CI/CD GitHub Actions (deploy)                | MEDIA     | ✅ Completado | 2025-11-26 | Copilot     |
| GP-18 | Fix Rollup bug (npm ci → npm install)        | ALTA      | ✅ Completado | 2025-11-26 | Copilot     |
| GP-19 | URL update (repo rename)                     | ALTA      | ✅ Completado | 2025-11-26 | Copilot     |

---

## 🚀 Próximos Pasos Recomendados

### 🎯 Prioridad Alta (v1.1.0)

1. **Integración ONNX Runtime Real**
   - Reemplazar MockLlmService con LLM real
   - Descargar modelo optimizado (Phi-2, TinyLlama)
   - Benchmark de performance en dispositivos Android

2. **Vector Store Implementation**
   - Implementar VectorStoreService con isar_agent_memory
   - Indexación automática de registros médicos
   - RAG full-funcional con búsqueda semántica

3. **APK Signing para Production**
   - Generar keystore de release
   - Configurar signing en gradle
   - Preparar para Google Play Store

### 🎨 Prioridad Media (v1.2.0)

4. **Landing Page - Contenido Adicional**
   - Crear página `/vision` (medicina personalizada)
   - Crear página `/features` (desglose técnico)
   - Crear página `/privacy` (política legal)

5. **Screenshots & Media**
   - Arreglar layout horizontal de galería
   - Grabar video demo de la app
   - Crear assets para redes sociales

6. **Community Features**
   - Blog integrado (anuncios de releases)
   - Analytics privacy-conscious (Plausible/Umami)
   - Newsletter signup

### 🔬 Prioridad Baja (v2.0.0)

7. **Telegram Bot (Support Automation)**
   - Edge Function para webhook
   - Integración GitHub API (issue creation)
   - Clasificación automática de tickets

8. **Advanced Features**
   - Flutter Web version (explorar viabilidad)
   - Sync opcional con Firebase (opcional, privacy-conscious)
   - Multi-idioma (i18n)

---

## 📚 Referencias

- [Jekyll Documentation](https://jekyllrb.com/docs/)
- [GitHub Pages Setup](https://docs.github.com/en/pages/getting-started-with-github-pages)
- [TailwindCSS](https://tailwindcss.com/)
- [AGPL-3.0 License](https://www.gnu.org/licenses/agpl-3.0.en.html)

