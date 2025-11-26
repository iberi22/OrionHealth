# OrionHealth 🏥

**Your Personal Health Data Sanctuary for the Future of Personalized Medicine**

[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Privacy First](https://img.shields.io/badge/Privacy-First-green)](https://github.com/iberi22/local-llm.OrionHealth)

---

## 🌟 Vision

**OrionHealth** is a privacy-first, local-first health assistant that enables individuals to own and control their complete health data history. Built with Flutter and powered by on-device AI, it creates a secure "Digital Health Sheet" that integrates medical records, sensor data (Apple HealthKit, Google Health Connect), and AI-powered insights—all without compromising your privacy.

### Why This Matters

**The Future of Medicine is Personal. And It Starts With Your Data.**

Every diagnosis, prescription, lab result, and health measurement you've ever had contains invaluable information. Today, this data is fragmented across hospitals, clinics, and wearables—inaccessible when you need it most.

OrionHealth changes that by:

1. **Centralizing Your Health History**: All your medical records, test results, prescriptions, and sensor data in one secure, portable app
2. **Preserving Privacy**: Your data never leaves your device unencrypted. No cloud uploads, no third-party access
3. **Enabling Future Innovation**: By maintaining a comprehensive, structured health timeline, you prepare your data for the next generation of AI-powered medical research

### The Long-Term Goal: Democratizing Personalized Medicine

Today's medicine follows a "one-size-fits-all" approach. Tomorrow's medicine will be **uniquely yours**.

OrionHealth is designed to be the foundation for a future where:

- **Advanced LLMs** (more powerful than today's models) can analyze your complete health history
- **Personalized treatment plans** are generated based on your unique genetic profile, medical history, and lifestyle
- **Drug discovery** accelerates through aggregated, anonymized health data donated by users
- **Clinical trials** become more efficient by matching patients with relevant studies
- **Preventive medicine** becomes predictive, catching issues before they become serious

By using OrionHealth today, you're not just organizing your health data—**you're preparing for a future where that data could save your life or help develop treatments for others**.

---

## ✨ Key Features

### 🔒 Privacy & Security
- **100% Local-First**: All data stored on-device using Isar database
- **Zero Cloud Dependencies**: Works completely offline
- **Encrypted Storage**: Medical-grade data protection
- **No Tracking**: No analytics, no telemetry, no third parties

### 📋 Health Record Management
- **Document Ingestion**: Upload PDFs, images, lab reports
- **OCR Integration**: Automatic text extraction from medical documents
- **Structured Data**: Convert unstructured records into queryable format
- **Sensor Integration**: Sync with Apple HealthKit & Google Health Connect

### 🤖 On-Device AI Intelligence
- **Local LLM**: Phi-3 Mini / Gemma 2B via ONNX Runtime
- **RAG (Retrieval Augmented Generation)**: Contextual health insights
- **Private Chat**: Ask questions about your health history
- **Trend Analysis**: AI-powered pattern recognition

### 📊 Insights & Reporting
- **Health Timeline**: Visualize your complete medical journey
- **Statistical Dashboards**: Track vitals, medications, symptoms
- **Export Reports**: Generate summaries for doctors (PDF/CSV)
- **Weekly AI Summaries**: Personalized health insights

---

## 🏗️ Architecture

OrionHealth follows **Hexagonal Architecture (Ports & Adapters)** for maximum modularity and testability:

```text
lib/
├── core/                   # Shared utilities, DI, theme
├── features/
│   ├── health_record/      # Medical history management
│   │   ├── domain/         # Entities & Repository interfaces
│   │   ├── application/    # Use cases (business logic)
│   │   ├── infrastructure/ # Isar DB, HealthKit adapters
│   │   └── presentation/   # UI (BLoC + Material 3)
│   │
│   ├── local_agent/        # AI chat & RAG
│   │   ├── domain/         # Message entities
│   │   ├── application/    # LLM use cases
│   │   ├── infrastructure/ # ONNX runtime, embeddings
│   │   └── presentation/   # Chat interface
│   │
│   ├── user_profile/       # User settings & preferences
│   └── health_report/      # Analytics & export
└── main.dart
```

**Tech Stack:**
- **Framework**: Flutter 3.x (Material Design 3)
- **State Management**: `flutter_bloc`
- **Database**: `isar` (NoSQL + vector embeddings)
- **AI Inference**: `onnxruntime` (Phi-3/Gemma)
- **Health Data**: `health` package (cross-platform)
- **Dependency Injection**: `get_it` + `injectable`

---

## 🚀 Getting Started

### Prerequisites
```bash
# Flutter SDK 3.19+
flutter --version

# Check device compatibility
flutter doctor
```

### Installation
```bash
# Clone the repository
git clone https://github.com/iberi22/local-llm.OrionHealth.git
cd OrionHealth

# Install dependencies
flutter pub get

# Run on your device
flutter run
```

### First-Time Setup
1. **Create Your Profile**: Enter basic health information
2. **Upload First Record**: Add a medical document or lab result
3. **Connect Sensors** (Optional): Sync Apple Health / Google Fit
4. **Download AI Model** (Optional): Enable on-device chat assistant

---

## 📖 Documentation

- **[PLANNING.md](PLANNING.md)**: Architecture decisions & development phases
- **[TASK.md](TASK.md)**: Project roadmap & task tracking
- **[CONTRIBUTING.md](docs/CONTRIBUTING.md)**: How to contribute

## 🛠️ Support & Feedback

We use an automated system to handle community feedback efficiently:

- **Telegram Bot**: Send messages to our bot to report bugs or request features.
- **GitHub Issues**: All reports are automatically converted into GitHub Issues for transparency.

---

## 🤝 Contributing

**OrionHealth is open source and free forever.** We believe health data ownership should be accessible to everyone.

However, this project is licensed under **AGPL-3.0** to ensure it remains non-commercial:
- ✅ **Use it freely**: Personal, research, educational purposes
- ✅ **Modify & improve**: Fork, customize, enhance
- ✅ **Share your changes**: Contribute back to the community
- ❌ **No commercial use**: You cannot sell this app or use it in paid services without releasing your code under AGPL-3.0

**Why AGPL?**
We want to prevent companies from taking this code, adding proprietary features, and charging for health data management. Your health data should always be free and under your control.

See [LICENSE](LICENSE) for full details.

---

## 🌍 The Bigger Picture: Open Health Data for Research

OrionHealth is designed with a future vision:

**Phase 1 (Today)**: Individual users collect and own their health data
**Phase 2 (Near Future)**: Optional anonymized data donation for research
**Phase 3 (Long-Term)**: Federated learning across user datasets to train medical AI
**Phase 4 (Ultimate Goal)**: Personalized drug discovery and treatment optimization powered by advanced LLMs

By structuring your health data in OrionHealth's format today, you're preparing for a future where AI can:
- Predict disease risk based on your unique genetic and lifestyle factors
- Recommend personalized treatments with higher efficacy
- Identify adverse drug interactions specific to your medical history
- Accelerate clinical trials by matching you with relevant studies

**Your data, your choice. But together, we can transform medicine.**

---

## 📜 License

This project is licensed under the **GNU Affero General Public License v3.0 (AGPL-3.0)**.

**TL;DR:**
- Free to use, modify, and distribute
- **Must remain open source** (copyleft)
- **Cannot be commercialized** without releasing source code
- If you run a modified version as a web service, you must share the code

See [LICENSE](LICENSE) for full terms.

---

## 💬 Community & Support

- **Issues**: [GitHub Issues](https://github.com/iberi22/local-llm.OrionHealth/issues)
- **Discussions**: [GitHub Discussions](https://github.com/iberi22/local-llm.OrionHealth/discussions)
- **Website**: [Coming Soon - GitHub Pages Landing]

---

## 🙏 Acknowledgments

Built with:
- [Flutter](https://flutter.dev) - Google's UI toolkit
- [Isar Database](https://isar.dev) - Fast local storage
- [ONNX Runtime](https://onnxruntime.ai) - AI inference
- [Health Package](https://pub.dev/packages/health) - Sensor integration

Special thanks to the open-source health tech community for making privacy-first healthcare tools possible.

---

**⚠️ Medical Disclaimer**: OrionHealth is a personal health data management tool, not a medical device. It does not provide medical advice, diagnosis, or treatment. Always consult qualified healthcare professionals for medical decisions.
