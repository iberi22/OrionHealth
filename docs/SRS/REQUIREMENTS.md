# Software Requirements Specification (SRS) Index — Requirements Summary

This document provides a consolidated index of system requirements for **OrionHealth v1.0**, bridging functional requirements (`REQ-F-001` to `REQ-F-107`) and non-functional requirements (`REQ-NF-001` to `REQ-NF-010`).

---

## 1. Functional Requirements (REQ-F-001 .. REQ-F-107)

Functional requirements specify features, system layers, and application capabilities defined across Clean Architecture layers.

| Requirement ID | Module / Feature | Architecture Layer | Description |
|---|---|---|---|
| **REQ-F-001** | Auth & Biometrics | Presentation | Secure user authentication including biometric (fingerprint/face) login and PIN setup. |
| **REQ-F-002** | User Profile | Presentation | Management of personal health profile, basic information, and preferences. |
| **REQ-F-003** | Dashboard | Presentation | Centralized overview of health status, upcoming appointments, and daily summaries. |
| **REQ-F-004** | Health Records | Domain | Comprehensive management of medical history, clinical documents, and FHIR resources. |
| **REQ-F-005** | Vitals Monitor | Presentation | Tracking and visualization of vital signs like heart rate, blood pressure, and oxygen levels. |
| **REQ-F-006** | Medications | Domain | Tracking of prescribed medications, dosages, and adherence schedules. |
| **REQ-F-007** | Appointments | Application | Scheduling and management of medical appointments and follow-ups. |
| **REQ-F-008** | Reports & Analytics | Presentation | Visual representation of health trends and generated health reports. |
| **REQ-F-009** | Medical Standards | Domain | Integration and mapping of medical terminologies (ICD-10, LOINC, RxNorm, SNOMED). |
| **REQ-F-010** | Doctor Verification | Application | System for verifying medical credentials and professional status of healthcare providers. |
| **REQ-F-011** | Voice Chat | Presentation | On-device AI-powered voice assistant for hands-free interaction. |
| **REQ-F-012** | Local Agent | Infrastructure | Personalized local AI agent that learns from user data while maintaining privacy. |
| **REQ-F-013** | Network Sync | Infrastructure | Infrastructure for peer-to-peer data synchronization across devices. |
| **REQ-F-014** | Allergies | Domain | Management and tracking of known allergies and adverse reactions. |
| **REQ-F-015** | Calendar Import | Presentation | Integration with external calendar providers (Gmail, Outlook) to import medical appointments. |
| **REQ-F-016** | Health Sharing | Application | Secure sharing of health data with trusted individuals or providers via P2P. |
| **REQ-F-017** | Governance | Application | Mechanisms for network participation, decision-making, and policy updates. |
| **REQ-F-018** | Incentives & Rewards | Presentation | Gamification and reward system for healthy habits and network contributions. |
| **REQ-F-019** | Meditation | Presentation | Guided offline meditation and breathing exercises for mental well-being. |
| **REQ-F-020** | Settings | Presentation | Application configuration, privacy controls, and theme management. |
| **REQ-F-021** | Sync Service | Infrastructure | Background service orchestrating data consistency across multiple platforms. |
| **REQ-F-022** | Emergency Data | Domain | Critical health information accessible in case of emergency (Medical ID). |
| **REQ-F-023** | Scraping Config | Application | Configuration and adapters for retrieving medical information from research sources. |
| **REQ-F-024** | Proposals | Presentation | Interface for submitting and voting on network improvement proposals. |
| **REQ-F-025** | Data Sources | Infrastructure | Integration layer for diverse health data inputs (sensors, files, external APIs). |
| **REQ-F-026** | Clinical Assessments | Presentation | Interactive clinical surveys and consent management for patient assessments. |
| **REQ-F-027 .. REQ-F-107** | Extended Clinical Modules | All Layers | Detailed sub-system specifications (diagnostics, lab results, immunization, prescriptions, telemedicine, device telemetry, FHIR adapters). |

---

## 2. Non-Functional Requirements (REQ-NF-001 .. REQ-NF-010)

Non-functional requirements define constraints, security rules, performance metrics, compliance standards, and offline capabilities.

| Requirement ID | Domain | Specification | Target Metric / Requirement |
|---|---|---|---|
| **REQ-NF-001** | Security | Identity & Authentication | Self-Sovereign Identity (SSI) with DIDs & Verifiable Credentials via `health_wallet`. |
| **REQ-NF-002** | Security | Encryption at Rest | AES-256-GCM encrypted local storage for sensitive health records via Isar & Secure Storage. |
| **REQ-NF-003** | Security | Encryption in Transit | P2P data exchange and network sync enforced via TLS 1.3+ with ECDHE key exchange. |
| **REQ-NF-004** | Privacy | Zero-Telemetry & Offline | 100% offline-first operation with zero third-party telemetry or cloud data extraction. |
| **REQ-NF-005** | Performance | App Load & Response Time | Cold start under 2.0s; local AI inference initial response (TTFT) under 500ms. |
| **REQ-NF-006** | Performance | Package Size & Frame Rate | Core APK size maintained under 50MB; 60fps UI animations. |
| **REQ-NF-007** | Offline | Offline Resilience | 100% feature availability in airplane mode with automatic background sync when reconnected. |
| **REQ-NF-008** | Compliance | Regulatory Data Protection | Compliance with Ley 1581 de 2012 (Habeas Data) & Ley 2015 de 2020 (EHR Interoperability). |
| **REQ-NF-009** | Compliance | International Standards | HIPAA technical safeguards and GDPR data portability/erasure support. |
| **REQ-NF-010** | Accessibility | UI Accessibility | WCAG 2.1 Level AA compliance across all Flutter UI views and widgets. |

---

## References & SRS Suite
1. `docs/SRS/01-functional-requirements.md`
2. `docs/SRS/02-non-functional-requirements.md`
3. `docs/SRS/03-external-interfaces.md`
4. `docs/SRS/04-data-requirements.md`
5. `docs/SRS/05-glossary.md`
6. `docs/SRS/06-introduction.md`
