

# TASK.md

Gestión de Tareas: OrionHealth
_Última actualización: 2025-11-25_

## 🎯 Resumen Ejecutivo y Estado Actual

**Estado General:** [95% - Integración Completa]
Se han integrado los módulos en la aplicación principal. La navegación funciona y se ha verificado el build de Android.

**Progreso por Componente:**

- [x] 🏗️ Infraestructura Base: 100% (DI, Isar, Theme)
- [x] 👤 Perfil y Datos: 100% (Entidad, Repo, UI)
- [x] 📥 Ingesta y Curación: 100% (Entidad, Servicios, UI)
- [x] 🧠 IA Local (Chat/RAG): 90% (Chat UI, Mock LLM, Vector Interface)
- [ ] 📊 Reportes y Planes: 0%
- [ ] 🌐 GitHub Pages & Landing: 0%

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

**Directorios Permitidos:** `lib/features/health_report/`

- [ ] **D-01**: Feature `health_report`: Entidad `HealthReport` (Markdown content).
- [ ] **D-02**: Servicio de Generación de Reportes (Mock/LLM).
- [ ] **D-03**: UI: Pantalla de Visualización de Reportes.

---

## 🌐 GitHub Pages - Landing Page (Nueva Pista)

### 📋 Objetivo

Crear una landing page profesional para OrionHealth que comunique la visión del proyecto, sus características principales, y la filosofía de privacidad y open source. La página debe ser estática, responsiva, y optimizada para conversión (descargas, contribuciones).

### 🎨 Estructura del Sitio

**URL:** `https://iberi22.github.io/local-llm.OrionHealth/`

#### Páginas Propuestas

1. **Home (`index.html`)**
   - Hero section con tagline principal
   - Features overview (4-6 features clave)
   - CTA principal: "Download Now" / "View on GitHub"
   - Social proof (badges, stats)

2. **Vision (`vision.html`)**
   - La misión a largo plazo (medicina personalizada)
   - Fases de impacto (1-5)
   - Infografía del futuro de la medicina con AI

3. **Features (`features.html`)**
   - Desglose detallado de funcionalidades
   - Screenshots/demos (cuando estén disponibles)
   - Comparación con alternativas comerciales

4. **Privacy (`privacy.html`)**
   - Filosofía local-first
   - Explicación técnica de seguridad
   - Comparación: OrionHealth vs apps en la nube

5. **Get Started (`get-started.html`)**
   - Guía de instalación paso a paso
   - Requisitos del sistema
   - Video tutorial (opcional, futuro)

6. **Contribute (`contribute.html`)**
   - Cómo contribuir al proyecto
   - Roadmap visible
   - Licencia AGPL-3.0 explicada

7. **About (`about.html`)**
   - Historia del proyecto
   - Equipo/contributors
   - Contacto

### 🛠️ Stack Técnico Propuesto

