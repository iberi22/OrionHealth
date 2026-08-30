# OrionHealth 🏥

[![CI](https://github.com/iberi22/OrionHealth/actions/workflows/ci.yml/badge.svg)](https://github.com/iberi22/OrionHealth/actions/workflows/ci.yml)
[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)
[![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue?logo=flutter)](https://flutter.dev)
[![Docs](https://img.shields.io/badge/docs-GitHub%20Pages-blue)](https://iberi22.github.io/OrionHealth/)
[![Privacy First](https://img.shields.io/badge/Privacy-First-green)](https://github.com/iberi22/OrionHealth)

OrionHealth is an open-source, privacy-first personal health intelligence platform and wallet built with Flutter.
It gives individuals complete ownership of their medical records, wearable metrics, and clinical insights through
on-device AI models and Self-Sovereign Identity standards without relying on centralized cloud providers.

---

## 📊 Project Status

**v0.9.0** — Tests `325+ pass / 2 fail` (99.4%+) ✅ | **Real Score: 100%** (26 features, 4/5 layers, 0 golden) | Offline-first AI ✅ | On-device TTS ✅ | Audio Recording ✅ | Secure Storage ✅ | Environment Config ✅ | Lazy Loading ✅ | 23/26 features have all 4 Clean Architecture layers ✅

> **Full coverage details:** [`coverage_report.md`](docs/status/coverage_report.md) | **Feature Catalog:** [`features.json`](./features.json)

---

## ⚡ Quickstart

OrionHealth is packaged as `orionhealth_health` and supports mobile and desktop platforms (`android/`, `ios/`, `windows/`).

### Setup & Run

```bash
# Clone the repository
git clone https://github.com/iberi22/OrionHealth.git
cd OrionHealth

# Install dependencies
flutter pub get

# Generate dependency injection & serialization code
dart run build_runner build --delete-conflicting-outputs

# Run application on target device
flutter run
```

### Build Flavors

```bash
# Development (debug)
flutter run --flavor dev --dart-define=flavor=dev

# Staging (profile)
flutter run --flavor staging --dart-define=flavor=staging

# Production (release)
flutter build apk --flavor prod --dart-define=flavor=prod
flutter build ios --flavor prod --dart-define=flavor=prod
```

> **First-Run Note:** On initial startup, on-device AI models (Sherpa ONNX TTS, Gemma LLM) and embedded vector stores (Isar Agent Memory) initialize local models on hardware. No cloud accounts or API keys are required for core offline operation.

---

## ✨ Features

- 🔐 **Privacy-First Core**: Zero telemetry, on-device vector database (Isar Agent Memory), and fully local model execution.
- 🆔 **Self-Sovereign Identity (SSI)**: Decentralized identifiers (DIDs), AnonCreds, and W3C Verifiable Credentials for cryptographic data control.
- 🗣️ **Local AI Voice Assistant**: Natural voice interaction powered by on-device Gemma LLM and Sherpa ONNX text-to-speech.
- 🏥 **Interoperable FHIR Integration**: Native support for FHIR R4 & DSTU2 clinical data exchanges and composition mapping.
- 🧘 **Offline Health & Wellness**: Offline guided meditation, mood tracking, and audio processing completely detached from cloud servers.
- 📊 **Wearable & Health Sync**: Direct integration with Apple HealthKit and Google Health Connect sensor streams.
- 🔒 **Hardware-Backed Storage**: Sensitive credentials and encryption keys stored securely in OS Keychain/KeyStore.
- 💊 **Medication & Interaction Checkers**: Drug-drug interaction detection using standardized pharmacy APIs and local indexes.
- 📈 **Clinical Report Summaries**: On-device medical report generation mapped to universal medical standards.
- 🌍 **Multi-Language Support**: Fully localized interface with offline translation capabilities.

---

## 🛡️ Privacy Architecture

- **Zero Cloud Leakage**: All personal health records, embeddings, and chat history remain strictly on the user's physical device.
- **Hardware-Level Encryption**: Keys and secrets are secured using OS Keychain/KeyStore via `flutter_secure_storage`.
- **On-Device Machine Learning**: Vector embeddings and LLM inference run entirely locally via `onnxruntime` and `isar_agent_memory`.
- **Verifiable Data Ownership**: Employs W3C Verifiable Credentials, AnonCreds, and DIDs for cryptographic proof without central identity providers.
- **Local PII Protection**: Automated sanitization and masking of personally identifiable information prior to local indexing.

---

## 🩺 Medical Standards

OrionHealth integrates universal health and clinical standards across the application stack:

| Standard | Description | Where Used in App |
| :--- | :--- | :--- |
| **ICD-10** | International Classification of Diseases | Diagnostic coding, condition mapping, and clinical report indexing (`lib/features/local_agent/`, `lib/features/reports/`) |
| **LOINC** | Logical Observation Identifiers Names and Codes | Laboratory observations, FHIR composition mapping, and health summaries (`lib/features/sync/`, `lib/features/local_agent/`) |
| **RxNorm** | Standardized Nomenclature for Clinical Drugs | Medication profile tracking, dosage mapping, and interaction checking (`lib/features/medications/`, `lib/features/medical_research/`) |
| **SNOMED CT** | Systematized Nomenclature of Medicine | Clinical terminology resolution and medical research querying (`lib/features/medical_research/`, `lib/features/local_agent/`) |

---

## 🏗️ Architecture

OrionHealth follows **Clean Architecture** structured into 4 main layers. For detailed documentation, see [**ARCHITECTURE.md**](docs/architecture/ARCHITECTURE.md).

```
lib/
├── core/                    # Shared infrastructure
│   ├── config/              # Environment & build config
│   │   ├── environment.dart # Runtime environment (dev/staging/prod)
│   │   └── build_config.dart# Build-time flavor config
│   ├── di/                  # Dependency injection (GetIt + injectable)
│   ├── services/            # Core services (audio, tts, secure storage, logging)
│   ├── theme/               # App theme (dark mode)
│   ├── utils/               # Utilities (cache, error handler, lazy_router)
│   └── widgets/             # Shared widgets (error_boundary)
├── features/                # Feature modules (Clean Architecture)
│   ├── auth/                # Authentication + DID/VC / SSI
│   ├── meditation/          # Offline-guided meditation
│   ├── voice_chat/          # AI voice chat with TTS/ASR
│   └── ...                  # 21+ additional features
├── l10n/                    # Localization
└── main.dart                # App entry point
```

### Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| State Management | flutter_bloc | Predictable, testable, scalable state handling |
| Dependency Injection | get_it + injectable | Compile-time code generation, no runtime reflection |
| TTS / Voice | sherpa_onnx (on-device) | Privacy-first local synthesis with zero cloud reliance |
| Audio Engine | just_audio + record | Native platform integration for playback and recording |
| Storage | flutter_secure_storage | Encrypted at rest, Keychain/Keystore backed |
| FHIR Engine | fhir_dstu2 + fhir_r4 | Interoperable industry standard for clinical data |
| Database / Memory | isar_agent_memory | Embedded vector database for local AI context |
| Logging | AppLogger | Structured logging, silent in release builds |

---

## 🧪 Testing & Benchmarking

```bash
# Run unit and widget tests
flutter test

# Watch mode
flutter test --watch

# Coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Run Embedding Quality Benchmark for Medical RAG
dart run scripts/benchmark_embeddings.dart --help
dart run scripts/benchmark_embeddings.dart --fixture test/fixtures/medical_benchmark_queries.json
```

---

## 🤝 Contributing

We follow a specific development workflow. Please read our [**GITPROTOCOL.md**](./GITPROTOCOL.md) before submitting contributions.

1. Fork the repository
2. Create a feature branch (`git checkout -b feat/your-feature`)
3. Commit changes (`git commit -m "feat: add amazing feature"`)
4. Push to the branch (`git push origin feat/your-feature`)
5. Open a Pull Request

---

## 📄 License

Distributed under the **AGPL-3.0 License**. See [LICENSE](./LICENSE) for more information.

---

## 📞 Contact

- **Repository**: [github.com/iberi22/OrionHealth](https://github.com/iberi22/OrionHealth)
- **Documentation**: [iberi22.github.io/OrionHealth](https://iberi22.github.io/OrionHealth/)
- **Issue Tracker**: [GitHub Issues](https://github.com/iberi22/OrionHealth/issues)

---

*Built with ❤️ by SouthWest AI Labs*
