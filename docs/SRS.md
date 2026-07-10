# Software Requirements Specification (SRS) - OrionHealth v1.0

## 1. Introduction

### 1.1 Purpose
The purpose of this document is to provide a comprehensive description of the software requirements for OrionHealth. It specifies the functional and non-functional requirements, external interfaces, and constraints of the system. This document is intended for developers, project managers, and stakeholders to ensure a shared understanding of the product.

### 1.2 Scope
OrionHealth is a decentralized medical intelligence network and a privacy-first, local-first health assistant application built with Flutter. It enables users to own and control their complete health data history, integrated with local sensors and on-device AI to provide health insights without compromising privacy.

### 1.3 Definitions, Acronyms, and Abbreviations
*   **AI**: Artificial Intelligence
*   **BLE**: Bluetooth Low Energy
*   **DI**: Dependency Injection
*   **FHIR**: Fast Healthcare Interoperability Resources
*   **GATT**: Generic Attribute Profile
*   **HL7**: Health Level Seven
*   **ICD-10**: International Classification of Diseases, 10th Revision
*   **LOINC**: Logical Observation Identifiers Names and Codes
*   **NFC**: Near Field Communication
*   **PHI**: Protected Health Information
*   **PII**: Personally Identifiable Information
*   **RAG**: Retrieval-Augmented Generation
*   **SSI**: Self-Sovereign Identity
*   **SRS**: Software Requirements Specification

### 1.4 References
*   `features.json`: Catalog of 25 features.
*   `docs/ARCHITECTURE.md`: Clean Architecture vision.
*   `docs/ORIONHEALTH-ROADMAP.md`: Technical roadmap, phases, and statuses.
*   `docs/planning/PLANNING.md`: Vision and three-layer architecture.
*   `docs/FEATURE_AUDIT.md`: Detailed feature audit and metrics.
*   `SECURITY.md`: Security audit and data handling policies.
*   `docs/security/certificate-pinning.md`: Network security documentation.

## 2. General Description

### 2.1 Product Perspective
OrionHealth is a standalone mobile application that interfaces with local device hardware (NFC, BLE, Sensors) and utilizes on-device AI for medical intelligence. It operates as a node within a decentralized network for secure, P2P health data sharing.

### 2.2 User Functions
The system provides a wide range of functions, including health record management, vital signs monitoring, medication tracking, appointment scheduling, and AI-powered health insights through a local assistant.

### 2.3 User Characteristics
The primary users are individuals seeking to manage their personal health data with high privacy. Secondary users include healthcare providers who may receive shared data through secure P2P protocols.

### 2.4 Constraints
*   **Local-First**: All primary functions must work without an internet connection.
*   **Privacy-First**: PHI/PII must be encrypted and remain on-device unless explicitly shared.
*   **Architecture**: Must follow Clean Architecture principles (Presentation, Domain, Application, Infrastructure).
*   **Legal/Compliance**: Designed to support HIPAA, GDPR, and LGPD compliance.

## 3. Specific Requirements

### 3.1 External Interfaces

#### 3.1.1 User Interface
*   Material Design 3 aesthetic.
*   Cyber/Glassmorphic theme elements.
*   Responsive design for mobile (Android/iOS).
*   Support for 20+ languages (Localization).

#### 3.1.2 Hardware Interfaces
*   **NFC**: Used for contact-based P2P sharing.
*   **BLE**: Used for peer discovery and data transfer.
*   **WiFi**: Used for high-speed P2P data transfer (WiFi Direct/mDNS).
*   **Sensors**: Integration with device sensors via HealthKit (iOS) and Health Connect (Android).
*   **Biometrics**: Fingerprint and Face ID for authentication.

#### 3.1.3 Software Interfaces
*   **Flutter**: Framework for cross-platform development.
*   **Isar**: Local NoSQL database with AES encryption support.
*   **ONNX Runtime**: Engine for running on-device LLMs (Phi-3 Mini / Gemma 2B).
*   **Flutter Secure Storage**: For sensitive secrets and tokens.

#### 3.1.4 Communications Interfaces
*   TLS 1.3 for any external network communication.
*   SHA-256 Certificate Pinning for verified endpoints.
*   P2P protocols for decentralized synchronization.

### 3.2 Functional Requirements

The following requirements are mapped to the feature catalog and follow the Clean Architecture hierarchy.

