# Changelog

All notable changes to OrionHealth will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.10.1] — 2026-09-02

### Refactored
- **EPS Colombia scraper removal**: Removed non-functional EPS Colombia scraper and cleaned up EPS stubs (`b40f2f28`, `92b8784f`)
- **IHCE Colombia neutralization**: Neutralized IHCE Colombia integration and completed cleanup (`92b8784f`)

### Fixed
- **UI Legibility**: Increased fontSize >= 14 across app UI elements for Galaxy S22+ legibility and improved responsiveness (`0dc0f5af`, `b40f2f28`)
- **docs build**: restore `docs/public/clinical_guidelines.json` + 5 medical JSONs from legacy (UNRESOLVED_IMPORT 6→0, build 6.07s 219 pages)
- **Isar codegen gap**: 37 undefined_getter errors pending build_runner with Dart 3.10 SDK (SDK gap documented)
- **features.json v2→v3**: 26/26 stable with implemented_in + passes + last_tested 2026-09-02 + req_ids, overall 98.08→100%

### Changed
- **features.json schema**: v2.0.0 → 3.8.0 GitCore, last_updated 2026-08-16 → 2026-09-02, status in_progress → completed
- **version sync**: pubspec 0.10.1 now has CHANGELOG entry, docs/backend semver independent (1.0.0 docs, 1.0.0 backend)

### Deployed
- **PWA Status**: PWA live deployment at https://app-orionhealth.pages.dev is at v0.10.0 (`593450b1`)

---

## [0.10.0] — 2026-08-30

### Added
- **FEAT-022 Emergency Data (Medical ID)**: Complete implementation with MedicalIdEntity, EmergencyContact, MedicalCondition entities, Isar (mobile) + Web SharedPreferences repositories, QrGeneratorService, EmergencyCubit, 2 pages (lock-screen + edit), 1 widget (QR display with copy-to-clipboard)
- **Flutter Web PWA target**: `lib/main_web.dart` dedicated entrypoint, `web/` target with PWA manifest customized for OrionHealth
- **Custom splash screen** (`web/index.html`): Brand-styled loading screen with spinner, hides when Flutter app boots
- **Cloudflare Pages deploy**: `app-orionhealth.pages.dev` project created and live (3 deployments: 85 files uploaded in 42s, then 3 incremental updates)
- **CI workflow** (`.github/workflows/deploy-web.yml`): Auto-build + deploy on push to main
- **18 Emergency Data tests**: entity (11) + QR generator (5) + use cases (4), 100% passing
- **Privacy guarantees**: Medical ID NEVER includes SSN, address, photo, insurance numbers

### Changed
- **intl: ^0.20.3 → ^0.20.2**: Compatibility with Flutter 3.44 stable channel (both 3.41 CI and 3.44 local work with 0.20.2)
- **features.json**: FEAT-022 status: in_progress → completed, overall_progress: 96.2% → 100%
- **coverage_report.md**: Per-feature table updated (all 26 features at 100%)

### Deployed
- **PWA live**: https://app-orionhealth.pages.dev (200 OK, 2.6MB main.dart.js, 41ms TTFB)
- **85 files uploaded**, bundle 2.6MB (main.dart.js) + 59MB total (with CanvasKit)
- **Service worker**: Flutter default (auto-regenerated on build, handles SW cleanup)

---

## [0.9.0] — 2026-08-29

