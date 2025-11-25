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

1. **Framework:** Flutter (Latest Stable)
2. **State Management:** `flutter_bloc`
3. **Dependency Injection:** `get_it` + `injectable`
4. **Database & Vector Store:** `isar` (NoSQL + Embeddings)
5. **AI Inference:** `onnxruntime` (via FFI) or `mediapipe_genai`
6. **Health Data:** `health` package
7. **UI Design:** Material Design 3

## Constraints & Principles

* **Local Privacy:** User data never leaves the device unencrypted.
* **Offline First:** The app must function fully without internet access (except for model updates).
* **Modular AI:** The AI model should be swappable without affecting the UI.

## Parallel Execution Strategy (Sprints)

To accelerate development and minimize git conflicts, we have divided the work into 3 isolated tracks.

### Track A: Core & User Profile

* **Scope:** `lib/core`, `lib/features/user_profile`, `lib/main.dart`.
* **Responsibility:** Architecture setup, DI, Global DB, User Profile Feature.

### Track B: Data Ingestion (Health Record)

* **Scope:** `lib/features/health_record`.
* **Responsibility:** File/Image Pickers, OCR Staging, Medical Record Entities.
* **Constraint:** Must not modify `main.dart`.

### Track C: Local AI (Agent)

* **Scope:** `lib/features/local_agent`.
* **Responsibility:** Chat UI, LLM Service Interface, RAG Logic.
* **Constraint:** Must not modify `main.dart`.

## Development Phases

1. **Foundation & User Profile:** Hexagonal structure, Isar setup, User Profile data model & UI.
2. **Data Ingestion & Curation (Critical):** "Staging Area" for documents, OCR/Text Extraction, Validation UI, Persistence to Medical History.
3. **Local Intelligence (Chat & RAG):** LLM Inference Service, Model Management, Embeddings generation, Vector Search, Chat UI.
4. **Insights & Reporting:** Statistical Dashboards, Weekly AI Summaries, Health Plans, Report Export.
5. **Interoperability:** App Intents (Siri/Gemini), Notifications.
