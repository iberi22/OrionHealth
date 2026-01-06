# 🧠 GitHub Copilot Instructions - OrionHealth

> **"Privacy-First Health Data Sanctuary - Flutter + Clean Architecture + On-Device AI"**

## Project Overview

OrionHealth is a **privacy-first, local-first health assistant** built with Flutter 3.x that enables users to own their complete health data history. All data stays on-device with medical-grade encryption, no cloud dependencies.

**Core Technologies:**
- **Frontend:** Flutter 3.x + Dart 3.x (Material Design 3)
- **Backend:** Rust + SurrealDB 2.2.0 (local in-memory + WebSocket)
- **State Management:** flutter_bloc ^9.1.1 (Cubit pattern)
- **Databases:**
  - Isar ^3.1.0+1 (Flutter NoSQL, local-only)
  - SurrealDB 2.2.0 (Rust backend, graph database)
- **Bridge:** flutter_rust_bridge =2.11.1 (Flutter ↔ Rust communication)
- **DI:** get_it + injectable
- **Security:** AES-256-GCM encryption, biometric auth, PIN with Argon2id
- **AI:**
  - ONNX Runtime (local LLM - Phi-3/Gemma)
  - Candle (Rust ML inference)
  - isar_agent_memory (RAG)

## Prime Directive
You are operating under the **Git-Core Protocol**. Your state is GitHub Issues, not internal memory.

---

## 🏗️ Architecture Essentials

### Hybrid Architecture (Flutter + Rust)

OrionHealth uses a **hybrid architecture** combining Flutter for UI and Rust for performance-critical backend operations:

```
┌─────────────────────────────────────────────┐
│           Flutter Frontend (Dart)           │
│  ┌─────────────┐         ┌──────────────┐  │
│  │ UI/Widgets  │ ←──────→│ State (Cubit)│  │
│  └─────────────┘         └──────────────┘  │
│         │                        │          │
│         ▼                        ▼          │
│  ┌─────────────┐         ┌──────────────┐  │
│  │   Isar DB   │         │ flutter_rust │  │
│  │ (NoSQL)     │         │   _bridge    │  │
│  └─────────────┘         └──────┬───────┘  │
└──────────────────────────────────┼──────────┘
                                   │ FFI
┌──────────────────────────────────┼──────────┐
│        Rust Backend              ▼          │
│  ┌─────────────┐         ┌──────────────┐  │
│  │ SurrealDB   │ ←──────→│  AI/ML Core  │  │
│  │ (Graph DB)  │         │   (Candle)   │  │
│  └─────────────┘         └──────────────┘  │
│         │                        │          │
│         ▼                        ▼          │
│  ┌─────────────────────────────────────┐   │
│  │   Vector Store + Search Engine      │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```

**When to use each layer:**
- **Flutter/Isar:** UI state, user preferences, cached data
- **Rust/SurrealDB:** Complex queries, graph relationships, medical records, AI inference

### Clean Architecture (Hexagonal/Ports & Adapters)

**EVERY feature follows this structure:**
```
features/<feature_name>/
├── application/bloc/        # Cubit + State (sealed classes with equatable)
├── domain/
│   ├── entities/           # Isar entities (@collection)
│   └── repositories/       # Abstract repository interfaces
├── infrastructure/
│   ├── repositories/       # Repository implementations (Isar)
│   └── services/          # External services (HealthKit, BLE, encryption)
└── presentation/
    ├── pages/             # Full screen pages
    └── widgets/           # Feature-specific widgets
```

**Example: Auth Feature Flow**
```
AuthGate (presentation)
  → AuthCubit (application/bloc)
    → AuthRepository (domain)
      → AuthRepositoryImpl (infrastructure)
        → EncryptionService + BiometricService
```

### Critical Architectural Decisions

