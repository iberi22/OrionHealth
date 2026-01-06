# 🏗️ OrionHealth Architecture

## Stack
- **Language:** Dart 3.x
- **Framework:** Flutter 3.x
- **State Management:** flutter_bloc ^9.1.1 (Cubit pattern)
- **DI:** get_it ^9.1.0 + injectable ^2.6.0
- **Database:** Isar ^3.1.0+1 (local NoSQL)
- **Authentication:** local_auth ^2.3.0 (biometrics) + flutter_secure_storage ^9.2.4
- **Encryption:** cryptography ^2.7.0 (AES-256-GCM, Argon2id)
- **Bluetooth:** flutter_blue_plus ^1.35.2 (BLE data sharing)
- **AI Agent:** isar_agent_memory (local LLM memory)

## CRITICAL DECISIONS

| Decision | Choice | Rationale | Date |
|----------|--------|-----------|------|
| Architecture | Clean Architecture | Separation of concerns, testability | 2025-11 |
| State Management | Cubit (flutter_bloc) | Simpler than BLoC, less boilerplate | 2025-11 |
| Local DB | Isar | Fast, Flutter-native, schema-based | 2025-11 |
| Auth Method | PIN + Biometric | Medical data requires strong auth | 2025-12 |
| Data Sharing | BLE | Direct device-to-device, no internet needed | 2025-12 |
| Encryption | AES-256-GCM | Hospital-grade encryption for medical data | 2025-12 |

## Project Structure
```
lib/
├── main.dart                    # Entry point + AuthGate
├── core/
│   ├── di/                      # Dependency injection (injectable)
│   │   ├── injection.dart
│   │   ├── injection.config.dart
│   │   └── database_module.dart
│   ├── theme/                   # CyberTheme dark theme
│   └── widgets/                 # Shared widgets
├── features/
│   ├── auth/                    # 🔐 Authentication & Security
│   │   ├── application/bloc/    # AuthCubit + states
│   │   ├── domain/
│   │   │   ├── entities/        # AuthCredentials
│   │   │   └── repositories/    # AuthRepository
│   │   ├── infrastructure/
│   │   │   ├── repositories/    # AuthRepositoryImpl
│   │   │   └── services/        # Encryption, Biometric, BLE
│   │   └── presentation/        # Login, SetupPin, Share, Receive
│   ├── dashboard/               # 🏠 Home dashboard
│   ├── user_profile/            # 👤 User profile management
│   ├── allergies/               # ⚠️ Allergy tracking
│   ├── medications/             # 💊 Medication management
│   ├── vitals/                  # ❤️ Vital signs tracking
│   ├── appointments/            # 📅 Medical appointments
│   ├── health_record/           # 📁 Medical records
│   ├── health_report/           # 📊 Health reports
│   └── local_agent/             # 🤖 AI chat agent
```

## Feature Module Structure (Clean Architecture)
```
feature/
├── application/
│   └── bloc/                    # Cubit + State (sealed classes)
├── domain/
│   ├── entities/                # Isar entities (@collection)
│   └── repositories/            # Abstract repository interfaces
├── infrastructure/
│   ├── repositories/            # Repository implementations
│   └── services/                # External services
└── presentation/
    ├── pages/                   # Full screen pages
    └── widgets/                 # Feature-specific widgets
```

## Security Architecture

### Authentication Flow
```
App Start → AuthGate → [Has PIN?]
                         ├── No  → SetupPinPage → Create PIN → Save hash
                         └── Yes → LoginPage → [Biometric?]
                                                ├── Yes → Authenticate
                                                └── No  → Enter PIN → Verify hash
```

### Data Encryption
- **At Rest:** Master key in platform secure storage (Keychain/Keystore)
- **PIN Storage:** Argon2id hash + random salt (timing-attack resistant)
- **BLE Transfer:** Session key exchange + AES-256-GCM encryption

### Lockout Protection
- Failed attempts: 1→5→15→30→60 minute progressive lockout
- Session timeout: Configurable (default 5 min inactivity)

## Data Flow (BLE Medical Sharing)
```
Patient Device                         Doctor Device
─────────────────────────────────────────────────────
[Select Data] ─────────────────────────→ [Scan]
     │                                      │
     │        ← BLE Connection →            │
     │                                      │
[Generate Session Key] ──────────────→ [Receive Key]
     │                                      │
[Encrypt Data (AES-256-GCM)] ────────→ [Decrypt Data]
     │                                      │
[Send Chunks with Progress] ─────────→ [Display Data]
```

## Database Schema (Isar Collections)
- `UserProfile` - Personal info, blood type, emergency contact
- `AuthCredentials` - PIN hash, salt, biometric settings, lockout
- `Allergy` - Name, severity, reaction, critical flag
- `Medication` - Name, dosage, frequency, status
- `VitalSign` - Type, value, unit, recorded timestamp
- `Appointment` - Doctor, specialty, datetime, status
- `MedicalRecord` - Records from doctor visits
- `HealthReport` - Generated health reports
- `ChatMessage` - Local AI agent conversation history
- `MemoryNode/Edge` - AI agent memory graph
