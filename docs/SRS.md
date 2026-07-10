# Software Requirements Specification (SRS) - OrionHealth

## 1. Introduction
This document describes the functional and non-functional requirements for the OrionHealth mobile application.

## 2. Functional Requirements

### 2.1 EPS Connection (eps_connection)

#### REQ-F-100: EPS Provider Integration
The system shall allow users to connect to Colombian health providers (EPS), starting with SURA EPS.

#### REQ-F-101: Secure Authentication
The system shall implement OAuth2 for secure authentication and authorization with EPS providers.

#### REQ-F-102: Data Synchronization
The system shall synchronize clinical data (appointments, authorizations, medical records) from connected EPS providers.

#### REQ-F-103: HL7 FHIR Compliance
The system shall use HL7 FHIR R4 as the standard for clinical data exchange with Minsalud and other interoperable providers.

#### REQ-F-104: Local Data Encryption
All data retrieved from EPS providers shall be stored locally using AES-256-GCM encryption.

#### REQ-F-105: Background Sync
The system shall support periodic background synchronization of health data to ensure information is up-to-date.

#### REQ-F-106: Minsalud IHC Interoperability
The system shall provide integration with the Colombian national interoperability node (IHC) according to Resolucion 866 of 2021.

#### REQ-F-107: RIPS JSON Support
The system shall support the ingestion and processing of RIPS data in JSON format as per Resolucion 2275 of 2023.

## 3. Non-Functional Requirements

### 3.1 Security
- **REQ-NF-200**: All external communication must use HTTPS with certificate pinning.
- **REQ-NF-201**: Sensitive tokens must be stored in the device's secure enclave (Keychain/Keystore).

### 3.2 Privacy
- **REQ-NF-300**: Users must provide explicit consent before connecting any health provider.
- **REQ-NF-301**: No raw clinical data shall be transmitted to OrionHealth servers.