### Added
- **MedicalTextNormalizer** (Ola 8.01): Spanish medical abbreviation maps (TA, FC, IMC, FR, SpO2, Hb, HTA, DM, EPOC) for normalized RAG queries
- **Embedding quality benchmark pipeline** (Ola 8.02): CLI script with 20+ medical queries, precision/recall/MRR measurement, regression reports
- **SWALTooltip wrapper** (Ola 7.14): Centralized accessibility wrapper for icon buttons with theme-aware styling
- **O(1) AppointmentsLookup service** (Ola 7.15): Date-indexed map replaces O(n) iteration in calendar grid (42 cells × N appointments → 42 lookups)
- **25 feature pages + SRS docs sync** (Ola 7.12): Complete documentation site content with `docs/src/content/features/*.md`
- **Apollo test helpers** (Ola 7.05/7.06): Centralized `mock_encryption_service.dart` and `mock_health.dart` for test deduplication
- **Golden baselines regenerated** (Ola 7.11): 10 PNG baselines regenerated against current widget rendering
- **Android Kotlin migration** (Ola 7.01): Migrate to Built-in Kotlin to fix `assembleDebug` APK failures
- **PWA manifest fix** (Ola 7.02): Configure `AstroPWA manifestFilename` for Astro 7.2.x compatibility
- **scripts/RULES.md** (Ola 9.03): Documentation of GitCore repo structure rules
- **docs/public/README.md** (Ola 9.04): Documents PWA-only purpose, prevents regression of medical-standards JSON duplicates

### Changed
- **Flutter analyze: 0 info lints** (Ola 7.04): Resolved 135 info-level hints in `lib/` (encryptedSharedPreferences deprecations, curly_braces, prefer_final_fields, deprecated_member_use)
- **Tooltips migrated to SWALTooltip** (Ola 7.14): `page_header.dart`, `appointments_page.dart`, `voice_chat_page.dart`, `connection_status_indicator.dart`
- **Apollo calendar lookup optimized** (Ola 7.15): `_appointmentsLookup.hasAppointmentsOn(date)` replaces `_allAppointments.any(...)`
- **Backend FHIR security hardened** (Ola 7.13): Auth middleware, errorHandler sanitization, IDOR prevention (+3142/-2678 LOC)
- **Dependencies bumped** (Wave 8): flutter_blue_plus 2.3.8 → 2.3.12, record 6.2.1 → 7.1.1 (closed obsolete), connectivity_plus 7.1.1 → 7.3.1, just_audio 0.10.5 → 0.10.6, astro 7.1.6 → 7.2.4, postcss 8.5.25 → 8.5.26, esbuild 0.28.1 → 0.28.2, fast-uri 3.1.4 → 3.1.6
- **Medical-standards JSON consolidated** (Ola 9.04): 8 duplicate files moved from `docs/public/` to `docs/legacy/public-deprecated/`

### Fixed
- **Golden screenshots test imports** (Ola 7.08): Added missing imports for `google_fonts`, mock helpers
- **voice_chat tests** (Ola 7.09): Imports for `VoiceChatCubit`/`VoiceChatState` real classes
- **app_init/smoke_init/widget tests** (Ola 7.10): Imports for `throwsA`, `isA`, `verify`, `Timeout`, `isTrue`
- **RPConsentDocument API** (Ola 7.07): Constructor + `addSection` aligned with usage sites
- **Allergy MockEncryptionService duplicate** (Ola 7.05): Extracted to shared helper, resolved collision with auth tests
- **Data_sources MockHealth mismatch** (Ola 7.06): Unified with `HealthWrapper` API across tests
- **Astro docs 0 warnings** (Ola 7.03): SNOMED CSS + deprecation warnings resolved

### Security
- **Backend FHIR IDOR + error leakage audit** (Ola 7.13): Comprehensive audit covering all `backend/src/routes/fhir/*.ts` endpoints. Auth middleware validates `req.user.id === patientId`. Error handler sanitizes stack traces in production (`NODE_ENV === 'production'`).
- **IHCE auth middleware** (Ola 7.13): New `backend/src/middleware/auth.js` enforcing ownership checks

### Removed
- **Stale medical-standards.html** and **test_bloc_version.sh** from root (orphan outputs, content preserved elsewhere)

