## OrionHealth Testing & PWA Validation (Web Research Enhanced)

**Contexto:** OrionHealth es una app Flutter + Astro docs site en GitHub Pages. Score real del codebase: **79.7%** (26 features, 4/5 layers, 0 golden tests). Basado en web research de mejores practicas 2026 para Flutter health apps + PWA compliance.

### Investigacion Web: Checklist Final Validacion

**PWA Lighthouse (Docs Site - Astro en GitHub Pages):**
- Manifest: ? ya tiene name, short_name, start_url /OrionHealth/, display standalone, icons 192+512, maskable, shortcuts
- Service Worker: ? ya tiene cache-first para JSON medical data, network-first para docs, navegacion offline
- HTTPS: ? GitHub Pages automatico
- Falta: Test real con Lighthouse (performance, accessibility, SEO, PWA scores)
- Falta: iOS meta tags en index.html (apple-mobile-web-app-capable, apple-touch-icon)
- Falta: Offline fallback page HTML personalizada

**Flutter App Testing (Codigo Dart):**
- Unit tests domain: 264 tests creados (Sprint 1-3 completados por Jules)
- Widget tests: Muy pocos (~20 tests en total)
- Integration tests: ~1 por feature, minimos
- Golden tests: **0** en todas las features (layer faltante en todas)
- Falta: Test de repositorios con mock HTTP, DB local, serializacion edge cases
- Falta: Widget tests para pantallas principales (auth, home, dashboard, medical-standards)
- Falta: E2E tests reales con navegacion completa

**Health/Security Compliance (HIPAA-style):**
- Falta: Checklist de PHI (Protected Health Information) - que datos maneja realmente?
- Falta: flutter_secure_storage para tokens (no SharedPreferences)
- Falta: Cifrado AES-256 en datos locales
- Falta: Certificate pinning para API calls
- Falta: Audit logging de acceso a datos medicos
- Falta: Session timeout (15 min automatico)
- Falta: Pantalla de consentimiento/privacidad HIPAA
- Falta: BLE sync cifrado

**App Store / PWA Install:**
- Falta: Screenshots reales para la web
- Falta: Hero image PNG en /OrionHealth/hero-image.png (actualmente 404)
- Falta: Pagina de landing funcional en ingles
- Falta: Dark mode testing
- Falta: Responsive design test (mobile <-> desktop)

**Coverage Gaps Identificados (Web Research):**
1. **OWASP MASVS** - Mobile AppSec Verification Standard (no aplicado)
2. **WCAG Accessibility** - Contraste de color, lectores de pantalla
3. **FDA / MHMDA** - Si es dispositivo medico, regulacion adicional
4. **Background Sync** - Cola de operaciones offline
5. **Push Notifications** - No implementado en PWA
6. **CICD Testing** - Tests no se corren automaticamente en PRs
7. **Golden Tests Coverage** - 0% en todas las features
8. **Bundle Size** - No analizado para Flutter web build

### Sprints Actualizados (2026-07-06)

**Sprint 1: Unit Tests Domain Batch 1 (7 features)** - ? COMPLETADO (PR #1355 merged)
auth, network, local_agent, vitals, appointments, sync, health_data_import

**Sprint 2: Unit Tests Domain Batch 2 (7 features)** - ? COMPLETADO (PR #1353 merged)
about, allergies, calendar_import, doctor_verification, email-citas, eps_connection, health_record

**Sprint 3: Unit Tests Infrastructure Batch 1** - ? COMPLETADO (PR #1354 merged)
health_sharing, home, medications, meditation, network_health, onboarding, reports

**Sprint 4: Unit Tests Infrastructure + Widgets Batch 2** - ?? EN PROGRESO (PR #1356 OPEN)
settings, user_profile, voice_chat infrastructure + widget tests para auth, home, vitals, appointments

**Sprint 5: Widget Tests Restantes**
widget tests para: network, local_agent, medications, health_sharing, eps_connection, doctor_verification, chat/settings
**Meta: +50 widget tests**

**Sprint 6: PWA Audit & Fixes (WEB RESEARCH ENHANCED)**
1. Lighthouse audit real (performance, accesibilidad, SEO, PWA)
2. iOS meta tags en index.html (apple-mobile-web-app-capable, apple-touch-icon, status-bar-style)
3. Manifest: agregar screenshot/categories, verificar icons 512x512 reales
4. Service worker: offline fallback page, test en Chrome DevTools
5. hero-image.png para la landing page
6. Dark mode testing en mobile y desktop
7. Responsive design (mobile nav, tablet grid, desktop layout)
8. Bundle size analysis (flutter build web --release)

**Sprint 7: Health & Security Compliance (WEB RESEARCH ENHANCED)**
1. Audit de PHI: que datos almacena localmente la app? (diagnosticos, alergias, medicaciones, vitales)
2. flutter_secure_storage: migrar tokens, PIN, datos sensibles
3. Cifrado AES-256 para datos locales de salud
4. Certificate pinning en HTTP client
5. Audit logging: quien accedio a que dato medico y cuando
6. Session timeout (15 min con idle detection + server-side expiry)
7. Pantalla de consentimiento HIPAA-style con privacidad
8. BLE sync cifrado (network module)
9. Data minimization review: que datos NO necesita la app?

**Sprint 8: Final Polish & Docs**
1. README.md: documentar testing strategy, coverage actual
2. CI/CD: ejecutar flutter test en cada PR (workflow github actions)
3. Coverage target: 80% unit + widget tests
4. OWASP MASVS checklist basico
5. WCAG accessibility basico (color contrast, screen reader labels)
6. Reporte final: Lighthouse score + testing coverage + HIPAA checklist

### Features Debiles (score mas bajo segun real-scanner):
1. email-citas: **56.5%** - 0 unit/widget/infra tests, solo 1 integration test
2. data_sources: **73.5%** - 1 unit test, 0 integration
3. dashboard: **78.5%** - 0 integration tests

### Issues Asignados a Jules (2026-07-06)
**Sprint 5: Widget Tests**
- #1357 Widget tests: dashboard stats card
- #1358 Widget tests: email-citas list tile
- #1359 Widget tests: data sources tile
- #1360 Widget tests: network connection status
- #1361 Widget tests: health sharing card

**Sprint 6: PWA Audit & Fixes**
- #1362 PWA: iOS meta tags y touch icons
- #1363 PWA: offline fallback page
- #1364 PWA: hero image para landing page

**Sprint 7: Health & Security**
- #1365 Security: migrar tokens a flutter_secure_storage
- #1366 Security: session timeout 15 min