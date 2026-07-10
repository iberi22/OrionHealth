# EPS Connection & Colombia Health Data Integration

## Objective
Establish a secure, interoperable connection with Colombian health providers (EPS) and the national health data infrastructure (Minsalud) to allow users to manage their clinical history and authorizations locally.

## Regulatory Framework
- **Ley 2015 de 2020**: Regulates the Electronic Clinical History Interoperability (IHC) in Colombia.
- **Resolución 866 de 2021**: Technical specifications for IHC interoperability based on HL7 FHIR.
- **Resolución 2275 de 2023**: New RIPS (Individual Records of Health Services Provision) format based on JSON.

## Target Integrations

### 1. SURA EPS (Primary Target)
- **Status**: Researching available patient APIs.
- **Method**: OAuth2 for patient authorization.
- **Data**: Appointments, medical authorizations, and lab results.

### 2. Minsalud (Interoperabilidad IHC)
- **Standard**: HL7 FHIR R4.
- **Endpoint**: National Interoperability Node (Minsalud).
- **Security**: Digital certificates and OAuth2.

## Technical Specifications

### Interoperability Standards
- **HL7 FHIR R4**: The base for all clinical data exchange.
- **RIPS JSON**: For service provision data exchange.
- **LOINC/SNOMED CT**: For clinical terminology normalization.

### Authentication & Security
- **OAuth2**: Standard flow for patient-mediated data access.
- **HTTPS & Certificate Pinning**: Enforced for all provider endpoints.
- **AES-256-GCM**: Local encryption for all retrieved health data.

## Integration Roadmap

### Phase 1: Authentication & Authorization (Q3 2026)
- Implement OAuth2 flow for SURA EPS.
- Secure token storage in `SecureStorageService`.
- UI for provider selection and linking.

### Phase 2: Data Ingestion - Basic (Q4 2026)
- Fetch and parse upcoming appointments.
- Map basic medical records to `HealthRecord` entities.
- Implement background sync for new authorizations.

### Phase 3: FHIR Interoperability (Q1 2027)
- Integration with Minsalud IHC node.
- Mapping FHIR Resources (Patient, Observation, Condition, MedicationStatement) to local models.
- Support for Resolucion 866 clinical history summaries.

### Phase 4: RIPS Integration & Advanced Analytics (Q2 2027)
- Support for Resolucion 2275 JSON RIPS.
- Local AI analysis of longitudinal clinical data.
- Automated appointment reminders based on EPS data.

## Estimated Timeline
| Phase | Duration | Target Date |
|-------|----------|-------------|
| Research & Pilot | 2 months | August 2026 |
| Phase 1: Auth | 3 months | October 2026 |
| Phase 2: Basic Data | 4 months | February 2027 |
| Phase 3: FHIR IHC | 6 months | August 2027 |
