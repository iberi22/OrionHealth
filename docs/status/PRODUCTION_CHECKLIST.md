# OrionHealth - Production Readiness Checklist (v0.9.x)

> **Estado:** Open Beta — versión 0.9.x, preparando para release estable.

## Pre-Release Verification

### Code Quality
- [ ] flutter analyze passes (lib directory is clean)
- [ ] All unit tests pass
- [ ] All E2E tests pass (Integration tests require specific native setup)
- [x] No TODO comments without issue tracking

### Dependencies
- [x] All pubspec dependencies are pinned
- [x] No conflicting versions
- [x] All assets properly declared

### Security
- [x] No API keys in source code
- [ ] Encryption properly implemented (Isar encryption PENDING)
- [x] PIN/biometric auth in place
- [ ] Data at rest is encrypted (PENDING)

### Medical Standards
- [x] ICD-10 data is complete
- [x] LOINC codes are accurate
- [x] Medications list is up to date
- [x] Clinical guidelines are referenced

### Privacy
- [x] Privacy consent implemented
- [x] Data export works (GDPR)
- [x] Data deletion works (right to be forgotten)

### Platform Specific
- [ ] Android build succeeds
- [ ] iOS build succeeds (if applicable)
- [x] All platform channels implemented
- [x] Permissions properly declared

### Documentation
- [x] README complete
- [x] API documentation (if applicable)
- [x] User documentation
- [x] Architecture documentation

## Release Steps (cuando esté lista)
1. `git tag v1.0.0 && git push origin v1.0.0`
2. Verify GitHub Actions run
3. Download artifacts
4. Sign APK/AAB
5. Upload to stores