- **Framework:** [Jekyll](https://jekyllrb.com/) (nativamente soportado por GitHub Pages)
- **Theme Base:** Usar un tema médico/tech minimalista (ej: [Cayman](https://pages-themes.github.io/cayman/), [Minimal](https://pages-themes.github.io/minimal/), o custom)
- **CSS Framework:** TailwindCSS o Bootstrap 5 para responsividad
- **Animations:** AOS (Animate On Scroll) para efectos sutiles
- **Icons:** Material Icons o Feather Icons
- **Analytics:** GitHub Pages + Google Analytics (opcional, privacidad-conscious)

### 📐 Wireframe Conceptual (Home)

```text
┌─────────────────────────────────────────────────────────┐
│  [Logo] OrionHealth         [Features] [Vision] [Download]
├─────────────────────────────────────────────────────────┤
│                                                         │
│          🏥 Your Health Data, Your Future              │
│   Privacy-first health records for personalized medicine
│                                                         │
│      [Download for Android]  [View on GitHub]          │
│                                                         │
├─────────────────────────────────────────────────────────┤
│  🔒 100% Private  |  🤖 AI-Powered  |  🌍 Open Source  │
├─────────────────────────────────────────────────────────┤
│                   Key Features                          │
│                                                         │
│  📋 Medical Record Management  🧠 On-Device AI          │
│  🔍 Smart Search & RAG         📊 Health Insights       │
│                                                         │
├─────────────────────────────────────────────────────────┤
│              Why OrionHealth?                           │
│   "Preparing your health data for the AI revolution    │
│    in personalized medicine"                            │
│                                                         │
│   [Learn More About Our Vision]                        │
├─────────────────────────────────────────────────────────┤
│  Footer: License | Contribute | Docs | Contact         │
└─────────────────────────────────────────────────────────┘
```

### 🎯 Tareas de Implementación (GitHub Pages)

#### **Fase 1: Setup & Estructura (1-2 horas)**

- [ ] **GP-01**: Crear rama `gh-pages` en el repositorio
  - Configurar GitHub Pages en Settings → Pages
  - Seleccionar branch `gh-pages` y carpeta `/` o `/docs`

- [ ] **GP-02**: Inicializar proyecto Jekyll
  ```bash
  # En la raíz del repo
  jekyll new docs --blank
  cd docs
  bundle install
  ```

- [ ] **GP-03**: Configurar `_config.yml`
  - Título: OrionHealth
  - Descripción: Privacy-first health assistant for personalized medicine
  - URL base: https://iberi22.github.io/local-llm.OrionHealth
  - Theme: Elegir tema (ej: `minima`, `cayman`, o custom)

#### **Fase 2: Contenido & Páginas (3-5 horas)**

- [ ] **GP-04**: Crear `index.md` (Home)
  - Hero section con tagline
  - Features grid (4-6 cards)
  - CTA buttons (Download, GitHub)
  - Embed shields.io badges (License, Build Status, etc.)

- [ ] **GP-05**: Crear `vision.md`
  - Sección "The Long-Term Goal"
  - Fases de impacto (1-5) con iconografía
  - Testimonial o case study (futuro)

- [ ] **GP-06**: Crear `features.md`
  - Tabla comparativa: OrionHealth vs comerciales
  - Screenshots (placeholders por ahora)
  - Demos interactivos (opcional, futuro)

- [ ] **GP-07**: Crear `privacy.md`
  - Diagrama: Local-first architecture
  - FAQ sobre privacidad
  - Comparación con apps en la nube

- [ ] **GP-08**: Crear `get-started.md`
  - Installation guide (Android APK)
  - Prerequisites (Flutter SDK para devs)
  - Troubleshooting común

- [ ] **GP-09**: Crear `contribute.md`
  - Link a CONTRIBUTING.md del repo
  - Roadmap embebido
  - Explicación de AGPL-3.0

- [ ] **GP-10**: Crear `about.md`
  - Historia del proyecto
  - Contributors (GitHub API integration?)
  - Contact form o email

#### **Fase 3: Diseño & Estilos (2-3 horas)**

- [ ] **GP-11**: Crear layout personalizado (`_layouts/default.html`)
  - Header con navegación sticky
  - Footer con links sociales
  - Responsividad mobile-first

- [ ] **GP-12**: Crear estilos custom (`assets/css/style.scss`)
  - Color palette: Azul médico (#1E88E5), Verde salud (#43A047)
  - Typography: Roboto/Inter para body, Montserrat para headings
  - Animaciones sutiles (fade-in, slide-up)

- [ ] **GP-13**: Añadir iconografía
  - Material Icons para features
  - Logo SVG de OrionHealth (diseñar o placeholder)
  - Ilustraciones (ej: unDraw para medicina)

#### **Fase 4: Optimización & SEO (1-2 horas)**

- [ ] **GP-14**: Configurar SEO
  - Meta tags (Open Graph, Twitter Cards)
  - `sitemap.xml` (Jekyll lo genera automáticamente)
  - `robots.txt` (permitir indexación)

- [ ] **GP-15**: Performance
  - Minificar CSS/JS
  - Optimizar imágenes (WebP, lazy loading)
  - Lighthouse score > 90

- [ ] **GP-16**: Analytics (opcional)
  - Google Analytics 4 (con consentimiento de cookies)
  - O alternativa privacy-conscious (Plausible, Umami)

#### **Fase 5: Deploy & Testing (1 hora)**

- [ ] **GP-17**: Deploy inicial
  ```bash
  git checkout -b gh-pages
  git add docs/
  git commit -m "feat: initial GitHub Pages landing"
  git push origin gh-pages
  ```

- [ ] **GP-18**: Pruebas cross-browser
  - Chrome, Firefox, Safari
  - Mobile (iOS/Android simulators)

- [ ] **GP-19**: Configurar dominio custom (opcional, futuro)
  - Comprar dominio (ej: orionhealth.app)
  - Configurar DNS en GitHub Pages Settings

#### **Fase 6: Contenido Avanzado (Futuro)**

- [ ] **GP-20**: Blog con Jekyll (`_posts/`)
  - Anuncios de releases
  - Artículos técnicos sobre privacy
  - Research updates

- [ ] **GP-21**: Demo interactivo
  - Embed de Flutter Web (si es viable)
  - O video tutorial embebido (YouTube)

- [ ] **GP-22**: Sección "Research"
  - Papers relacionados
  - Datasets públicos (FHIR, OMOP)
  - Colaboraciones académicas

---

## 🔗 Puntos de Integración (Merge)

_Tareas que se realizan una vez las 3 pistas convergen._

- [x] **I-01**: Registrar `HealthRecordRepository` y `LlmService` en el DI (`injection.dart`).
- [x] **I-02**: Añadir rutas de navegación en `main.dart` o `app_router.dart`.
- [x] **I-03**: Conectar el RAG (Agente C) con la base de datos de Registros (Agente B).

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
| TB-01 | Feature HealthRecord (Domain)                | ALTA      | ✅ Completado | Antigravity |
| TB-02 | Servicios Ingesta (File/Image/OCR)           | ALTA      | ✅ Completado | Antigravity |
| TB-03 | UI Staging Area                              | ALTA      | ✅ Completado | Antigravity |
| TC-04 | Interfaz VectorStoreService (RAG)            | MEDIA     | ✅ Completado | Antigravity |
| GP-01 | GitHub Pages: Setup inicial                  | MEDIA     | ⏳ Pendiente | Comunidad   |
| GP-04 | Crear landing page (Home)                    | MEDIA     | ⏳ Pendiente | Comunidad   |
| GP-05 | Página Vision (medicina personalizada)       | MEDIA     | ⏳ Pendiente | Comunidad   |

---

## 🚀 Próximos Pasos Recomendados

1. **Prioridad Alta**: Implementar feature de Reportes (Pista D)
2. **Prioridad Media**: Crear GitHub Pages landing (GP-01 a GP-19)
3. **Prioridad Baja**: Integración con ONNX Runtime real (reemplazar MockLlmService)

---

## 📚 Referencias

- [Jekyll Documentation](https://jekyllrb.com/docs/)
- [GitHub Pages Setup](https://docs.github.com/en/pages/getting-started-with-github-pages)
- [TailwindCSS](https://tailwindcss.com/)
- [AGPL-3.0 License](https://www.gnu.org/licenses/agpl-3.0.en.html)

