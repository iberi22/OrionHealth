# Developer Guide — OrionHealth

## Prerequisites
- Flutter SDK ^3.7.0
- Dart SDK ^3.0
- Android Studio / VS Code
- Git

## First-time Setup
```bash
git clone https://github.com/iberi22/OrionHealth.git
cd OrionHealth
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## Running Tests
```bash
# All tests
flutter test

# Single test file
flutter test test/path/to/test.dart

# With coverage (requires lcov)
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Flutter Analyze
```bash
flutter analyze --no-pub
# Should return: No issues found!
```

## Building
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```

## Project Structure
```
lib/
├── core/          — DI, services, theme
├── features/      — Feature modules (auth, health_wallet, etc.)
packages/
├── isar_agent_memory/ — Graph + Vector DB
├── health_wallet/     — Offline health records
├── medical_standards/ — ICD-10, LOINC, RxNorm, SNOMED
android/
└── AicorePlugin.kt    — On-device LLM bridge
```

## Commit Convention
Use conventional commits:
- `feat:` new feature
- `fix:` bug fix
- `docs:` documentation
- `chore:` maintenance
- `refactor:` code change without feature/bug
- `test:` test changes
