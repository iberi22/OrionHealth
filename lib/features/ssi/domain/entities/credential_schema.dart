/// Credential Schema for AnonCreds-compatible verifiable credentials.
///
/// Defines the structure and attribute types for a specific
/// medical credential type. Schemas are published to a
/// schema registry for interoperability.
class CredentialSchema {
  /// Schema identifier (e.g., did:ion:.../schemas/VaccinationCredential/v1)
  final String id;

  /// Human-readable name
  final String name;

  /// Schema version (semver)
  final String version;

  /// List of attribute names in this schema
  final List<String> attributes;

  /// Attribute type hints (name → type, e.g. 'dosage' → 'number').
  /// Currently informational; used for future schema validation.
  final Map<String, String> attributeTypes;

  const CredentialSchema({
    required this.id,
    required this.name,
    required this.version,
    required this.attributes,
    this.attributeTypes = const {},
  });

  /// Predefined medical credential schemas.
  static const vaccinationCredential = CredentialSchema(
    id: 'orion:schemas:VaccinationCredential:v1',
    name: 'Vaccination Credential',
    version: '1.0.0',
    attributes: ['vaccineName', 'doseNumber', 'dateAdministered', 'lotNumber', 'administeringClinic'],
  );

  static const labResultCredential = CredentialSchema(
    id: 'orion:schemas:LabResultCredential:v1',
    name: 'Lab Result Credential',
    version: '1.0.0',
    attributes: ['testName', 'resultValue', 'referenceRange', 'testDate', 'labName', 'interpretation'],
  );

  static const prescriptionCredential = CredentialSchema(
    id: 'orion:schemas:PrescriptionCredential:v1',
    name: 'Prescription Credential',
    version: '1.0.0',
    attributes: ['medicationName', 'dosage', 'frequency', 'prescribingDoctor', 'pharmacy', 'datePrescribed'],
  );

  /// Composite Vital Signs credential bundling multiple vital readings
  /// into a single verifiable credential. Includes common vitals such as
  /// heart rate, blood pressure, temperature, SpO₂, and respiratory rate
  /// for holistic sharing in clinical contexts.
  static const vitalSignsCredential = CredentialSchema(
    id: 'orion:schemas:VitalSignsCredential:v1',
    name: 'Vital Signs Credential',
    version: '1.0.0',
    attributes: [
      'heartRate',
      'systolic',
      'diastolic',
      'bodyTemperature',
      'temperatureSite',
      'spo2',
      'respiratoryRate',
      'recordedAt',
      'patientPosition',
    ],
    attributeTypes: {
      'heartRate': 'number',
      'systolic': 'number',
      'diastolic': 'number',
      'bodyTemperature': 'number',
      'spo2': 'number',
      'respiratoryRate': 'number',
    },
  );

  /// Composite Lab Result credential bundling multiple lab test readings
  /// into a single verifiable credential. Supports common lab panels
  /// such as basic metabolic panel, lipid panel, and complete blood count.
  static const labResultCredentialV2 = CredentialSchema(
    id: 'orion:schemas:LabResultCredential:v2',
    name: 'Lab Result Credential (Composite)',
    version: '2.0.0',
    attributes: [
      'testName',
      'resultValue',
      'referenceRange',
      'testDate',
      'labName',
      'interpretation',
      'specimenType',
      'performingProvider',
    ],
    attributeTypes: {
      'resultValue': 'number',
    },
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'version': version,
        'attributes': attributes,
      };
}
