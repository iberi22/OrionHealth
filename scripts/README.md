# OrionHealth Scripts

Automation scripts for development, testing, and deployment.

## 🚀 Pre-Push Check

Comprehensive validation before pushing code to ensure CI will pass.

### Usage

**Windows (PowerShell):**
```powershell
.\scripts\pre-push-check.ps1
```

**Linux/macOS (Bash):**
```bash
chmod +x scripts/pre-push-check.sh
./scripts/pre-push-check.sh
```

### What It Checks

1. ✅ **Flutter Analyze** - Static analysis for Dart code
2. ✅ **Rust Format** - Code formatting check (`cargo fmt --check`)
3. ✅ **Rust Clippy** - Linter with `-D warnings` (fail on warnings)
4. ✅ **Rust Tests** - All unit and integration tests
5. ✅ **Bridge Sync** - Validates `flutter_rust_bridge` is in sync
6. ✅ **Flutter Tests** - All Dart unit and widget tests
7. ✅ **Integration Tests** - E2E tests (if they exist)

### Exit Codes

- `0` - All checks passed, safe to push
- `1` - One or more checks failed, fix before pushing

### Setting Up Git Hook

To run automatically before every push:

**Linux/macOS:**
```bash
cat > .git/hooks/pre-push << 'EOF'
#!/bin/bash
./scripts/pre-push-check.sh
EOF
chmod +x .git/hooks/pre-push
```

**Windows (PowerShell):**
```powershell
@"
#!/bin/bash
powershell.exe -ExecutionPolicy Bypass -File scripts/pre-push-check.ps1
"@ | Out-File -FilePath .git/hooks/pre-push -Encoding ASCII
```

### Troubleshooting

**Bridge out of sync:**
```bash
flutter_rust_bridge_codegen \
  --rust-input rust/src/api \
  --dart-output lib/bridge \
  --dart-format-line-length 80
git add lib/bridge/
git commit -m "chore(bridge): regenerate flutter_rust_bridge"
```

**Rust format issues:**
```bash
cd rust && cargo fmt
```

**Clippy warnings:**
```bash
cd rust && cargo clippy --fix --all-targets --all-features
```

## 📚 Related Documentation

- [.github/copilot-instructions.md](../.github/copilot-instructions.md) - AI agent guide
- [DEPLOY_CICD_README.md](../DEPLOY_CICD_README.md) - CI/CD workflows
- [docs/CICD_SYSTEM_GUIDE.md](../docs/CICD_SYSTEM_GUIDE.md) - Complete CI/CD guide
- [AGENTS.md](../AGENTS.md) - Git-Core Protocol for AI agents

## 🎯 Quick Commands

```bash
# Run all checks
./scripts/pre-push-check.sh

# Individual checks
flutter analyze
flutter test
cd rust && cargo test
flutter_rust_bridge_codegen --rust-input rust/src/api --dart-output lib/bridge
flutter test integration_test/

# Fix common issues
cd rust && cargo fmt              # Format Rust code
cd rust && cargo clippy --fix     # Auto-fix clippy issues
flutter format lib/               # Format Dart code
```

---

**Note:** These scripts are designed to match exactly what runs in CI/CD (`.github/workflows/ci-cd-main.yml`), ensuring no surprises when you push.
