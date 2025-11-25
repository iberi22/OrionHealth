# PLANNING.md

## Vision
**OrionHealth** is a privacy-first, local-first health assistant application built with Flutter. It aims to provide a secure "Digital Health Sheet" that integrates with local sensors (Apple HealthKit, Google Health Connect) and uses on-device AI (Phi-3 Mini / Gemma 2B via ONNX) to provide health insights without compromising user privacy.

## Architecture
We follow **Hexagonal Architecture (Ports & Adapters)** to decouple the core domain logic from external tools (UI, Database, AI Models).

### Directory Structure
```text
lib/
├── core/                   # Utilities, Config, Errors, Base UseCases
├── features/
│   ├── health_record/      # Feature: Medical History
│   │   ├── domain/         # Entities & Repositories (Interfaces)
│   │   ├── application/    # Use Cases (AddRecord, AnalyzeTrends)
│   │   ├── infrastructure/ # Implementation (Isar, HealthKit API)
│   │   └── presentation/   # BLoC & UI (Material 3)
│   │
│   ├── local_agent/        # Feature: AI Chat
│   │   ├── domain/         # Entities (Message, AgentAction)
│   │   ├── application/    # Use Cases (SendMessage, RetrieveContext)
│   │   ├── infrastructure/ # Implementation (FoundryService, OnnxService)
│   │   └── presentation/   # Chat UI
│   │
│   └── app_intents/        # Feature: Siri/Gemini Connection
└── main.dart
```

## Tech Stack
1.  **Framework:** Flutter (Latest Stable)
2.  **State Management:** `flutter_bloc`
3.  **Dependency Injection:** `get_it` + `injectable`
4.  **Database & Vector Store:** `isar` (NoSQL + Embeddings)
5.  **AI Inference:** `onnxruntime` (via FFI) or `mediapipe_genai`
6.  **Health Data:** `health` package
7.  **UI Design:** Material Design 3

## Constraints & Principles
*   **Local Privacy:** User data never leaves the device unencrypted.
*   **Offline First:** The app must function fully without internet access (except for model updates).
*   **Modular AI:** The AI model should be swappable without affecting the UI.

## Development Phases
1.  **Data Core:** Isar setup, Health integration, Encryption.
2.  **Local Brain:** Model selection (Phi-3), Infrastructure Adapter, Memory (isar_agent_memory).
3.  **Local RAG:** Embeddings generation, Semantic Search.
4.  **UI/UX:** Material 3 implementation.
5.  **Interoperability:** App Intents (Siri/Gemini).
