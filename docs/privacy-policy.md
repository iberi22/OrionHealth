# Privacy Policy — OrionHealth

Last updated: 2026-08-29
Effective: 2026-08-29

## 1. Data Controller

OrionHealth is a privacy-first, local-first health assistant. The **user is
the sole owner and controller of their data**. There is no central server
collecting, processing, or transmitting your health information.

For questions or to exercise your rights, contact us via:
- GitHub Issues: https://github.com/iberi22/OrionHealth/issues
- Email: [contact info — to be added]

## 2. Data We Collect and Process

We store ONLY on the user's device:

### Personal data

- Profile data (name, age, biological sex, weight, height, etc.)
- Authentication credentials (PIN, biometric tokens — stored in device's
  secure enclave, never transmitted)

### Health data (PHI)

- Medical records (diagnoses, lab results, imaging references)
- Medications (current and historical)
- Vital signs (heart rate, blood pressure, glucose, weight trends, etc.)
- Allergies and conditions
- Vaccination history
- Clinical assessments and consent documents
- Local AI model outputs (health insights, risk scores)

### Usage data

- PHI audit log (who accessed what, when) — for HIPAA compliance
- App preferences (theme, language, notifications)

### Data we DO NOT collect

- No analytics
- No crash reporting (e.g., Firebase Crashlytics, Sentry)
- No advertising IDs
- No location tracking (unless user explicitly imports a calendar)
- No third-party SDK telemetry

## 3. Purpose of Processing

OrionHealth processes your data locally to provide:

- **Personalized health intelligence**:
  - Symptom analysis and differential diagnosis
  - Drug interaction checking
  - Lab result interpretation
  - Trend analysis and alerts
- **Self-sovereign identity** (SSI): manage verifiable health credentials
- **Medical standards reference**: ICD-10, LOINC, RxNorm, SNOMED CT lookups
  (these are public reference data, not personal data)
- **Audit trail**: log of PHI access events for compliance and security

## 4. Legal Basis

### GDPR (European Union)

- **Article 6(1)(a)**: Explicit consent
- **Article 6(1)(d)**: Vital interests
- **Article 9(2)(h)**: Healthcare provision
- **Article 9(2)(i)**: Public health

### Ley 1581 de 2012 (Colombia)

- **Article 6**: Explicit consent for personal data processing
- **Article 17**: Rights of the data subject (ARCO)
- **Article 4**: Purpose limitation

### HIPAA (United States)

- **45 CFR § 164.312**: Technical safeguards
- **45 CFR § 164.316**: Documentation requirements
- **45 CFR § 164.530**: Administrative safeguards (audit controls)

## 5. Data Retention

| Data Type | Retention Period |
|-----------|------------------|
| Profile data | Until user requests deletion |
| Medical records | Until user requests deletion |
| Medications | Until user requests deletion |
| Vital signs | Until user requests deletion |
| PHI audit log | 6 years (HIPAA § 164.530(j)(2)) |
| Encrypted backups (if enabled) | User-controlled |
| Anonymous usage statistics | Never collected |

## 6. Third-Party Sharing

**None.** OrionHealth does not share data with any third party under any
circumstances. There are no:

- Marketing partners
- Analytics providers
- Cloud backup services
- Advertising networks
- Data brokers

Your data never leaves your device unless you explicitly share it via the
Health Sharing feature (which uses your explicit consent and direct peer-to-peer
transfer).

## 7. International Transfers

**None.** All data processing occurs on the user's device. There is no server
infrastructure that would constitute a "transfer" of personal data.

If you use the optional Peer-to-Peer Health Sharing feature, data transfers
directly between you and the recipient you authorize, using end-to-end
encryption (TLS 1.3+ with ECDHE key exchange).

## 8. Security Measures

### Encryption

- **At rest**: AES-256-GCM (Isar DB) with keys managed in device secure
  enclave (iOS Keychain / Android Keystore)
- **In transit**: TLS 1.3+ with ECDHE key exchange for any network sync
- **Certificate pinning**: Hardened certificate validation for known hosts
  (see `docs/security/certificate-pinning.md`)

### Access controls

- Mandatory biometric or PIN authentication for app access
- Automatic session timeout after 15 minutes of inactivity
- PHI access logged for audit (see Wave 9 issue #1674)

### Code-level

- Zero telemetry, no analytics, no crash reporting
- All network connections are user-initiated
- Inputs sanitized to prevent injection attacks
- Dependencies audited for known vulnerabilities (Dependabot)

## 9. Your Rights

You have the right to:

### Access

Export ALL your data in a portable ZIP format.
Settings → My Rights → Access (GDPR Art. 15, Ley 1581 Art. 17 Acceso)

### Rectification

Correct inaccurate personal data.
Settings → My Rights → Rectification

### Cancellation / Erasure

Delete all or part of your data (right to be forgotten).
Settings → My Rights → Cancellation
GDPR Art. 17, Ley 1581 Art. 17 Cancelación

### Opposition

Object to processing for specific purposes (e.g., analytics, marketing).
Settings → My Rights → Opposition
GDPR Art. 21, Ley 1581 Art. 17 Oposición

### Portability

Receive your data in a structured, commonly used, machine-readable format
(JSON, ZIP).
GDPR Art. 20 (implemented in Wave 9 issue #1672)

### Restriction

Request restriction of processing in certain circumstances.
GDPR Art. 18

### Lodge a Complaint

File a complaint with your local data protection authority.
Colombia: Superintendencia de Industria y Comercio (SIC)
EU: Your national Data Protection Authority

## 10. Children's Privacy

OrionHealth is not intended for children under 13 (COPPA) or 16 (GDPR Art. 8,
Ley 1581). We do not knowingly collect data from children. If you believe a
child has provided data, please contact us for deletion.

## 11. Changes to This Policy

We will notify users of material changes via in-app notification at least
**30 days before** the change takes effect. The notification will:

- Summarize the changes
- Provide the full new policy
- Allow users to accept or object (and exit / export data if desired)

Non-material changes (typos, clarifications) may be made without notice
but will be reflected in the "Last updated" date above.

## 12. Open Source and Transparency

OrionHealth is open-source (AGPL-3.0). You can:

- Inspect the source code: https://github.com/iberi22/OrionHealth
- Verify our privacy claims by reading the code
- Submit issues or pull requests
- Fork the project for your own use

We encourage security researchers and privacy advocates to review our code
and report any concerns.

## 13. Contact

For privacy questions, to exercise your rights, or to report concerns:

- **GitHub Issues**: https://github.com/iberi22/OrionHealth/issues
  (use `privacy` or `compliance` label)
- **Email**: [to be added]
- **Security disclosures**: See SECURITY.md

We aim to respond to privacy requests within **15 business days** as
required by Ley 1581 Art. 14 and GDPR Art. 12.

---

Last updated: 2026-08-29 — Wave 9 (orchestrator)
Effective: 2026-08-29