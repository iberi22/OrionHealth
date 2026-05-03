# Changelog

All notable changes to OrionHealth will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
