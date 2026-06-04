# Changelog

All notable changes to OrionHealth will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

See [PLANNING.md](PLANNING.md) and [TASK.md](TASK.md) for upcoming features and roadmap.
