# Production Readiness Checklist

## 🛡️ Security & Privacy
- [ ] AES-256-GCM encryption verified for all collections.
- [ ] Biometric lock functional on Android/iOS.
- [ ] Session timeout (15 mins) tested.
- [ ] Local model weights excluded from regular backups.

## 🏗️ Architecture & Code Quality
- [ ] Hexagonal layers strictly separated.
- [ ] All features have a `main_preview.dart` for isolation.
- [ ] Dependency injection fully wired in `injection.dart`.
- [ ] `flutter analyze` passes with zero warnings.

## 🧪 Testing
- [ ] Core domain entities have 90%+ unit test coverage.
- [ ] Repository implementations tested with Isar mock/temp db.
- [ ] Onboarding flow verified with integration tests.

## 📦 Build & Release
- [ ] Android Proguard/R8 rules configured.
- [ ] App icons and splash screens updated.
- [ ] Versioning follows Semantic Versioning (SemVer).
- [ ] CI/CD pipeline green.
