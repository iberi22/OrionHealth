### 3.3 Non-functional Requirements

## Compliance Matrix (last reviewed: 2026-08-29 — Wave 9)

| REQ-NF | Requirement | Status | Implementation | Tests |
|--------|-------------|--------|----------------|-------|
| REQ-NF-001 | SSI / DIDs / VCs | ✅ Implemented | `packages/health_wallet/` | wallet tests |
| REQ-NF-002 | AES-256-GCM at rest | ✅ Implemented | `lib/core/services/secure_storage_service.dart` | encryption tests |
| REQ-NF-003 | TLS 1.3+ transit | ✅ Implemented | `docs/security/certificate-pinning.md` | n/a |
| REQ-NF-004 | Zero-telemetry | ✅ Implemented | no analytics SDK in deps | n/a |
| REQ-NF-005 | Cold start <2s, TTFT <500ms | ⚠ Partial | benchmarks partial | n/a |
| REQ-NF-006 | APK <50MB, 60fps | ⚠ Partial | no automated CI measurement | n/a |
| REQ-NF-007 | Airplane mode 100% | ✅ Implemented | all features local | widget tests |
| REQ-NF-008 | Ley 1581 + Ley 2015 | ⚠ In Wave 9 | #1675 (HabeasDataConsent) + #1676 (ArcoRights) | pending |
| REQ-NF-009 | GDPR portability + erasure | ⚠ In Wave 9 | #1672 (DataExport) + #1673 (RightToErasure) | pending |
| REQ-NF-010 | WCAG 2.1 AA | ⚠ In Wave 9 | #1671 (semanticLabel) + Wave 7 SWALTooltip | pending |

### Known Gaps (2026-08-29)

- **REQ-NF-005** (Performance benchmarks): No automated cold-start measurement in CI.
- **REQ-NF-006** (APK size + 60fps): No automated measurement. Manual check only.
- **REQ-NF-008/009/010** (Compliance): Wave 9 issues dispatched to Jules (in flight).
- **REQ-NF-010** (WCAG): External audit not performed. Self-assessment only.

### Next review after Wave 9 merge

This matrix is updated by the orchestrator after each wave. The "Status" column reflects actual implementation state, not aspirational goals.

---

#### 3.3.1 Security
- **Self-Sovereign Identity (SSI)**: Implementation of DIDs and Verifiable Credentials via the \health_wallet\ package for secure, owner-controlled identity and data exchange.
- **Encryption at Rest**: All sensitive health data is stored locally using **AES-256-GCM** encryption via Isar DB.
- **Encryption in Transit**: P2P data exchange and network synchronization must use **TLS 1.3** or higher with ECDHE key exchange.
- **Zero-Knowledge Architecture**: The system is designed so that no entity other than the user can access or decrypt their private health data. Keys are managed in the device\'s secure enclave (Keychain/Keystore).
- **Handling of Sensitive Data**: Explicit separation of PII and PHI. Sensitive fields are encrypted before database storage.
- **Certificate Pinning**: Hardened certificate validation for known hosts.

#### 3.3.2 Privacy
- **100% Offline-first**: All core functionalities must function without an active internet connection.
- **User Consent**: Granular consent mechanisms for every data sharing action.
- **Data Policy**: Public (medical standards, unencrypted), Private (PHR, encrypted, device-only), Shared (explicitly authorized, encrypted for recipient).
- **Zero Telemetry**: Strict policy against tracking, analytics, or third-party crash reporting.
- **Biometric/PIN**: Mandatory for accessing sensitive health data.

#### 3.3.3 Performance
- **App Load Time**: Initial cold start to interactive state must be under **2 seconds**.
- **On-Device Inference**: AI assistant TTFT should be under **500ms** for local models.
- **APK Size**: Core application package must be kept under **50MB**.
- **UI Responsiveness**: Maintain 60fps for animations.

#### 3.3.4 Offline Capability
- **Synchronization**: Automatic background sync of medical standards when connectivity is restored.
- **Full Local Cache**: All medical standards cached locally for 100% offline access.
- **Airplane Mode**: Full functionality in airplane mode (data entry, AI analysis, history viewing).

#### 3.3.5 Compliance & Medical Standards
- **Regulatory Compliance (Colombia)**:
  - **Ley 1581 de 2012**: Protection of personal data (Habeas Data).
  - **Ley 2015 de 2020**: Electronic medical records interoperability.
- **International Standards**:
  - **HIPAA**: Implementation of technical safeguards for PHI.
  - **GDPR**: Support for data portability (JSON export) and right to erasure.
- **Medical Standards Interoperability**:
  - **ICD-10**: Clinical diagnoses classification.
  - **LOINC**: Laboratory and clinical observations.
  - **RxNorm**: Standardized medication nomenclature.
  - **SNOMED CT**: Comprehensive clinical terminology.
  - **HL7 FHIR R4**: Data exchange and interoperability format.
- **Accessibility**: Compliance with **WCAG 2.1 Level AA** standards.

