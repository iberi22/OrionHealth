import '../entities/credential_schema.dart';

/// Registry of medical credential schemas with local validation.
///
/// Provides predefined AnonCreds-compatible schemas for medical data
/// and validates claims against schema definitions.
class SchemaRegistry {
  static final SchemaRegistry _instance = SchemaRegistry._();
  factory SchemaRegistry() => _instance;
  SchemaRegistry._();

  /// All registered schemas by ID.
  static final Map<String, CredentialSchema> _schemas = {
    // ── Core medical schemas ────────────────────────────────────────
    CredentialSchema.vaccinationCredential.id: CredentialSchema.vaccinationCredential,
    CredentialSchema.labResultCredential.id: CredentialSchema.labResultCredential,
    CredentialSchema.prescriptionCredential.id: CredentialSchema.prescriptionCredential,

    // ── Vital Signs schemas ────────────────────────────────────────
    ..._vitalSignSchemas,
    // ── Lab Result schemas ─────────────────────────────────────────
    ..._labResultSchemas,
  };

  /// Vital Signs schemas
  static final Map<String, CredentialSchema> _vitalSignSchemas = {
    'orion:schemas:HeartRateMeasurement:v1': const CredentialSchema(
      id: 'orion:schemas:HeartRateMeasurement:v1',
      name: 'Heart Rate Measurement',
      version: '1.0.0',
      attributes: ['heartRate', 'recordedAt', 'deviceSource', 'unit'],
    ),
    'orion:schemas:BloodPressureReading:v1': const CredentialSchema(
      id: 'orion:schemas:BloodPressureReading:v1',
      name: 'Blood Pressure Reading',
      version: '1.0.0',
      attributes: ['systolic', 'diastolic', 'recordedAt', 'deviceSource', 'unit'],
    ),
    'orion:schemas:BodyTemperature:v1': const CredentialSchema(
      id: 'orion:schemas:BodyTemperature:v1',
      name: 'Body Temperature',
      version: '1.0.0',
      attributes: ['temperature', 'site', 'recordedAt', 'deviceSource', 'unit'],
    ),
    'orion:schemas:OxygenSaturation:v1': const CredentialSchema(
      id: 'orion:schemas:OxygenSaturation:v1',
      name: 'Oxygen Saturation',
      version: '1.0.0',
      attributes: ['spo2', 'heartRate', 'recordedAt', 'deviceSource', 'unit'],
    ),
    'orion:schemas:RespiratoryRate:v1': const CredentialSchema(
      id: 'orion:schemas:RespiratoryRate:v1',
      name: 'Respiratory Rate',
      version: '1.0.0',
      attributes: ['respiratoryRate', 'recordedAt', 'deviceSource', 'unit'],
    ),
  };

  /// Lab Result schemas
  static final Map<String, CredentialSchema> _labResultSchemas = {
    'orion:schemas:BloodGlucose:v1': const CredentialSchema(
      id: 'orion:schemas:BloodGlucose:v1',
      name: 'Blood Glucose',
      version: '1.0.0',
      attributes: ['glucoseValue', 'mealContext', 'recordedAt', 'unit'],
    ),
    'orion:schemas:HbA1c:v1': const CredentialSchema(
      id: 'orion:schemas:HbA1c:v1',
      name: 'HbA1c',
      version: '1.0.0',
      attributes: ['hba1cValue', 'recordedAt', 'unit'],
    ),
    'orion:schemas:CholesterolPanel:v1': const CredentialSchema(
      id: 'orion:schemas:CholesterolPanel:v1',
      name: 'Cholesterol Panel',
      version: '1.0.0',
      attributes: ['totalCholesterol', 'ldl', 'hdl', 'triglycerides', 'recordedAt', 'unit'],
    ),
    'orion:schemas:Creatinine:v1': const CredentialSchema(
      id: 'orion:schemas:Creatinine:v1',
      name: 'Creatinine',
      version: '1.0.0',
      attributes: ['creatinineValue', 'recordedAt', 'unit'],
    ),
    'orion:schemas:Hemoglobin:v1': const CredentialSchema(
      id: 'orion:schemas:Hemoglobin:v1',
      name: 'Hemoglobin',
      version: '1.0.0',
      attributes: ['hemoglobinValue', 'recordedAt', 'unit'],
    ),
  };

  /// Get a schema by its ID.
  CredentialSchema? getSchema(String id) => _schemas[id];

  /// List all registered schemas.
  List<CredentialSchema> listSchemas() => _schemas.values.toList();

  /// List schemas by category (e.g., 'vital', 'lab', 'prescription').
  List<CredentialSchema> listSchemasByCategory(String category) {
    return _schemas.values
        .where((s) => s.name.toLowerCase().contains(category.toLowerCase()))
        .toList();
  }

  /// Validate claims against a schema.
  ///
  /// Returns a list of validation error messages. Empty list = valid.
  ///
  /// Checks:
  /// - All required attributes are present
  /// - No unexpected attributes (extra claims not in schema)
  /// - Attribute types match hints (basic validation)
  SchemaValidationResult validate(String schemaId, Map<String, dynamic> claims) {
    final schema = _schemas[schemaId];
    if (schema == null) {
      return SchemaValidationResult(
        isValid: false,
        errors: ['Schema not found: $schemaId'],
      );
    }

    final errors = <String>[];

    // Check for missing required attributes
    for (final attr in schema.attributes) {
      if (!claims.containsKey(attr)) {
        errors.add('Missing required attribute: $attr');
      }
    }

    // Check for unexpected attributes
    for (final key in claims.keys) {
      if (!schema.attributes.contains(key)) {
        // Allow extra dynamic attributes (like 'recordedAt', 'notes')
        // but warn about unknown structured fields
        if (!key.startsWith('_')) {
          errors.add('Unexpected attribute: $key (not in schema ${schema.id})');
        }
      }
    }

    // Type validation based on attribute type hints
    for (final entry in schema.attributeTypes.entries) {
      final value = claims[entry.key];
      if (value != null) {
        final expectedType = entry.value;
        if (expectedType == 'number' && value is! num) {
          errors.add('Attribute ${entry.key} should be a number, got ${value.runtimeType}');
        }
      }
    }

    return SchemaValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      schema: schema,
    );
  }

  /// Register a custom schema at runtime.
  void register(CredentialSchema schema) {
    _schemas[schema.id] = schema;
  }
}

/// Result of schema validation.
class SchemaValidationResult {
  final bool isValid;
  final List<String> errors;
  final CredentialSchema? schema;

  const SchemaValidationResult({
    required this.isValid,
    required this.errors,
    this.schema,
  });
}
