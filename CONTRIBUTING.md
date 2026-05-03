# Contributing to OrionHealth

Thank you for your interest in contributing to OrionHealth! We welcome contributions from the community. This document outlines the process for contributing to the project.

> **Note on health data**: OrionHealth is a local-first health data application. Please **never share real health data** in issues, pull requests, or discussions. Use synthetic or anonymized examples when discussing health-related features.

---

## Getting Started

### Prerequisites

- **Flutter SDK**: 3.19+ ([Install Flutter](https://docs.flutter.dev/get-started/install))
- **Dart SDK**: 3.0+ (included with Flutter)
- **Git**: Latest version
- **IDE**: VS Code (recommended), Android Studio, or IntelliJ

### Development Environment Setup

```bash
# Clone the repository
git clone https://github.com/iberi22/OrionHealth.git
cd OrionHealth

# Install Flutter dependencies
flutter pub get

# Verify setup
flutter doctor

# Run the app
flutter run
```

### Additional Setup Steps

Some features require additional setup:

1. **Health data sync**: No setup needed (works offline)
2. **On-device AI**: Download Gemma 4 model through app settings (optional)
3. **API keys** (optional): Set `GEMINI_API_KEY` environment variable for cloud AI fallback

---

## Development Workflow

### Branch Strategy

We use a simplified Git Flow:

| Branch | Purpose |
|--------|---------|
| `main` | Production-ready code (protected) |
| `develop` | Integration branch for features |
| `feat/<feature-name>` | Feature branches |
| `fix/<bug-description>` | Bug fix branches |
| `docs/<description>` | Documentation-only changes |

### Workflow Steps

1. **Create a branch** from `develop`:
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feat/your-feature-name
   ```

2. **Make changes** following our code style guidelines

3. **Commit changes** using conventional commits (see below)

4. **Push and create a PR** to `develop`:
   ```bash
   git push origin feat/your-feature-name
   ```

5. **Ensure CI passes** (lint + tests)

6. **Request review** from maintainers

### Commit Style

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**
- `feat` — New feature
- `fix` — Bug fix
- `docs` — Documentation changes
- `refactor` — Code refactoring (no functional changes)
- `test` — Adding or fixing tests
- `chore` — Maintenance, dependencies, CI
- `style` — Code style (formatting, missing semicolons)
- `perf` — Performance improvements

**Examples:**
```
feat(auth): add biometric authentication support
fix(health_record): resolve OCR text extraction crash
docs(api): update README with new API endpoints
chore(deps): bump isar to v4.0.1
refactor(core): extract encryption service to separate module
```

---

## Code Style Guidelines

### Dart & Flutter

We follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style) with these additional conventions:

- **Use `flutter_lints`** — Our `analysis_options.yaml` enforces consistent linting
- **Run `flutter analyze`** before committing — ensure zero issues
- **Format with `dart format`** — Keep code consistently formatted
- **Use `const` where possible** — For better performance
- **Prefer `///` doc comments** — Especially on public APIs, entities, and use cases
- **Follow BLoC conventions** — Use `flutter_bloc` for state management

### Architecture

OrionHealth follows **Hexagonal Architecture (Ports & Adapters)**:

```
lib/features/<feature>/
├── domain/         # Entities & repository interfaces
├── application/    # Use cases (business logic)
├── infrastructure/ # Database, API, platform adapters
└── presentation/   # UI (BLoC + Material 3 widgets)
```

- `domain` should have **zero external dependencies**
- `infrastructure` implements interfaces defined in `domain`
- `presentation` should only depend on `application` and `domain`

### File Naming

- Dart files: `snake_case.dart`
- Test files: `*_test.dart`
- Generated files: `*.g.dart`, `*.freezed.dart`

---

## Testing Requirements

All contributions must maintain or improve test coverage.

### Running Tests

```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/features/health_record/repository_test.dart

# Run with coverage (optional)
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Testing Guidelines

- **Unit tests** required for all business logic (use cases, repositories, services)
- **Widget tests** required for new UI components
- **Mock dependencies** using `mockito` or manual mocks
- **Test pyramid**: Focus on unit tests (70%), widget tests (20%), integration tests (10%)
- **No real health data** in tests — use `faker` or factory constructors

---

## Pull Request Process

### Before Submitting a PR

- [ ] Code compiles without errors: `flutter analyze` passes with zero issues
- [ ] All tests pass: `flutter test` succeeds
- [ ] Code is formatted: `dart format .` has been run
- [ ] New features include tests
- [ ] Documentation is updated (README, code comments, etc.)
- [ ] Branch is up to date with `develop`: `git rebase develop`
- [ ] Commit messages follow conventional commits
- [ ] No `.g.dart` files in `lib/injection.config.dart` (let CI regenerate)

### PR Review Process

1. **Open PR** against `develop` branch
2. **CI checks** run automatically (lint + test + build)
3. **At least one maintainer review** required
4. **Address feedback** — make requested changes, or explain why not
5. **Squash merge** into `develop` when approved

### PR Title Format

Use the same type convention as commits:
```
feat: add biometric authentication
fix: resolve OCR crash on PDF upload
docs: update installation instructions
```

### After Merge

- Delete your feature branch after merge
- Celebrate your contribution! 🎉

---

## Multi-Agent Development

This project may be developed using parallel agents. If you're working as part of the multi-agent workflow:

1. Each agent owns a specific "territory" (feature directory)
2. Create interfaces (abstract classes) for dependencies on other territories
3. Use `main_preview.dart` in your feature directory for isolated testing
4. Do not modify `lib/main.dart` unless you are the integration agent
5. Do not commit `lib/injection.config.dart` unless you generated it

See `docs/CONTRIBUTING.md` for the full multi-agent protocol.

---

## License

By contributing to OrionHealth, you agree that your contributions will be licensed under **GNU Affero General Public License v3.0 (AGPL-3.0)**.

- Your code will remain open source
- Commercial use requires releasing your full source code under AGPL-3.0
- You retain copyright of your contributions

See [LICENSE](LICENSE) for full terms.

---

## Need Help?

- **GitHub Issues**: [Open an issue](https://github.com/iberi22/OrionHealth/issues)
- **Discussions**: [Start a discussion](https://github.com/iberi22/OrionHealth/discussions)
- **Email**: `support@southwest-ai-labs.com`

---

Thank you for helping make OrionHealth better! 💙
