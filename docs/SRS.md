# Software Requirements Specification (SRS) - OrionHealth

## 1. Introduction
OrionHealth is a privacy-first, local-first personal health assistant designed to empower users with full control over their medical data while providing AI-driven insights using on-device models.

## 2. Overall Description
The system is built as a decentralized medical intelligence network, focusing on security, privacy, and interoperability through international medical standards.

## 3. System Requirements

### 3.1 Functional Requirements
*(See individual feature documentation for detailed functional requirements)*

### 3.2 External Interface Requirements
- **User Interfaces**: Material Design 3 based mobile interface.
- **Hardware Interfaces**: NFC, Bluetooth Low Energy (BLE), and Wi-Fi for P2P sharing.
- **Software Interfaces**: Integration with Apple HealthKit (iOS) and Google Health Connect (Android).

### 3.3 Non-functional Requirements

#### 3.3.1 Security
- **Self-Sovereign Identity (SSI)**: Implementation of DIDs and Verifiable Credentials via the [`health_wallet`](../packages/health_wallet/README.md) package for secure, owner-controlled identity and data exchange.
- **Encryption at Rest**: All sensitive health data is stored locally using **AES-256-GCM** encryption via Isar DB. See [Architecture: Encryption](ARCHITECTURE.md#encryption).
- **Encryption in Transit**: P2P data exchange and network synchronization must use **TLS 1.3** or higher with ECDHE key exchange.
- **Zero-Knowledge Architecture**: The system is designed so that no entity other than the user can access or decrypt their private health data. Keys are managed in the device's secure enclave (Keychain/Keystore).
- **Handling of Sensitive Data**: Explicit separation of PII (Personally Identifiable Information) and PHI (Protected Health Information). Sensitive fields are encrypted before database storage. See [Roadmap: Security Specifications](ORIONHEALTH-ROADMAP.md#security).

#### 3.3.2 Privacy
- **100% Offline-first**: All core functionalities, including AI assistant and medical record management, must function without an active internet connection. See [Planning: Privacy-First Philosophy](planning/PLANNING.md#data-philosophy).
- **User Consent**: Granular consent mechanisms for every data sharing action. Users must explicitly approve sharing of "Medical Packages" via BLE/NFC.
- **Data Policy**:
    - **Public**: Medical standards and guidelines (unencrypted).
    - **Private**: Personal health records (encrypted, device-only).
    - **Shared**: Explicitly authorized data for P2P transfer (encrypted for recipient).
    See [Roadmap: Data Privacy Model](ORIONHEALTH-ROADMAP.md#data-privacy-model).
- **Zero Telemetry**: Strict policy against tracking, analytics, or third-party crash reporting to ensure maximum user privacy. See [Architecture: Privacy Model](ARCHITECTURE.md#privacy).

#### 3.3.3 Performance
- **App Load Time**: Initial cold start to interactive state must be under **2 seconds**.
- **On-Device Inference**: AI assistant response generation (TTFT - Time To First Token) should be under **500ms** for local models.
- **APK Size**: The core application package (excluding on-demand medical standards downloads) must be kept under **50MB**.

#### 3.3.4 Offline Capability
- **Synchronization**: Automatic background synchronization of medical standards and public guidelines when connectivity is restored.
- **Full Local Cache**: All relevant medical standards (ICD-10, LOINC, etc.) based on the user's profile are cached locally for 100% offline access.
- **Airplane Mode**: The application must remain fully functional in airplane mode, including data entry, AI analysis, and historical data viewing.

#### 3.3.5 Compliance & Medical Standards
- **Regulatory Compliance (Colombia)**:
    - **Ley 1581 de 2012**: Protection of personal data (Habeas Data).
    - **Ley 2015 de 2020**: Electronic medical records interoperability.
    See [Roadmap: Compliance Standards](ORIONHEALTH-ROADMAP.md#compliance).
- **Medical Standards Interoperability**:
    - **ICD-10**: Clinical diagnoses classification.
    - **LOINC**: Laboratory and clinical observations.
    - **RxNorm**: Standardized medication nomenclature.
    - **SNOMED CT**: Comprehensive clinical terminology.
    See [Planning: Medical Standards Architecture](planning/PLANNING.md#medical-standards-architecture).
- **Accessibility**: Compliance with **WCAG 2.1 Level AA** standards to ensure inclusivity for users with disabilities.

---

## 4. Traceability & References
- [Architecture Guide](ARCHITECTURE.md)
- [Technical Roadmap](ORIONHEALTH-ROADMAP.md)
- [Privacy-First Philosophy](planning/PLANNING.md)
- [Health Wallet Package](../packages/health_wallet/README.md)
