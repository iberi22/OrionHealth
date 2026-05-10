# Contributing to OrionHealth

Thank you for your interest in contributing! This document provides guidelines for contributing to the OrionHealth monorepo.

## 🤝 Multi-Agent Development Protocol

If you are an AI agent or a developer working in a parallel workflow, you **must** follow these rules:

1.  **Territories**: Each agent/developer is assigned a specific feature directory. Do not modify files in another person's territory unless explicitly requested.
2.  **Interfaces**: If you need functionality from another feature that isn't ready yet, define an **Abstract Class (Interface)** in your domain and use a mock for testing.
3.  **Testing**: Use `main_preview.dart` within your feature folder for isolated UI testing. Do not modify the main `lib/main.dart` for feature-specific tests.
4.  **DI Generation**: Do not commit `lib/injection.config.dart` unless you are the integration lead. Let CI or the lead regenerate it to avoid merge conflicts.

## 🛠️ Development Workflow

1.  **Branching**: Create a branch from `develop` using the format `feat/your-feature` or `fix/bug-description`.
2.  **Commits**: Use [Conventional Commits](https://www.conventionalcommits.org/):
    - `feat:` (new feature)
    - `fix:` (bug fix)
    - `docs:` (documentation)
    - `chore:` (maintenance/deps)
3.  **Code Quality**:
    - Run `flutter analyze` and ensure zero issues.
    - Run `dart format .` before committing.
    - Ensure all tests pass with `flutter test`.

## 🧬 Code Style & Architecture

- **Architecture**: Follow **Hexagonal Architecture** (Domain -> Application -> Infrastructure/Presentation).
- **State Management**: Use `flutter_bloc` (Cubit or Bloc).
- **Immutability**: Prefer `final` and `const`.
- **Documentation**: Use `///` doc comments for public APIs and complex business logic.

## 📚 Contributing to Documentation

The documentation site is located in the `docs/` directory.

- **Technology**: Astro 6, Tailwind CSS v4.
- **Languages**: Translations are managed in `docs/src/i18n/ui.ts`.
- **Images**: Place images in `docs/public/assets/`.

To contribute a new guide:
1.  Add a new `.md` or `.astro` file to `docs/src/pages/`.
2.  Update the navigation or links in `docs/README.md`.

## 🩺 Adding New Medical Standards

Medical standards are the "recipes" of our system. To add a new standard (e.g., a new set of diagnosis codes):

1.  **Markdown Source**: Create a directory in `docs/medical-standards/` (e.g., `my-new-std/`).
2.  **Add Reference**: Add markdown files with descriptions and Wikipedia links.
3.  **JSON Schema**: Ensure the data follows the standard schema defined in `docs/planning/PLANNING.md`.
4.  **CI Trigger**: The `medical-standards-ci.yml` will automatically detect new markdown files and generate the corresponding JSON for the app.

---

*Together, we can transform medicine. Thank you for your support!* 💙
