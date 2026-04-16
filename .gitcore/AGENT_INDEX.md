# Git-Core Agent Index v1.3.0

## 🧭 Repository Overview
OrionHealth is a privacy-first, local-first health assistant.

## 🏗️ Architectural Patterns
- **Hexagonal Architecture**: Separation of concerns via domain, application, infrastructure, and presentation layers.
- **BLoC Pattern**: State management for all features.
- **Local-First**: Isar database for persistence, on-device LLM for intelligence.

## 📂 Key Feature Directories
- `lib/features/auth/`: Security, encryption, and data sharing.
- `lib/features/health_record/`: Medical record management.
- `lib/features/local_agent/`: AI Assistant and RAG implementation.
- `lib/features/user_profile/`: User identity and preferences.
- `lib/features/appointments/`: Scheduling and management.
- `lib/features/medications/`: Medication tracking.
- `lib/features/vitals/`: Health metrics tracking.
- `lib/features/allergies/`: Allergy documentation.

## 🛠️ Tooling & Standards
- **Build Runner**: `dart run build_runner build --delete-conflicting-outputs`
- **Analysis**: `flutter analyze`
- **Testing**: `flutter test`

## 🤖 Agent Onboarding
Agents should prioritize `TASK.md` for current sprint details and `PLANNING.md` for long-term vision.
Always follow the Hexagonal Architecture and minimize dependencies between features.
