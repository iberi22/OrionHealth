# Software Requirements Specification (SRS) - OrionHealth v1.0

## 1. Introduction
OrionHealth is a privacy-first, local-first medical intelligence network.

## 2. Functional Requirements

### 2.1 Core Features (REQ-F-1XX)
- **REQ-F-101**: Secure User Authentication (PIN/Biometric).
- **REQ-F-102**: Encrypted User Profile Management.
- **REQ-F-103**: Health Dashboard with summary visualization.

### 2.2 Health Data Management (REQ-F-2XX)
- **REQ-F-201**: Encrypted Medical Record Storage (Isar).
- **REQ-F-202**: Vitals Monitoring and historical tracking.
- **REQ-F-203**: Medication adherence and scheduling.
- **REQ-F-204**: Allergy and adverse reaction tracking.

### 2.3 AI Medical Assistant (REQ-F-3XX)
- **REQ-F-301**: Local LLM Inference (Phi-3 Mini / Gemma 2B).
- **REQ-F-302**: Retrieval-Augmented Generation (RAG) using local records.
- **REQ-F-303**: Symptom analysis with confidence-based thresholds.
- **REQ-F-304**: Voice interaction support.

### 2.4 Interoperability & Sharing (REQ-F-4XX)
- **REQ-F-401**: Secure P2P Health Data Sharing (BLE/NFC/WiFi).
- **REQ-F-402**: Medical Standards Mapping (ICD-10, LOINC, SNOMED, RxNorm).
- **REQ-F-403**: FHIR Resource support.
- **REQ-F-404**: Self-Sovereign Identity (SSI) integration.

### 2.5 Infrastructure & Sync (REQ-F-5XX)
- **REQ-F-501**: Decentralized Node Synchronization.
- **REQ-F-502**: Selective Synchronization based on profile.
- **REQ-F-503**: Encrypted Cloud Backup (optional).

## 3. Non-Functional Requirements
- **REQ-NF-01**: Data privacy (Local-first).
- **REQ-NF-02**: Security (AES-256-GCM, Argon2id).
- **REQ-NF-03**: Performance (Inference < 5s).