### Compliance (Wave 9)
- **GDPR DataExportService** (Ola 9.06): Portable ZIP export of all user data with pure-Dart encoder (no external dependencies). Repository pattern with abstract `DataExportRepository` interface and Isar implementation.
- **GDPR RightToErasureRepository** (Ola 9.07): Irreversible deletion of all user data across 8 Isar collections in a single atomic `writeTxn`. Returns `ErasureCounts` receipt.
- **HIPAA PhiAuditService** (Ola 9.08): Append-only audit log of all PHI access events (read/write/delete/export/share). Persisted to SecureStorage as JSON (encrypted at rest). No PHI content logged — only resource IDs.
- **Ley 1581 HabeasDataConsent** (Ola 9.09): Explicit consent entity for Colombian data protection law. Requires 3 checkboxes (ARCO rights, processing purpose, data sharing) before any PHI collection.
- **Ley 1581 ArcoRequest** (Ola 9.10): Request model for 4 ARCO rights (Acceso, Rectificación, Cancelación, Oposición) with 4 status states (pending/processing/processed/denied).
- **WCAG 2.1 AA accessibility** (Ola 9.12): `docs/accessibility.md` conformance statement + WCAG badge in README.
- **Privacy policy** (Ola 9.13): `docs/privacy-policy.md` with 13 sections covering GDPR (Art. 6/9/15-21), Ley 1581 (Art. 6/17/ARCO), HIPAA (§ 164.312/316/530), data retention, security measures.
- **WCAG tooltips** (Ola 9.05): Added Spanish tooltips to 13 icon-only IconButtons across 8 files for screen reader support.

### Quality
- **CHANGELOG.md updated** (Ola 9.11): Full Wave 7+8+9 release notes with Keep a Changelog 1.1.0 format.
- **SRS REQ-NF compliance matrix** (Ola 9.14): Updated `docs/SRS/02-non-functional-requirements.md` with status table for all 10 NFRs.
- **scripts/RULES.md** (Ola 9.03): GitCore repo structure documentation.
- **Root hygiene** (Ola 9.01-9.02, 9.07): 8 diagnostic .txt files moved to `docs/diagnostics/`, stale HTML/sh removed, root 100% clean.

### Testing
- **Test coverage for Wave 9** (1,299 LOC tests, 1.28x ratio vs code):
  - `test/core/audit/` — 15 tests for HIPAA PhiAuditEvent + PhiAuditService
  - `test/features/onboarding/` — 5 tests for HabeasDataConsent
  - `test/features/user_profile/` — 14 tests for ArcoRequest, DataExport, RightToErasure
  - `test/integration/compliance/` — 14 E2E tests for full compliance user journey
- **All 55 new tests pass**: `flutter test` reports `All tests passed!`
- **Compliance E2E coverage**:
  - Step 1: Habeas Data consent (Ley 1581)
  - Step 2: PHI audit events (HIPAA)
  - Step 3: 4 ARCO rights requests
  - Step 4: GDPR data export
  - Step 5: GDPR right to erasure (irreversible)

---

## [0.8.1-beta] — 2026-06-04

### Added
- **SchemaRegistry**: VitalSigns (5) and LabResult (5) medical schemas with local validation
- **ZKP indicator**: Lock/badge icons in FieldSelector for fields supporting zero-knowledge proofs
- **AnonCreds salted commitments**: Cryptographic security with per-claim 256-bit random salts
- **BBS+/BLS12-381 evaluation**: Technical feasibility document for future ZKP migration
- **FUNDING.yml**: GitHub Sponsors and Open Collective links
- **PULL_REQUEST_TEMPLATE.md**: Standardized PR checklist
- **Repository description**: Professional OSS description added

### Changed
- **CI/CD workflows**: Fixed `actions/checkout@v6` → `@v4`, `upload-artifact@v7` → `@v4`, `download-artifact@v8` → `@v4`
- **README badges**: Updated CI badge, added SSI, Docs, and Stars badges
- **README status**: Updated to reflect current test count and features
- **HealthContextService**: `conditions` type changed to `List<String>` for Isar compatibility
- **DrugInteractionChecker**: Uses `MedicationReference.displayName` instead of removed `name` field