| Decision | Choice | Rationale | File |
|----------|--------|-----------|------|
| Architecture | Clean Architecture | Separation of concerns, testability | [.✨/ARCHITECTURE.md](../.✨/ARCHITECTURE.md#L17) |
| Backend | Rust + SurrealDB | Performance, type safety, graph queries | [rust/Cargo.toml](../rust/Cargo.toml) |
| Frontend DB | Isar | Fast, Flutter-native, schema-based | [pubspec.yaml](../pubspec.yaml#L47-L49) |
| Backend DB | SurrealDB (in-memory) | Graph relationships, ACID, SQL-like | [rust/src/database.rs](../rust/src/database.rs) |
| State Management | Cubit (flutter_bloc) | Simpler than BLoC, less boilerplate | [main.dart](../lib/main.dart#L24-L26) |
| Flutter↔Rust Bridge | flutter_rust_bridge | Type-safe FFI communication | [flutter_rust_bridge.yaml](../flutter_rust_bridge.yaml) |
| AI Inference | Candle (Rust) | Fast local LLM, ONNX support | [rust/src/llm/](../rust/src/llm/) |
| Auth Method | PIN + Biometric | Medical data requires strong auth | [.✨/ARCHITECTURE.md](../.✨/ARCHITECTURE.md#L26) |
| Data Sharing | BLE (flutter_blue_plus) | Direct device-to-device, no internet | [.✨/ARCHITECTURE.md](../.✨/ARCHITECTURE.md#L27) |
| Encryption | AES-256-GCM + Argon2id | Hospital-grade encryption | [.✨/ARCHITECTURE.md](../.✨/ARCHITECTURE.md#L28) |
| Theme | CyberTheme (cyberpunk UI) | Glassmorphic, neon accents | [cyber_theme.dart](../lib/core/theme/cyber_theme.dart) |

**⚠️ Architecture First Rule:** Before implementing ANY infrastructure feature, check `.✨/ARCHITECTURE.md` CRITICAL DECISIONS table. Architecture decisions override issue descriptions.

---

## 🔐 Security Architecture (Medical-Grade)

### Authentication Flow
```
App Start → AuthGate → [Has PIN?]
             ├── No  → SetupPinPage → Create PIN → Argon2id hash + salt
             └── Yes → LoginPage → [Biometric enabled?]
                                    ├── Yes → Biometric auth (local_auth)
                                    └── No  → Enter PIN → Verify hash
```

### Key Security Patterns

**1. PIN Storage (NEVER store plaintext):**
```dart
// ❌ WRONG: Storing PIN directly
final pin = "1234";

// ✅ RIGHT: Hash with Argon2id + random salt
final salt = await _encryptionService.generatePinSalt();
final pinHash = await _encryptionService.hashPin(pin, salt);
// Store: pinHash + salt in flutter_secure_storage
```

**2. Encryption at Rest:**
- Master key stored in platform secure storage (Keychain/Keystore)
- All medical data encrypted with AES-256-GCM before Isar storage
- Session keys rotated on auth

**3. Lockout Protection:**
```dart
// Progressive lockout: 1→5→15→30→60 minute delays
if (credentials.isCurrentlyLocked) {
  emit(AuthLocked(
    remainingMinutes: credentials.lockRemainingMinutes,
    failedAttempts: credentials.failedAttempts,
  ));
}
```

**4. BLE Medical Data Sharing:**
```
Patient Device                         Doctor Device
────────────────────────────────────────────────────
[Select Data] ─────────────────────────→ [Scan QR]
     │                                      │
     │        ← BLE Connection →            │
     │                                      │
  Encrypt with                         Receive +
  session key                          decrypt
     │                                      │
  Send chunks ────────────────────────→ Reassemble
```

**Files:**
- [auth_cubit.dart](../lib/features/auth/application/bloc/auth_cubit.dart) - Auth logic
- [encryption_service.dart](../lib/features/auth/infrastructure/services/encryption_service.dart)
- [biometric_service.dart](../lib/features/auth/infrastructure/services/biometric_service.dart)

---

## 🎨 UI/UX Patterns

### CyberTheme System

**Colors:**
```dart
primary: Color(0xFF00FF85)    // Neon green
secondary: Color(0xFF00E0FF)  // Cyan
backgroundDark: Color(0xFF0A0A0A)  // Almost black
surfaceDark: Color(0xFF1A1A1A)     // Dark gray
```

**Typography:** Google Fonts Space Grotesk (consistent cyberpunk aesthetic)

**Glassmorphic Effects:**
```dart
// Use for cards/overlays
Container(
  decoration: BoxDecoration(
    color: Colors.black.withOpacity(0.5),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: CyberTheme.primary.withOpacity(0.3)),
  ),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    child: content,
  ),
)
```

**Navigation:** Bottom nav with 4 tabs (Dashboard, Reports, Records, Profile)

---

## 🦀 Rust Backend (SurrealDB + AI)

### Project Structure

```
rust/
├── Cargo.toml                   # Dependencies (SurrealDB, Candle, etc.)
├── src/
│   ├── lib.rs                   # Public API exports
│   ├── api/                     # Flutter-exposed API (via flutter_rust_bridge)
│   ├── database.rs              # SurrealDB connection management
│   ├── vector_store.rs          # Embedding storage for RAG
│   ├── llm/                     # AI inference with Candle
│   ├── search.rs                # Medical record search
│   ├── health.rs                # Health data processing
│   ├── models.rs                # Data models
│   └── error.rs                 # Error types
└── examples/                    # Usage examples
```

### SurrealDB Patterns

**1. Initialize Database:**
```rust
use crate::database::DatabaseManager;

let db_manager = DatabaseManager::new();
db_manager.init().await?;  // Creates in-memory DB with namespace "orionhealth"
let db = db_manager.get_db().await?;
```

**2. Query Medical Records (SQL-like):**
```rust
// SurrealDB supports graph queries for relationships
let records: Vec<MedicalRecord> = db
    .query("SELECT * FROM medical_records WHERE patient_id = $id")
    .bind(("id", patient_id))
    .await?
    .take(0)?;
```

**3. Graph Relationships:**
```rust
// Query doctor-patient relationships with graph syntax
db.query(
    "SELECT * FROM doctor->treats->patient WHERE patient.id = $pid"
).bind(("pid", patient_id))
.await?;
```

**Files:**
- [database.rs](../rust/src/database.rs) - Connection management
- [Cargo.toml](../rust/Cargo.toml) - SurrealDB config

### Flutter ↔ Rust Communication

**1. Define Rust API (auto-generates Dart bindings):**
```rust
// In rust/src/api/mod.rs
#[flutter_rust_bridge::frb(sync)]
pub fn get_patient_records(patient_id: String) -> Result<Vec<MedicalRecord>> {
    // Implementation
}
```

**2. Regenerate Bridge (after Rust changes):**
```bash
flutter_rust_bridge_codegen --rust-input rust/src/api --dart-output lib/bridge
```

**3. Use from Flutter:**
```dart
import 'package:orionhealth_health/bridge/api.dart';

final records = await getPatientRecords(patientId: "123");
```

### AI/ML with Candle (Rust)

**Local LLM Inference:**
```rust
// In rust/src/llm/
use candle_core::{Device, Tensor};
use candle_transformers::models::llama;

pub async fn run_inference(prompt: String) -> Result<String> {
    // Load model from HuggingFace Hub
    // Run inference on device (CPU/GPU)
    // Return generated text
}
```

**Why Candle over ONNX?**
- Native Rust (no Python dependency)
- Better performance for transformers
- GPU support out of the box
- HuggingFace Hub integration

### Testing Rust Code

```bash
# Run all tests
cd rust && cargo test

# Run with output
cargo test -- --nocapture

# Run specific test
cargo test test_database_init

# Format code
cargo fmt

# Lint
cargo clippy -- -D warnings
```

---

## 🗃️ Database Patterns

### Isar (Flutter Local Storage)

**Use for:** UI state, user preferences, cached data, offline-first features

**Defining Entities (ALWAYS use @collection lowercase):**
```dart
import 'package:isar/isar.dart';

part 'medical_record.g.dart';  // Required for code generation

@collection
class MedicalRecord {
  Id id = Isar.autoIncrement;  // Auto-incrementing ID

  DateTime? date;

  @Enumerated(EnumType.name)  // Store as string, not index
  RecordType type;

  String? summary;

  List<MedicalAttachment> attachments;  // Embedded objects

  MedicalRecord({
    this.date,
    this.type = RecordType.other,
    this.summary,
    this.attachments = const [],
  });
}
```

### Repository Pattern

**Domain (interface):**
```dart
abstract class HealthRecordRepository {
  Future<List<MedicalRecord>> getAllRecords();
  Future<MedicalRecord?> getRecordById(int id);
  Future<void> saveRecord(MedicalRecord record);
}
```

**Infrastructure (implementation):**
```dart
@LazySingleton(as: HealthRecordRepository)
class HealthRecordRepositoryImpl implements HealthRecordRepository {
  final Isar _isar;

  HealthRecordRepositoryImpl(this._isar);

  @override
  Future<List<MedicalRecord>> getAllRecords() {
    return _isar.medicalRecords.where().findAll();
  }
}
```

**Regenerate after entity changes:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### SurrealDB (Rust Backend)

**Use for:** Complex queries, graph relationships, medical records with connections, AI/RAG

**Query Examples:**
```rust
// Simple query
let records: Vec<Record> = db
    .select("medical_records")
    .await?;

// With conditions
db.query("SELECT * FROM appointments WHERE date > $today")
    .bind(("today", chrono::Utc::now()))
    .await?;

// Graph traversal (doctor-patient relationships)
db.query("SELECT * FROM doctor->treats->patient WHERE patient.age > 65")
    .await?;
```

**Benefits over Isar:**
- Graph relationships (one query for complex connections)
- ACID transactions
- SQL-like syntax (easier migrations from SQL)
- Real-time subscriptions

---

## � State Management (Cubit Pattern)

### Cubit Structure

**State (sealed class with equatable):**
```dart
part of 'auth_cubit.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthRequired extends AuthState {
  final bool biometricAvailable;
  const AuthRequired({required this.biometricAvailable});

  @override
  List<Object?> get props => [biometricAvailable];
}
```

**Cubit:**
```dart
@injectable
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final hasSetup = await _authRepository.hasSetupAuth();
      if (!hasSetup) {
        emit(AuthSetupRequired());
      }
    } catch (e) {
      emit(AuthError('Error: $e'));
    }
  }
}
```

**Usage in Widget:**
```dart
BlocBuilder<AuthCubit, AuthState>(
  builder: (context, state) {
    return switch (state) {
      AuthLoading() => CircularProgressIndicator(),
      AuthRequired() => LoginPage(),
      AuthSetupRequired() => SetupPinPage(),
      _ => SizedBox.shrink(),
    };
  },
)
```

---

## 🧪 Testing & CI/CD

### Running Tests

```bash
# Flutter unit tests
flutter test

# Rust tests
cd rust && cargo test

# Integration tests
flutter test integration_test/

# All tests (Flutter + Rust)
flutter test && cd rust && cargo test && cd ..

# Dart analysis
flutter analyze

# Rust clippy
cd rust && cargo clippy -- -D warnings

# Format check (both)
dart format --set-exit-if-changed .
cd rust && cargo fmt --all -- --check
```

### CI/CD Workflows

**OrionHealth has 3 automated CI/CD workflows:**

#### 1. Main CI Pipeline ([ci-cd-main.yml](../.github/workflows/ci-cd-main.yml))
- **Triggers:** Every push/PR to main, develop, feat/*, fix/*
- **Jobs:**
  1. **Rust Tests** - Format, Clippy, Unit tests
  2. **Flutter Tests** - Analyze, Unit tests, Coverage, Bridge sync check
  3. **Integration Tests** - E2E tests (Rust ↔ Flutter), SurrealDB integration
  4. **Status Report** - Creates GitHub issues on failure
- **Auto-creates issues with:**
  - Complete error logs
  - Reproduction steps
  - Labels: `ai-agent`, `bug`, `priority-high`, `rust`/`flutter`/`integration`
  - Auto-assigns to Jules/Copilot

**Key Features:**
- ✅ **Bridge Sync Validation** - Detects when flutter_rust_bridge is out of sync
- ✅ **Integration Tests** - Tests Rust-Flutter communication end-to-end
- ✅ **SurrealDB Tests** - Dedicated database integration tests
- ✅ **Smart Issue Creation** - Different templates for Rust/Flutter/Integration failures

#### 2. Continuous Improvement ([continuous-improvement.yml](../.github/workflows/continuous-improvement.yml))
- **Triggers:** Daily at 6 AM UTC + manual
- **Analyzes:**
  - Code complexity (Rust + Dart)
  - Security (hardcoded secrets)
  - Test coverage
  - Missing documentation
  - Performance issues
- **Creates improvement issues** with `ai-agent` label

#### 3. Auto Deploy ([auto-deploy.yml](../.github/workflows/auto-deploy.yml))
- **Triggers:** Push to main with changes in `docs/`
- **Actions:** Builds and deploys documentation to GitHub Pages
- **On failure:** Creates issue assigned to Jules

### When Tests Fail in CI

**Automatic workflow:**
1. CI detects failure (Rust or Flutter)
2. Captures full error logs
3. Creates GitHub issue with:
   - Error details
   - Reproduction command
   - Link to workflow run
   - Labels for routing
4. Agent dispatcher assigns to best-fit agent
5. Agent fixes issue → Creates PR
6. Human reviews and merges

**Manual intervention only needed for:**
- High-stakes changes (security, data model)
- Breaking API changes
- Major architectural decisions

### Local Testing Before Push

**Automated approach (recommended):**

```powershell
# Windows
.\scripts\pre-push-check.ps1

# Linux/macOS
./scripts/pre-push-check.sh
```

**These scripts run:**
1. ✅ Flutter analyze
2. ✅ Rust format check (`cargo fmt --check`)
3. ✅ Rust clippy (`-D warnings`)
4. ✅ Rust tests
5. ✅ Bridge sync validation
6. ✅ Flutter tests
7. ✅ Integration tests (if they exist)

**Manual approach:**

```bash
# Run this before every commit (includes bridge check)
flutter analyze && \
flutter test && \
cd rust && cargo fmt && cargo clippy && cargo test && cd .. && \
flutter_rust_bridge_codegen --rust-input rust/src/api --dart-output lib/bridge && \
git diff --exit-code lib/bridge/ && \
flutter test integration_test/
```

**Pre-push checklist:**
- [ ] Flutter tests pass
- [ ] Rust tests pass
- [ ] Bridge is in sync (`flutter_rust_bridge_codegen`)
- [ ] Integration tests pass
- [ ] Code is formatted (Dart + Rust)
- [ ] No clippy warnings

**Pro tip:** Set up Git hook:
```bash
# .git/hooks/pre-push
#!/bin/bash
./scripts/pre-push-check.sh
```

**Full documentation:** [DEPLOY_CICD_README.md](../DEPLOY_CICD_README.md) | [docs/CICD_SYSTEM_GUIDE.md](../docs/CICD_SYSTEM_GUIDE.md)

---

## 🔧 Development Workflows

### Starting a New Feature

```bash
# 1. Read architecture
cat .✨/ARCHITECTURE.md

# 2. Check assigned issues
gh issue list --assignee "@me"

# 3. Take an issue
gh issue edit <id> --add-assignee "@me"

# 4. Create branch
git checkout -b feat/issue-<id>-description

# 5. Implement following Clean Architecture
# For Flutter: lib/features/<feature>/
# For Rust: rust/src/<module>/

# 6. Run tests (both languages)
flutter test && cd rust && cargo test && cd ..

# 7. Commit atomically (ONE logical change per commit)
git add lib/features/auth/application/bloc/
git commit -m "feat(auth): add biometric authentication (closes #<id>)"

# 8. Create PR
gh pr create --fill
```

### Working with Rust + Flutter Together

**Scenario: Add new medical record search with AI**

1. **Define Rust API:**
```rust
// rust/src/api/search.rs
#[flutter_rust_bridge::frb(sync)]
pub fn search_records_with_ai(
    query: String,
    use_embeddings: bool
) -> Result<Vec<SearchResult>> {
    // Implementation with SurrealDB + Candle
}
```

2. **Regenerate bridge:**
```bash
flutter_rust_bridge_codegen \
  --rust-input rust/src/api \
  --dart-output lib/bridge
```

3. **Use in Flutter:**
```dart
// lib/features/search/infrastructure/search_repository_impl.dart
@override
Future<List<SearchResult>> searchWithAI(String query) async {
  return await searchRecordsWithAi(
    query: query,
    useEmbeddings: true,
  );
}
```

4. **Test both sides:**
```bash
# Rust unit test
cd rust && cargo test search_records_with_ai

# Flutter integration test
flutter test integration_test/search_test.dart
```

### Dependency Injection Setup

**Registering a new service:**
```dart
// 1. Add @injectable annotation
@injectable
class NewService {
  final SomeDependency _dep;
  NewService(this._dep);
}

// 2. Regenerate DI
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Use in code
final service = getIt<NewService>();
```

**Module for singletons (like Isar):**
```dart
@module
abstract class DatabaseModule {
  @lazySingleton
  Future<Isar> get isar => _initIsar();

  Future<Isar> _initIsar() async {
    final dir = await getApplicationDocumentsDirectory();
    return Isar.open([/* schemas */], directory: dir.path);
  }
}
```

### Dependency Injection Setup

**Registering a new service:**
```dart
// 1. Add @injectable annotation
@injectable
class NewService {
  final SomeDependency _dep;
  NewService(this._dep);
}

// 2. Regenerate DI
flutter pub run build_runner build --delete-conflicting-outputs

// 3. Use in code
final service = getIt<NewService>();
```

**Module for singletons (like Isar):**
```dart
@module
abstract class DatabaseModule {
  @lazySingleton
  Future<Isar> get isar => _initIsar();

  Future<Isar> _initIsar() async {
    final dir = await getApplicationDocumentsDirectory();
    return Isar.open([/* schemas */], directory: dir.path);
  }
}
```

### Adding Health Metrics (HealthKit/Health Connect)

```dart
import 'package:health/health.dart';

// 1. Configure permissions in domain
final types = [
  HealthDataType.STEPS,
  HealthDataType.HEART_RATE,
  HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
];

// 2. Request authorization
final health = Health();
await health.requestAuthorization(types);

// 3. Fetch data
final now = DateTime.now();
final data = await health.getHealthDataFromTypes(
  startTime: now.subtract(Duration(days: 7)),
  endTime: now,
  types: types,
);

// 4. Store in Isar (encrypt sensitive data)
```

---

## 🚫 Forbidden Actions (Git-Core Protocol)

**NEVER create these files:**
- ❌ `TODO.md`, `TASKS.md`, `BACKLOG.md`, `PLANNING.md`, `ROADMAP.md`
- ❌ `NOTES.md`, `PROGRESS.md`, `STATUS.md`, `CHECKLIST.md`
- ❌ `TESTING_CHECKLIST.md`, `IMPLEMENTATION_SUMMARY.md`
- ❌ `GETTING_STARTED.md`, `GUIDE.md`, `TUTORIAL.md`, `QUICKSTART.md`
- ❌ ANY `.md` for task/state tracking

**✅ ONLY allowed `.md` files:**
- ✅ `README.md` (project overview ONLY)
- ✅ `AGENTS.md` (agent configuration ONLY)
- ✅ `.✨/ARCHITECTURE.md` (system architecture ONLY)
- ✅ `CONTRIBUTING.md`, `LICENSE.md` (standard repo files)

**Why?** GitHub Issues are the single source of truth for task management. Creating tracking files wastes tokens and creates synchronization issues.

**Instead of creating files:**
```bash
# Create an issue
gh issue create --title "TASK: Add OAuth integration" --body "Details..." --label "ai-plan"

# Add comment for progress
gh issue comment <id> --body "Completed authentication, working on token refresh"
```

---

## 📚 Key Files Reference

| File | Purpose | When to Read |
|------|---------|--------------|
| [.✨/ARCHITECTURE.md](../.✨/ARCHITECTURE.md) | Critical decisions, stack, security | Before ANY infrastructure change |
| [AGENTS.md](../AGENTS.md) | Git-Core Protocol, agent workflows | Understanding automation |
| [pubspec.yaml](../pubspec.yaml) | Dependencies, version constraints | Adding packages |
| [main.dart](../lib/main.dart) | App entry point, DI initialization | Understanding app startup |
| [cyber_theme.dart](../lib/core/theme/cyber_theme.dart) | Theme colors, typography | UI development |
| [injection.dart](../lib/core/di/injection.dart) | DI configuration | Dependency management |
| [DEPLOY_CICD_README.md](../DEPLOY_CICD_README.md) | CI/CD system guide | Understanding automation |

---

## 🎯 Common Tasks Quick Reference

**Add new feature:**
1. Create feature folder: `lib/features/<feature>/`
2. Follow Clean Architecture structure (domain → application → infrastructure → presentation)
3. Register in DI with `@injectable`
4. Add route to navigation
5. Write tests

**Add new Isar entity:**
1. Create in `domain/entities/` with `@collection`
2. Add `part` directive
3. Run `build_runner`
4. Add to Isar schemas in `DatabaseModule`

**Integrate new health sensor:**
1. Add to `health` package types
2. Request permissions in `AuthCubit`
3. Create repository in `features/vitals/`
4. Display in dashboard

**Add BLE feature:**
1. Use `flutter_blue_plus`
2. Encrypt data with `EncryptionService`
3. Handle permissions (Android/iOS)
4. Test on real devices (BLE requires hardware)

---

## 🤖 Agent Delegation

**For complex tasks, delegate to specialized agents:**

```bash
# Jules (best for autonomous implementation)
gh issue edit <id> --add-label "jules"

# Generic AI agent (auto-dispatch)
gh issue edit <id> --add-label "ai-agent"

# CodeRabbit (auto-reviews PRs)
# Automatically triggered on PR creation

# Gemini (large context analysis)
gemini analyze <file>
```

**Issue format for Jules (REQUIRED for best results):**
- 🎯 Objective (clear goal)
- 📁 Files to Modify (exact paths)
- Code Snippets (example implementation)
- ✅ Acceptance Criteria (testable)
- 🧪 Testing Commands (`flutter test`)

---

## 🚀 Quick Start Checklist

New to this codebase? Read these in order:

1. [ ] [README.md](../README.md) - Project vision, features
2. [ ] [.✨/ARCHITECTURE.md](../.✨/ARCHITECTURE.md) - Technical decisions
3. [ ] [AGENTS.md](../AGENTS.md) - Workflow automation
4. [ ] [lib/main.dart](../lib/main.dart) - App entry point
5. [ ] [lib/features/auth/](../lib/features/auth/) - Example Clean Architecture
6. [ ] This file - Copilot instructions

**Then run:**
```bash
flutter pub get
flutter pub run build_runner build
flutter test
flutter run
```

---

## 🔧 Troubleshooting

### Bridge Out of Sync Error

**Symptom:** CI fails with "flutter_rust_bridge generated code is out of sync"

**Cause:** Rust API changed but bridge wasn't regenerated

**Fix:**
```bash
# Regenerate bridge
flutter_rust_bridge_codegen \
  --rust-input rust/src/api \
  --dart-output lib/bridge \
  --dart-format-line-length 80

# Verify no changes needed
git diff lib/bridge/

# If changes exist, commit them
git add lib/bridge/
git commit -m "chore(bridge): regenerate flutter_rust_bridge"
```

### Integration Tests Failing in CI

**Symptom:** Integration tests pass locally but fail in CI

**Common causes:**
1. **Database state pollution:** Integration tests must run with `--test-threads=1`
2. **Missing SurrealDB setup:** Check rust tests initialize DB properly
3. **Bridge not in sync:** Run bridge check (see above)

**Debug steps:**
```bash
# 1. Check bridge sync
flutter_rust_bridge_codegen --rust-input rust/src/api --dart-output lib/bridge
git diff lib/bridge/

# 2. Run integration tests with verbose output
flutter test integration_test/ -v

# 3. Check Rust integration tests
cd rust && cargo test --test database_integration -- --nocapture

# 4. Verify SurrealDB is accessible
cd rust && cargo test --test "*_integration" --features test-integration
```

### Rust Clippy Warnings

**Symptom:** CI fails on `cargo clippy` but code compiles

**Fix:**
```bash
# See all warnings
cd rust && cargo clippy --all-targets --all-features

# Auto-fix common issues
cd rust && cargo clippy --fix --all-targets --all-features

# If unfixable, add allow attribute (use sparingly)
#[allow(clippy::too_many_arguments)]
fn complex_function(...) { }
```

### SurrealDB Connection Issues

**Symptom:** Tests fail with "Database connection error"

**Common causes:**
1. In-memory DB not initialized
2. Namespace/database not set
3. Test running in parallel (use `--test-threads=1`)

**Fix:**
```rust
// Ensure proper initialization
let db = Surreal::new::<Mem>(()).await?;
db.use_ns("orionhealth").use_db("medical").await?;

// In tests, use single-threaded execution
#[cfg(test)]
mod tests {
    // Run with: cargo test -- --test-threads=1
}
```

---

**Last Updated:** 2026-01-06
**Protocol Version:** 3.2.1

---

## 📋 Git-Core Protocol Summary

This project follows the **Git-Core Protocol** for AI-assisted development. Key principles:

- **State Management:** GitHub Issues are the single source of truth (not internal memory/files)
- **Task Tracking:** Use `gh issue` commands, never create TODO.md or similar tracking files
- **Atomic Commits:** ONE logical change per commit, following Conventional Commits
- **Architecture First:** Check [.✨/ARCHITECTURE.md](../.✨/ARCHITECTURE.md) before implementing infrastructure features

**For complete protocol details, workflows, and agent delegation patterns:** See [AGENTS.md](../AGENTS.md)

### Quick Workflow

```bash
# 1. Check architecture + assigned issues
cat .✨/ARCHITECTURE.md
gh issue list --assignee "@me"

# 2. Take issue + create branch
gh issue edit <id> --add-assignee "@me"
git checkout -b feat/issue-<id>-description

# 3. Implement + test
flutter test

# 4. Commit atomically
git commit -m "feat(auth): add biometric auth (closes #<id>)"

# 5. Create PR
gh pr create --fill
```

### Health Check Before New Features

```bash
# Run tests first (if broken, fix before adding features)
flutter test
flutter analyze
```

### Agent Delegation

```bash
# Delegate to Jules (best for autonomous implementation)
gh issue edit <id> --add-label "jules"

# Generic AI agent (auto-dispatch)
gh issue edit <id> --add-label "ai-agent"
```

**Full protocol documentation:** [AGENTS.md](../AGENTS.md) | **CI/CD details:** [DEPLOY_CICD_README.md](../DEPLOY_CICD_README.md)



