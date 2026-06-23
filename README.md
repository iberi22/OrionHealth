# OrionHealth 🏥

**Your Personal Health Data Sanctuary for the Future of Personalized Medicine**

[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)
[![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue?logo=flutter)](https://flutter.dev)
[![CI](https://github.com/iberi22/OrionHealth/actions/workflows/ci.yml/badge.svg)](https://github.com/iberi22/OrionHealth/actions/workflows/ci.yml)
[![Stars](https://img.shields.io/github/stars/iberi22/OrionHealth?style=social)](https://github.com/iberi22/OrionHealth/stargazers)
[![Last Commit](https://img.shields.io/github/last-commit/iberi22/OrionHealth)](https://github.com/iberi22/OrionHealth/commits/main)
[![Privacy First](https://img.shields.io/badge/Privacy-First-green)](https://github.com/iberi22/OrionHealth)
[![Docs](https://img.shields.io/badge/docs-GitHub%20Pages-blue)](https://iberi22.github.io/OrionHealth/)
[![Dart SDK](https://img.shields.io/badge/Dart-3.10+-blue?logo=dart)](https://dart.dev)
[![Code Size](https://img.shields.io/github/languages/code-size/iberi22/OrionHealth)](https://github.com/iberi22/OrionHealth)

---

## 📊 Project Status

**v0.9.0** — Tests `325+ pass / 2 fail` (99.4%+) ✅ | Clean Architecture Coverage: **17/25 (68%) full** + **4/25 (16%) near-complete** = **84% with all 4 layers** | Offline-first AI ✅ | On-device TTS ✅ | Audio Recording ✅ | Secure Storage ✅ | Environment Config ✅ | Lazy Loading ✅ | 23/25 features have all 4 Clean Architecture layers ✅

> **Full coverage details:** [`coverage_report.md`](./coverage_report.md) | **Feature Catalog:** [`features.json`](./features.json)

---

## 🌟 Vision

**OrionHealth** is a privacy-first, local-first health assistant that enables individuals to own and control their complete health data history. Built with Flutter and powered by on-device AI, it creates a secure "Digital Health Sheet" that integrates medical records, sensor data (Apple HealthKit, Google Health Connect), and AI-powered insights—all without compromising your privacy.

---

## 🏗️ Architecture

OrionHealth follows **Clean Architecture** with 4 layers. For a detailed breakdown, see [**ARCHITECTURE.md**](./ARCHITECTURE.md).

```
lib/
├── core/                    # Shared infrastructure
│   ├── config/              # Environment & build config
│   │   ├── environment.dart # Runtime environment (dev/staging/prod)
│   │   └── build_config.dart# Build-time flavor config
│   ├── di/                  # Dependency injection (GetIt + injectable)
│   ├── services/            # Core services
│   │   ├── audio/           # AudioPlayerService, AudioRecorderService
│   │   ├── tts/             # TTS adapters (SherpaOnnx, System)
│   │   ├── app_logger.dart  # Structured logging
│   │   └── secure_storage_service.dart # Encrypted storage
│   ├── theme/               # App theme (dark mode)
│   ├── utils/               # Utilities (cache, error handler, lazy_router)
│   └── widgets/             # Shared widgets (error_boundary)
├── features/                # Feature modules (Clean Architecture)
│   ├── auth/                # Authentication + DID/VC
│   ├── meditation/          # Offline-guided meditation
│   ├── voice_chat/          # AI voice chat with TTS/ASR
│   └── ...                  # 21+ additional features
├── l10n/                    # Localization (Spanish)
└── main.dart                # App entry point
```

### Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| State Management | flutter_bloc | Predictable, testable, scalable |
| DI | get_it + injectable | Compile-time code gen, no runtime reflection |
| TTS | sherpa_onnx (on-device) | Privacy-first, no cloud dependency |
| Audio | just_audio + record | Lightweight, native platform integration |
| Storage | flutter_secure_storage | Encrypted at rest, Keychain/Keystore backed |
| FHIR | fhir_dstu2 + fhir_r4 | Industry standard for health data |
| ObjectBox | isar_agent_memory | Embedded vector database for AI memory |
| Logging | AppLogger | Structured, level-based, release-mode silent |

---

## 🚀 Getting Started

### Prerequisites

- **Flutter** 3.10+ / Dart 3.10+
- **Android Studio** or **VS Code** with Flutter extension
- **Git LFS** (for large model files)

### Setup

```bash
# Clone the repository
git clone https://github.com/iberi22/OrionHealth.git
cd OrionHealth

# Install dependencies
flutter pub get

# Run code generation (DI, JSON serialization, etc.)
dart run build_runner build --delete-conflicting-outputs

# Run on device
flutter run
```

### Build Flavors

OrionHealth supports three build flavors:

```bash
# Development (debug)
flutter run --flavor dev --dart-define=flavor=dev

# Staging (profile)
flutter run --flavor staging --dart-define=flavor=staging

# Production (release)
flutter build apk --flavor prod --dart-define=flavor=prod
flutter build ios --flavor prod --dart-define=flavor=prod
```

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Watch mode
flutter test --watch

# Coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 🛠️ Key Features

- **🔐 Privacy-first**: All processing on-device, no cloud dependency
- **🗣️ Voice AI Chat**: Natural conversation with on-device TTS/ASR
- **🧘 Offline Meditation**: Guided sessions with breathing exercises
- **🏥 FHIR Integration**: Medical records via standard FHIR R4
- **🔒 Secure Storage**: Encrypted data at rest with platform keychain
- **🎯 Personalized AI**: Local agent memory for context-aware responses
- **📊 Health Metrics**: Sync with Apple HealthKit & Google Health Connect
- **🔗 DID/VC**: Self-Sovereign Identity for health data sharing

---

## 🤝 Contributing

We follow a specific development workflow. Please read our [**GITPROTOCOL.md**](./GITPROTOCOL.md) before contributing.

1. Fork the repository
2. Create a feature branch (`git checkout -b feat/your-feature`)
3. Commit changes (`git commit -m "feat: add amazing feature"`)
4. Push to the branch (`git push origin feat/your-feature`)
5. Open a Pull Request

### Issue Labels

| Label | Purpose |
|-------|---------|
| `jules` | Tasks for automated AI agent |
| `bug` | Bug reports |
| `enhancement` | Feature requests |
| `dependencies` | Dependency updates |

---

## 📄 License

[AGPL-3.0](https://www.gnu.org/licenses/agpl-3.0) — see [LICENSE](./LICENSE)

---

## 📞 Contact

- **Repository**: [github.com/iberi22/OrionHealth](https://github.com/iberi22/OrionHealth)
- **Docs**: [iberi22.github.io/OrionHealth](https://iberi22.github.io/OrionHealth/)
- **Bug Reports**: [Issues](https://github.com/iberi22/OrionHealth/issues)

---

*Built with ❤️ by SouthWest AI Labs*