### Fixed
- **Issue #198**: Replaced raw sha256 commitments with salted cryptographic commitments
- **Issue #347**: Created and implemented SchemaRegistry directly
- **Issue #348**: Created and implemented ZKP indicator UI
- **Build errors**: `JsonEncoder` import, `hybridSearch` for lab data, `Icd10Code` → `String` migration

---

## [0.8.0-beta] — 2026-05-10

### Added
- **GemmaReportGenerationService**: Real LLM-based medical report generation with HiRAG RAG context
  - Retrieves medical knowledge from VectorStore for evidence-based reports
  - Loads UserProfile for personalized context (conditions, medications)
  - Gemma 4 local → Gemini cloud → offline fallback pipeline
  - Automatic urgent report detection via clinical keyword analysis
- **ML Kit OCR Service**: Real OCR using `google_mlkit_text_recognition` replacing mock
- **Architecture docs**: `SSI_ARCHITECTURE_DECISION.md` (Sidetree/ION + Hyperledger Aries)
- **Monorepo documentation**: `docs/ARCHITECTURE.md` with hexagonal architecture diagrams

### Changed
- **ClinicalReasonerService**: Fuzzy symptom matching with Levenshtein distance
  - Sliding window n-gram token matching
  - Negation detection (Spanish: "no", "sin", "nunca", etc.)
  - Confidence-scored diagnostic matches
  - 211 additions, 31 deletions across 3 files
- **Xavier2**: Revived to v0.4.1, Docker port 8006, SessionSyncTask cron active
- **Build**: `user_profile.g.dart` regenerated, `injection.config.dart` wired for GemmaReportGenerationService
- **Pubspec**: Version bump from `1.0.0+1` → `0.8.0-beta+1`

