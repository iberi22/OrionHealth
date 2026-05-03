# Architecture — OrionHealth

## Tech Stack
- **Flutter** ^3.7.0 (Dart 3.x)
- **GetIt** 9.1.0 (DI)
- **IsarDB** (local vector + graph storage via isar_agent_memory)
- **ObjectBox** (medical standards data)
- **BLoC** pattern (state management)
- **MethodChannel** (native AICore/Gemma bridge)

## Package Architecture
```
lib/
├── core/               # DI, services, theme, shared utilities
│   ├── di/             # GetIt injection (injection.dart)
│   ├── services/       # AicoreService, DeviceCapability, Privacy
│   └── theme/          # CyberTheme (dark)
├── features/           # Feature modules (by domain)
│   ├── auth/           # Identity + medical identity
│   ├── health_sharing/ # BLE + NFC + WiFi Direct
│   ├── local_agent/    # RAG pipeline + LLM adapters
│   ├── health_wallet/  # Offline health records
│   └── ...             # Each feature is self-contained
packages/
├── isar_agent_memory/  # Graph + Vector DB (Isar) — v0.5.0-beta
├── health_wallet/      # Offline health record models
└── medical_standards/  # ICD-10, LOINC, RxNorm, SNOMED CT
android/
└── app/src/main/kotlin/
    └── MainActivity.kt + AicorePlugin.kt (new)
```

## Data Flow (RAG Query)
```
User Input → GemmaLlmAdapter (MethodChannel)
                  ↓
           AicoreService (Dart) → AicorePlugin (Kotlin)
                  ↓
           RagLlmService → MemoryGraph (Isar) → Hybrid Search
                  ↓
           MedicalStandards (ObjectBox)
                  ↓
           Response → UI
```

## Key Design Decisions
1. **Local-first**: All data stored on-device (Isar + ObjectBox)
2. **Privacy-centric**: Medical data never leaves the device
3. **RAG with MemoryGraph**: Vector + knowledge graph + BM25 hybrid search
4. **Plugin architecture**: AICore as Flutter plugin, not embedded in main activity
5. **BLoC pattern**: Each feature has its own Cubit for state
