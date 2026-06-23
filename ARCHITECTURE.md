# OrionHealth — Architecture Guide

OrionHealth is a privacy-first personal health assistant built with Flutter, following a strict Clean Architecture pattern and local-first principles.

## 🏗️ Clean Architecture (4 Layers)

The project is organized into modular features, each following four distinct layers to ensure separation of concerns and testability:

1.  **Domain Layer**: The core of the system. Contains Entities, Use Cases, and Repository Interfaces. It is independent of any other layer and contains the business logic.
2.  **Application Layer**: Contains BLoCs/Cubits and application-specific logic. It coordinates between the UI and the Domain layer.
3.  **Infrastructure Layer**: Implements Repository Interfaces. Handles data sources (local DB, external APIs), services (ASR, TTS), and infrastructure details like network or file system.
4.  **Presentation Layer**: Contains the UI widgets, pages, and animations. It interacts solely with the Application layer (Cubits/BLoCs) to display state.

### Directory Structure
```
lib/features/<feature_name>/
├── domain/           # Entities, Repositories, UseCases
├── application/      # BLoCs, Cubits
├── infrastructure/   # Repository Impl, Data Sources, Mappers
└── presentation/     # Widgets, Pages
```

## 🧠 State Management

OrionHealth uses **Flutter BLoC/Cubit** for predictable state management.
- **Cubits** are used for simple state transitions.
- **BLoCs** are used for more complex event-based state management.
- All UI components listen to state changes and rebuild reactively.

## 🔄 Data Flow

The application follows an **Offline-first** data flow:
1.  **Local Persistence**: Data is primarily stored and retrieved from **Isar DB** (local).
2.  **State Management**: The **BLoC/Cubit** layer fetches data from the local repository.
3.  **Reactive UI**: The UI subscribes to the BLoC/Cubit state and updates when the local data changes.
4.  **Sync**: Synchronization with external nodes or servers happens in the background via the Infrastructure layer.

```text
Local Storage (Isar DB) <---> Repository (Infra) <---> BLoC/Cubit (Application) <---> UI (Presentation)
```

## 🔒 Offline-first & Privacy

- **On-Device AI**: Uses local models for ASR (Speech-to-Text), TTS (Text-to-Speech), and LLM-based assistants.
- **Local Database**: All health data stays on the device by default, encrypted using **Isar**.
- **Secure Storage**: Sensitive keys and identifiers are stored in the system's secure enclave (Keychain/Keystore) via `flutter_secure_storage`.

## 📡 P2P Synchronization

OrionHealth supports distributed data sharing and synchronization:
- **Wi-Fi Direct / mDNS**: Local discovery of other OrionHealth nodes.
- **IPFS**: Decentralized storage for health records and blobs, ensuring availability without central servers.
- **SSI (Self-Sovereign Identity)**: Uses DIDs and Verifiable Credentials for secure data exchange.

## 🏥 Medical Standards Integration

To ensure interoperability and accuracy, OrionHealth integrates several international medical standards:
- **FHIR (R4/DSTU2)**: The primary data model for health resources.
- **ICD-10**: For clinical diagnoses and classification.
- **LOINC**: For laboratory and clinical observations.
- **RxNorm**: For standardized medication nomenclature.
- **SNOMED CT**: For clinical terminology and medical concepts.

## 🚀 Build System & CI

- **GitHub Actions**: Automated CI pipeline for every push and PR.
- **Static Analysis**: Enforced `dart analyze` for code quality.
- **Testing Suite**:
    - **Unit Tests**: Domain and Application logic.
    - **Widget Tests**: Presentation layer components.
    - **Golden Tests**: Visual regression testing using screenshots.
    - **Integration Tests**: End-to-end flows.

## 🔗 References

- [Features Catalog](features.json)
- [Git Protocol](GITPROTOCOL.md)