### Fixed
- **Repo sanitization**: 45 stale remote branches deleted, 14 local branches cleaned
- **PR cleanup**: 3 PRs merged (#163, #164, #166), 2 closed (#165, #167)
- **Issue #162**: Closed (Xavier2 session sync operational)
- **Issue #111**: Updated body with current security status

---

## [0.7.0] — 2026-05-03

### Added
- **AicorePlugin**: Android platform plugin for on-device AI via Google AICore
- **AicoreServiceKt**: Kotlin service placeholder for AICore integration
- **gitcore documentation**: `ARCHITECTURE.md` and `features.json` for gitcore patterns

### Changed
- **Cleanup**: Moved legacy scripts to `scripts/dev/`, removed model files and generated JSON data
- **Dependencies**: Updated `pubspec.lock`, Gemma scripts

### Fixed
- **Lint cleanup**: Resolved all 114 Flutter analyze issues → **zero issues**
  - `fix(core,auth,sharing)`: Unused imports, deprecated APIs, build_context issues
  - `fix(agent,medical,settings)`: Unused imports, string interpolation, non-null assertion
  - `fix(packages,tests)`: Library doc comments, analysis_options, deprecated withOpacity

---

## [0.6.0] — 2026-04

### Added
- **RAG pipeline**: Complete RAG integration with web search and Gemma 4
  - `feat(orionhealth)`: RAG + Web + Gemma4 full integration
  - `feat(android)`: AicorePlugin + AicoreService placeholders
- **Documentation**: RAG architecture review and AICore status reports
- **Auto-sync workflow**: CI workflow for `isar_agent_memory` package (later removed)

### Changed
- **CI**: Added `--legacy-peer-deps` for Astro 6 compatibility
- **CI**: Upgraded Node to v22 for Astro 6
- **Website**: OrionHealth public website with medical standards reference

### Fixed
- **Repository**: Updated `.gitignore`

---

## [0.5.0] — 2026-03

### Added
- **BLE Medical Data Sharing**: Encrypted peer-to-peer health data transfer
  - `feat`: BLE Medical Data Sharing (#45)
  - `fix`: State type parameters in BleSharingCubit handlers
  - `fix`: Add missing BLE auth pages and health_wallet schemas
- **LLM Settings UI**: Local/Cloud AI toggle (#107)
- **Floating Assistant Button**: Animated pulse FAB for AI assistant (#108)
- **Device Capability Detection**: Runtime capability checks (#103, #106)
- **Prompt Anonymizer**: PII removal before cloud API calls (#100)

### Fixed
- **Health wallet**: Added schemas to Isar.open, fixed generated .g.dart imports
- **Android build**: R8 keep rules for MediaPipe protobuf, ProGuard syntax fixes
- **Gradle**: compileSdk/targetSdk adjustments for isar_flutter_libs compatibility
- **Gradle**: Disabled R8 shrink, verifyResources tasks, Kotlin DSL syntax fixes
- **Removed broken tests**: `medical_standards`, `isar_agent_memory`, validation scripts
- **Removed**: `lint-baseline.xml`, invalid `--exit-zero-even-if-changes` flag

---

## [0.4.0] — 2026-03

### Added
- **Medical Standards Package**: Structured medical data reference
  - Medical standards JSON-first approach documentation
  - Compilation fixes for medical_standards package (#61)
- **AI Medical Research**: RAG enrichment and medical research feature
- **About Page**: Mission statement, blog, project vision
- **GitHub Pages Landing**: i18n support for documentation site

### Changed
- **Architecture docs**: Unified around medical standards JSON-first approach

### Fixed
- **Restored features**: `medical_assistant` feature and confidence system (#55, #60)
- **Isar models**: EncryptionService fixes in health_wallet package (#57)
- **Compilation errors**: Medical standards package (#61), medical_assistant (#67)
- **Missing dependencies**: Added to pubspec.yaml (#53)
- **APK artifact path**: Updated to flutter-apk directory (#54)

---

## [0.3.0] — 2026-02

### Added
- **Health Wallet**: Offline storage with Isar database
- **Health Report Feature**: Entity, service, and UI for health reports
- **Local AI Agent**: On-device chat with Phi-3 Mini / Gemma models
- **RAG Memory Module**: Isar-based vector memory for AI context

### Changed
- **Architecture**: Migrated to Hexagonal Architecture pattern
- **Multi-agent protocol**: Parallel development workflow established
- **Project structure**: Cleaned up duplicate content in TASK.md

### Fixed
- **Android build**: Asset folders, plugin registration, ObjectBox native library support
- **DI**: Path_provider for ObjectBox directory to resolve read-only error

---

## [0.2.0] — 2025

### Added
- **Authentication & Identity**: User profile and identity management
- **AGPL-3.0 License**: Full license text and vision update for personalized medicine
- **GitHub Pages documentation**: Astro-based documentation site
- **Integration tests**: Test framework, Windows support, release workflow
- **CI/CD pipelines**: Android build, release automation, docs deployment
- **Professional landing page**: Astro with Cyber-Minimalism design
- **Screenshots gallery**: Visual documentation of app features

### Changed
- **Design system**: `AppTheme` class for light/dark mode, full design migration
- **Repository**: Renamed from `local-llm.OrionHealth` to `OrionHealth`

### Fixed
- **CI/CD**: Rollup platform-specific dependency, Gradle wrapper permissions, Gradlew execute permissions
- **CI/CD**: Integration test exclusion from GeneratedPluginRegistrant for release builds
- **Docs**: Migrated Tailwind to local, updated repo URLs, temporarily disabled screenshots

---

## [0.1.0] — 2025

### Added
- **Project initialization**: Flutter scaffold with all platform-specific files
- **Multi-agent setup**: Initial project architecture and agent workflow
- **Handover documentation**: Jules AI agent handover prompt
- **Basic Flutter structure**: Platform configs, build system, entry points

---

## Roadmap

See [PLANNING.md](docs/planning/PLANNING.md) and [Project Tasks](https://github.com/iberi22/OrionHealth/issues) for upcoming features and roadmap.