| ID | Feature | Layer | Description |
|---|---|---|---|
| **REQ-F-001** | **Auth & Biometrics** | Presentation | Secure user authentication including biometric (fingerprint/face) login and PIN setup. |
| **REQ-F-002** | **User Profile** | Presentation | Management of personal health profile, basic information, and preferences. |
| **REQ-F-003** | **Dashboard** | Presentation | Centralized overview of health status, upcoming appointments, and daily summaries. |
| **REQ-F-004** | **Health Records** | Domain | Comprehensive management of medical history, clinical documents, and FHIR resources. |
| **REQ-F-005** | **Vitals Monitor** | Presentation | Tracking and visualization of vital signs like heart rate, blood pressure, and oxygen levels. |
| **REQ-F-006** | **Medications** | Domain | Tracking of prescribed medications, dosages, and adherence schedules. |
| **REQ-F-007** | **Appointments** | Application | Scheduling and management of medical appointments and follow-ups. |
| **REQ-F-008** | **Reports & Analytics** | Presentation | Visual representation of health trends and generated health reports. |
| **REQ-F-009** | **Medical Standards** | Domain | Integration and mapping of medical terminologies (ICD-10, LOINC, RxNorm, SNOMED). |
| **REQ-F-010** | **Doctor Verification** | Application | System for verifying medical credentials and professional status of healthcare providers. |
| **REQ-F-011** | **Voice Chat** | Presentation | On-device AI-powered voice assistant for hands-free interaction. |
| **REQ-F-012** | **Local Agent** | Infrastructure | Personalized local AI agent that learns from user data while maintaining privacy. |
| **REQ-F-013** | **Network Sync** | Infrastructure | Infrastructure for peer-to-peer data synchronization across devices. |
| **REQ-F-014** | **Allergies** | Domain | Management and tracking of known allergies and adverse reactions. |
| **REQ-F-015** | **Calendar Import** | Presentation | Integration with external calendar providers (Gmail, Outlook) to import medical appointments. |
| **REQ-F-016** | **Health Sharing** | Application | Secure sharing of health data with trusted individuals or providers via P2P. |
| **REQ-F-017** | **Governance** | Application | Mechanisms for network participation, decision-making, and policy updates. |
| **REQ-F-018** | **Incentives & Rewards** | Presentation | Gamification and reward system for healthy habits and network contributions. |
| **REQ-F-019** | **Meditation** | Presentation | Guided offline meditation and breathing exercises for mental well-being. |
| **REQ-F-020** | **Settings** | Presentation | Application configuration, privacy controls, and theme management. |
| **REQ-F-021** | **Sync Service** | Infrastructure | Background service orchestrating data consistency across multiple platforms. |
| **REQ-F-022** | **Emergency Data** | Domain | Critical health information accessible in case of emergency (Medical ID). |
| **REQ-F-023** | **Scraping Config** | Application | Configuration and adapters for retrieving medical information from various research sources. |
| **REQ-F-024** | **Proposals** | Presentation | Interface for submitting and voting on network improvement proposals. |
| **REQ-F-025** | **Data Sources** | Infrastructure | Integration layer for diverse health data inputs (sensors, files, external APIs). |

### 3.3 Non-functional Requirements

#### 3.3.1 Performance
*   AI inference response time: < 5 seconds for initial token.
*   App cold start: < 2 seconds on modern devices.
*   UI responsiveness: Maintain 60fps for animations.

#### 3.3.2 Security
*   **Data at Rest**: AES-256-GCM encryption for all PHI.
*   **Data in Transit**: TLS 1.3 + ECDHE.
*   **Certificate Pinning**: Hardened certificate validation for known hosts.
*   **Biometric/PIN**: Mandatory for accessing sensitive health data.
*   **Zero Telemetry**: No tracking of user health activities or data.

#### 3.3.3 Offline-First
*   All core features (records, AI assistant, vitals) must remain functional without internet.
*   AI models must be stored and run locally on the device.

#### 3.3.4 Self-Sovereign Identity (SSI)
*   Support for Verifiable Credentials (VCs).
*   User-controlled identity management.

#### 3.3.5 Compliance
*   **HIPAA**: Implementation of technical safeguards for PHI.
*   **GDPR**: Support for data portability (JSON export) and right to erasure.

### 3.4 Data Requirements

#### 3.4.1 Medical Standards
The system shall utilize the following standards for data structuring and interoperability:
*   **ICD-10**: For diagnosis and condition coding.
*   **LOINC**: For laboratory and clinical observations.
*   **RxNorm**: For medication terminology.
*   **SNOMED CT**: For comprehensive clinical terminology.
*   **HL7 FHIR R4**: For data exchange and interoperability format.

#### 3.4.2 Database Schema
*   Stored locally using Isar Database.
*   Support for Full-Text Search (FTS) on health records.
*   Encrypted collections for sensitive data.

## 4. Appendices

### 4.1 Glossary
*   **Clean Architecture**: A software design philosophy that separates the elements of a design into ring-level levels.
*   **P2P**: Peer-to-Peer network.
*   **Phi-3 / Gemma**: Small Language Models (SLMs) optimized for mobile and edge devices.

### 4.2 Regulatory References
*   HIPAA Security Rule (45 CFR Part 160 and Subparts A and C of Part 164).
*   GDPR Regulation (EU) 2016/679.
