import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_data_import/infrastructure/parsers/health_data_parser.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';

void main() {
  late HealthDataParser parser;

  setUp(() {
    parser = HealthDataParser();
  });

  group('HealthDataParser - CSV', () {
    test('should parse valid CSV data with header', () {
      const csv = 'type,value,unit,dateTime\nheartRate,72,bpm,2023-10-27T10:00:00Z\ntemperature,36.6,C,2023-10-27T10:05:00Z';
      final results = parser.parseCsv(csv);

      expect(results.length, 2);
      expect(results[0].type, VitalSignType.heartRate);
      expect(results[0].value, 72.0);
      expect(results[0].unit, 'bpm');
      expect(results[1].type, VitalSignType.temperature);
      expect(results[1].value, 36.6);
    });

    test('should parse valid CSV data without header', () {
      const csv = 'bpm,75,bpm,2023-10-27T11:00:00Z';
      final results = parser.parseCsv(csv);

      expect(results.length, 1);
      expect(results[0].type, VitalSignType.heartRate);
      expect(results[0].value, 75.0);
    });

    test('should handle malformed CSV rows', () {
      const csv = 'type,value,unit,dateTime\ninvalid,not_a_number,unit,date\nheartRate,80,bpm,2023-10-27T12:00:00Z';
      final results = parser.parseCsv(csv);

      expect(results.length, 1);
      expect(results[0].type, VitalSignType.heartRate);
    });

    test('should handle missing columns in CSV', () {
      const csv = 'type,value,unit\nheartRate,72,bpm';
      final results = parser.parseCsv(csv);
      expect(results.isEmpty, isTrue);
    });

    test('should handle mixed valid and invalid rows', () {
      const csv = 'type,value,unit,dateTime\nheartRate,72,bpm,2023-10-27T10:00:00Z\ninvalid,row\nspo2,98,%,2023-10-27T10:05:00Z';
      final results = parser.parseCsv(csv);
      expect(results.length, 2);
      expect(results[0].type, VitalSignType.heartRate);
      expect(results[1].type, VitalSignType.spO2);
    });

    test('should handle empty CSV', () {
      expect(parser.parseCsv('').length, 0);
      expect(parser.parseCsv('   ').length, 0);
    });
  });

  group('HealthDataParser - JSON', () {
    test('should parse valid JSON array', () {
      final jsonStr = jsonEncode([
        {
          'type': 'heartRate',
          'value': 70.5,
          'unit': 'bpm',
          'dateTime': '2023-10-27T13:00:00Z'
        },
        {
          'type': 'glucose',
          'value': 110,
          'unit': 'mg/dL',
          'dateTime': '2023-10-27T13:30:00Z'
        }
      ]);

      final results = parser.parseJson(jsonStr);

      expect(results.length, 2);
      expect(results[0].type, VitalSignType.heartRate);
      expect(results[0].value, 70.5);
      expect(results[1].type, VitalSignType.bloodGlucose);
    });

    test('should handle missing fields in JSON', () {
      final jsonStr = jsonEncode([
        {'type': 'heartRate', 'value': 70}, // missing dateTime
        {'type': 'heartRate', 'dateTime': '2023-10-27T14:00:00Z'} // missing value
      ]);

      final results = parser.parseJson(jsonStr);
      expect(results.length, 0);
    });

    test('should handle invalid JSON', () {
      expect(parser.parseJson('invalid json').length, 0);
      expect(parser.parseJson('{}').length, 0);
    });
  });

  group('HealthDataParser - FHIR', () {
    test('should parse FHIR Observation resource', () {
      final fhirData = jsonEncode({
        'resourceType': 'Observation',
        'status': 'final',
        'code': {
          'coding': [
            {'system': 'http://loinc.org', 'code': '8867-4', 'display': 'Heart rate'}
          ]
        },
        'effectiveDateTime': '2023-10-27T15:00:00Z',
        'valueQuantity': {'value': 78, 'unit': 'bpm'}
      });

      final results = parser.parseFhir(fhirData);

      expect(results.length, 1);
      expect(results[0].type, VitalSignType.heartRate);
      expect(results[0].value, 78.0);
    });

    test('should parse FHIR Bundle with Observations', () {
      final fhirBundle = jsonEncode({
        'resourceType': 'Bundle',
        'entry': [
          {
            'resource': {
              'resourceType': 'Observation',
              'code': {
                'coding': [
                  {'system': 'http://loinc.org', 'code': '8310-5'}
                ]
              },
              'effectiveDateTime': '2023-10-27T15:30:00Z',
              'valueQuantity': {'value': 37.2}
            }
          }
        ]
      });

      final results = parser.parseFhir(fhirBundle);

      expect(results.length, 1);
      expect(results[0].type, VitalSignType.temperature);
      expect(results[0].value, 37.2);
    });

    test('should parse FHIR Observation with multiple components (Blood Pressure)', () {
      final fhirBp = jsonEncode({
        'resourceType': 'Observation',
        'status': 'final',
        'code': {
          'coding': [
            {'system': 'http://loinc.org', 'code': '85354-9', 'display': 'Blood pressure panel with all children'}
          ]
        },
        'effectiveDateTime': '2023-10-27T16:00:00Z',
        'component': [
          {
            'code': {
              'coding': [
                {'system': 'http://loinc.org', 'code': '8480-6', 'display': 'Systolic blood pressure'}
              ]
            },
            'valueQuantity': {'value': 120, 'unit': 'mmHg'}
          },
          {
            'code': {
              'coding': [
                {'system': 'http://loinc.org', 'code': '8462-4', 'display': 'Diastolic blood pressure'}
              ]
            },
            'valueQuantity': {'value': 80, 'unit': 'mmHg'}
          }
        ]
      });

      final results = parser.parseFhir(fhirBp);

      expect(results.length, 2);
      expect(results.any((v) => v.type == VitalSignType.bloodPressureSystolic && v.value == 120), isTrue);
      expect(results.any((v) => v.type == VitalSignType.bloodPressureDiastolic && v.value == 80), isTrue);
    });

    test('should handle FHIR with no recognized codes', () {
      final fhirUnknown = jsonEncode({
        'resourceType': 'Observation',
        'code': {
          'coding': [
            {'system': 'http://loinc.org', 'code': 'unknown'}
          ]
        },
        'valueQuantity': {'value': 10}
      });
      final results = parser.parseFhir(fhirUnknown);
      expect(results.isEmpty, isTrue);
    });
  });

  group('HealthDataParser - Sanitization & Validation', () {
    test('should sanitize unit strings', () {
      const csv = 'heartRate,72,"bpm <script>",2023-10-27T10:00:00Z';
      final results = parser.parseCsv(csv);

      expect(results[0].unit, 'bpm script');
    });

    test('should validate heart rate range', () {
      final valid = VitalSign(
        type: VitalSignType.heartRate,
        value: 70,
        dateTime: DateTime.now(),
      );
      final invalidLow = VitalSign(
        type: VitalSignType.heartRate,
        value: -5,
        dateTime: DateTime.now(),
      );
      final invalidHigh = VitalSign(
        type: VitalSignType.heartRate,
        value: 350,
        dateTime: DateTime.now(),
      );

      expect(parser.isValid(valid), isTrue);
      expect(parser.isValid(invalidLow), isFalse);
      expect(parser.isValid(invalidHigh), isFalse);
    });

    test('should validate temperature range', () {
      final valid = VitalSign(
        type: VitalSignType.temperature,
        value: 36.5,
        dateTime: DateTime.now(),
      );
      final invalid = VitalSign(
        type: VitalSignType.temperature,
        value: 15,
        dateTime: DateTime.now(),
      );

      expect(parser.isValid(valid), isTrue);
      expect(parser.isValid(invalid), isFalse);
    });

    test('should validate blood pressure range', () {
      final validSystolic = VitalSign(
        type: VitalSignType.bloodPressureSystolic,
        value: 120,
        dateTime: DateTime.now(),
      );
      final invalidSystolic = VitalSign(
        type: VitalSignType.bloodPressureSystolic,
        value: 350,
        dateTime: DateTime.now(),
      );

      expect(parser.isValid(validSystolic), isTrue);
      expect(parser.isValid(invalidSystolic), isFalse);
    });

    test('should validate spO2 range', () {
      final valid = VitalSign(
        type: VitalSignType.spO2,
        value: 98,
        dateTime: DateTime.now(),
      );
      final invalid = VitalSign(
        type: VitalSignType.spO2,
        value: 105,
        dateTime: DateTime.now(),
      );

      expect(parser.isValid(valid), isTrue);
      expect(parser.isValid(invalid), isFalse);
    });
  });
}
