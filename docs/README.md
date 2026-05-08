# OrionHealth Monorepo Documentation

Welcome to the **OrionHealth** monorepo. This repository contains the mobile application, internal packages, medical standards data, and the professional documentation site.

## 📁 Repository Structure

This monorepo is organized to support a privacy-first, local-first medical intelligence network.

```text
.
├── android/            # Android-specific native code and configurations
├── assets/             # Global assets (images, icons, medical-standards JSON)
├── docs/               # Documentation site (Astro) and markdown guides
│   ├── api/            # API documentation for internal packages
│   ├── architecture/   # Architectural deep-dives and diagrams
│   ├── medical/        # Medical data gaps and research
│   ├── planning/       # Roadmap, tasks, and project vision
│   └── src/            # Astro source code for the documentation site
├── functions/          # Backend functions (e.g., Telegram support bot)
├── ios/                # iOS-specific native code and configurations
├── lib/                # Main Flutter application source code (Hexagonal Architecture)
│   ├── core/           # Shared utilities, DI, theme, and common widgets
│   └── features/       # Modular features (auth, reports, health_record, etc.)
├── medical-standards/  # Raw medical standards data (ICD-10, LOINC, etc.)
├── packages/           # Internal Dart/Flutter packages
│   ├── health_wallet/  # Encrypted local health record models
│   ├── isar_agent_memory/ # Graph + Vector DB for RAG
│   └── medical_standards/ # Parsers and loaders for medical codes
├── scripts/            # Build, maintenance, and verification scripts
├── test/               # Unit and widget tests for the main application
└── integration_test/   # E2E and visual regression tests
```

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: ^3.7.0
- **Node.js & npm**: (For the documentation site)
- **Git**: Latest version

### 📱 Developing the Mobile App

1.  **Clone and Install**:
    ```bash
    git clone https://github.com/iberi22/OrionHealth.git
    cd OrionHealth
    flutter pub get
    ```
2.  **Generate Code**:
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```
3.  **Run the App**:
    ```bash
    flutter run
    ```

### 🌐 Developing the Documentation Site

The documentation site is built with **Astro 6** and **Tailwind CSS v4**.

1.  **Navigate and Install**:
    ```bash
    cd docs
    npm install --legacy-peer-deps
    ```
2.  **Start Dev Server**:
    ```bash
    npm run dev
    ```

## 📖 Internal Documentation

- **[Architecture](./ARCHITECTURE.md)**: Deep dive into Hexagonal Architecture and RAG pipeline.
- **[Contributing](./CONTRIBUTING.md)**: Guidelines for contributing code and documentation.
- **[Dev Guide](./dev-guide.md)**: Onboarding guide for new developers.
- **[RAG Architecture](./rag-architecture-review.md)**: Detailed review of the on-device AI system.
- **[API Index](./api/index.md)**: Documentation for internal packages.

## 🚢 Deployment

### Mobile App
The app is built and released via GitHub Actions (`.github/workflows/android_build.yml`).
Manual release build:
```bash
flutter build apk --release
```

### Documentation Site
The site is automatically deployed to GitHub Pages via `.github/workflows/deploy-docs.yml`.
Live URL: [https://iberi22.github.io/OrionHealth](https://iberi22.github.io/OrionHealth)

## ⚖️ License

This project is licensed under the **GNU Affero General Public License v3.0 (AGPL-3.0)**. See the [LICENSE](../LICENSE) file in the repository root for details.
