# PLANNING.md

## Vision

**OrionHealth** is a privacy-first, local-first health assistant application built with Flutter. It empowers individuals to own and control their complete health data history, creating a secure "Digital Health Sheet" that integrates with local sensors (Apple HealthKit, Google Health Connect) and uses on-device AI (Phi-3 Mini / Gemma 2B via ONNX) to provide health insights without compromising user privacy.

### The Greater Mission: Democratizing Personalized Medicine

OrionHealth's ultimate goal extends beyond personal health management. By enabling users to collect, structure, and own their comprehensive health data, we're building the foundation for a paradigm shift in medicine:

**Today's Challenge:**
- Health data is fragmented across hospitals, clinics, and wearables
- Medical treatment follows "one-size-fits-all" protocols
- Patients lack access to their complete health history
- Clinical research relies on limited, incomplete datasets

**Tomorrow's Vision:**
- **Individual Empowerment**: Users own their complete, structured health timeline
- **Advanced AI Analysis**: Next-generation LLMs (far more powerful than today's models) can analyze entire health histories to identify patterns invisible to human physicians
- **Personalized Treatment**: Drug recommendations, dosages, and therapies tailored to individual genetic profiles, medical histories, and lifestyle factors
- **Accelerated Drug Discovery**: Aggregated, anonymized health data enables faster identification of drug candidates and side effect patterns
- **Predictive Medicine**: AI models predict disease onset years in advance, enabling preventive interventions
- **Efficient Clinical Trials**: Patients matched with relevant studies automatically; trials complete faster with better participant selection

**Ethical Framework:**
1. **Privacy First**: User data never leaves the device unencrypted without explicit consent
2. **User Control**: Individuals decide if/when to donate anonymized data for research
3. **Non-Commercial**: Open-source AGPL-3.0 license prevents privatization of health data tools
4. **Interoperability**: Standardized data formats enable future ecosystem integration
5. **Transparency**: All AI models and algorithms open for audit

### Phases of Impact

**Phase 1 (Current - Individual Collection):**
- Users centralize personal health records in OrionHealth
- Local AI provides basic insights and trend analysis
- Complete portability of health data

**Phase 2 (Near Future - Federated Learning):**
- Optional anonymized data contribution to research networks
- Privacy-preserving federated learning across user datasets
- Community-driven AI model improvements

**Phase 3 (Mid-Term - Clinical Integration):**
- Integration with electronic health record (EHR) systems
- Physician collaboration tools (share selected data with doctors)
- Real-time drug interaction warnings

**Phase 4 (Long-Term - Personalized Medicine):**
- Advanced LLMs trained on massive health datasets generate personalized treatment plans
- Genetic profile + medical history + real-time sensor data → precision medicine
- Automated discovery of novel treatment combinations
- Predictive health scores prevent diseases before symptoms appear

**Phase 5 (Ultimate Goal - Democratized Healthcare):**
- Open-source medical AI accessible to underserved communities
- Reduction in healthcare costs through preventive medicine
- Global health data network accelerates pandemic response
- Personalized medicine becomes standard of care worldwide

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
│   ├── user_profile/       # Feature: User Settings & Preferences
│   └── health_report/      # Feature: Analytics & Export
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
* **Data Portability:** Users can export their entire dataset in standard formats (JSON, FHIR).
* **Non-Commercial Guarantee:** AGPL-3.0 license ensures the project remains free and open forever.

## Future Data Standards for Medical AI

To maximize compatibility with future AI research platforms, OrionHealth structures health data using:

- **FHIR (Fast Healthcare Interoperability Resources):** Industry-standard medical data format
- **OMOP (Observational Medical Outcomes Partnership):** Common data model for research
- **Timestamped Vector Embeddings:** Efficient semantic search over health history
- **Structured Metadata:** Categorization by type, severity, body system, provider

This future-proofing ensures that when advanced LLMs become capable of medical reasoning, OrionHealth users will have "AI-ready" health histories.

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
5. **Interoperability:** App Intents (Siri/Gemini), Notifications, FHIR Export.

## Licensing Philosophy

**Why AGPL-3.0?**

We chose the GNU Affero General Public License v3.0 specifically to prevent commercialization of health data tools:

1. **Copyleft Protection:** Any derivative work must also be open source
2. **Network Service Protection:** Even if someone runs OrionHealth as a web service, they must release the source code
3. **Community-Driven Development:** All improvements benefit everyone
4. **Anti-Monopoly:** Prevents tech companies from privatizing health data infrastructure

**What You Can Do:**
- ✅ Use OrionHealth for personal health management
- ✅ Fork and modify for your own needs
- ✅ Contribute improvements back to the project
- ✅ Use in academic/research settings
- ✅ Deploy in non-profit healthcare organizations

**What You Cannot Do:**
- ❌ Sell OrionHealth or charge users for access
- ❌ Create proprietary versions with closed-source features
- ❌ Use OrionHealth code in commercial health apps without releasing your code under AGPL-3.0
- ❌ Offer OrionHealth as a paid SaaS without open-sourcing the entire platform

This ensures that health data ownership tools remain public goods forever.
