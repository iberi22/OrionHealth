import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/ssi/domain/entities/credential_schema.dart';
import 'package:orionhealth_health/features/ssi/domain/services/schema_registry.dart';

void main() {
  late SchemaRegistry registry;

  setUp(() {
    registry = SchemaRegistry();
  });

  group('SchemaRegistry', () {
    test('resolves core medical schemas by ID', () {
      final vaccination = registry.getSchema('orion:schemas:VaccinationCredential:v1');
      expect(vaccination, isNotNull);
      expect(vaccination!.name, 'Vaccination Credential');
    });

    test('resolves composite vital signs schema', () {
      final vitals = registry.getSchema('orion:schemas:VitalSignsCredential:v1');
      expect(vitals, isNotNull);
      expect(vitals!.name, 'Vital Signs Credential');
      expect(vitals.attributes, contains('heartRate'));
    });

    test('resolves composite lab result schema (v2)', () {
      final labV2 = registry.getSchema('orion:schemas:LabResultCredential:v2');
      expect(labV2, isNotNull);
      expect(labV2!.name, 'Lab Result Credential (Composite)');
      expect(labV2.attributes, contains('specimenType'));
    });

    test('resolves individual vital sign schemas', () {
      final hr = registry.getSchema('orion:schemas:HeartRateMeasurement:v1');
      expect(hr, isNotNull);
      expect(hr!.attributes, contains('heartRate'));
      expect(hr.attributes, contains('recordedAt'));

      final bp = registry.getSchema('orion:schemas:BloodPressureReading:v1');
      expect(bp, isNotNull);
      expect(bp!.attributes, contains('systolic'));
      expect(bp.attributes, contains('diastolic'));
    });

    test('resolves individual lab result schemas', () {
      final glucose = registry.getSchema('orion:schemas:BloodGlucose:v1');
      expect(glucose, isNotNull);
      expect(glucose!.attributes, contains('glucoseValue'));

      final cholesterol = registry.getSchema('orion:schemas:CholesterolPanel:v1');
      expect(cholesterol, isNotNull);
      expect(cholesterol!.attributes, contains('ldl'));
    });

    test('listSchemas returns all registered schemas', () {
      final all = registry.listSchemas();
      expect(all.length, greaterThanOrEqualTo(11));
    });

    test('listSchemasByCategory filters by name', () {
      final vitals = registry.listSchemasByCategory('vital');
      expect(vitals, isNotEmpty);
      expect(vitals.every((s) => s.name.toLowerCase().contains('vital')), true);

      final labs = registry.listSchemasByCategory('lab');
      expect(labs, isNotEmpty);
    });

    test('validate returns valid for matching claims', () {
      final result = registry.validate('orion:schemas:VaccinationCredential:v1', {
        'vaccineName': 'COVID-19 mRNA',
        'doseNumber': 2,
        'dateAdministered': '2026-05-01',
        'lotNumber': 'LOT-123',
        'administeringClinic': 'Hospital Central',
      });
      expect(result.isValid, true);
      expect(result.errors, isEmpty);
    });

    test('validate returns errors for missing attributes', () {
      final result = registry.validate('orion:schemas:VaccinationCredential:v1', {
        'vaccineName': 'COVID-19 mRNA',
      });
      expect(result.isValid, false);
      expect(result.errors, isNotEmpty);
      expect(result.errors.any((e) => e.contains('Missing required')), true);
    });

    test('validate returns error for unknown schema', () {
      final result = registry.validate('orion:schemas:Unknown:v1', {});
      expect(result.isValid, false);
      expect(result.errors.first, contains('Schema not found'));
    });

    test('register adds custom schema at runtime', () {
      registry.register(const CredentialSchema(
        id: 'orion:schemas:CustomTest:v1',
        name: 'Custom Test',
        version: '1.0.0',
        attributes: ['customField'],
      ));

      final schema = registry.getSchema('orion:schemas:CustomTest:v1');
      expect(schema, isNotNull);
      expect(schema!.name, 'Custom Test');
    });
  });
}
