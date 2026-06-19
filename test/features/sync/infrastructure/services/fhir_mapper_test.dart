import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/sync/infrastructure/services/fhir_mapper.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';

void main() {
  group('FhirMapper', () {
    test('mapPatient should map correctly', () {
      final json = {
        'resourceType': 'Patient',
        'id': '123',
        'name': [
          {
            'family': 'Doe',
            'given': ['John']
          }
        ],
        'gender': 'male',
        'birthDate': '1990-01-01',
        'telecom': [
          {'system': 'email', 'value': 'john@example.com'},
          {'system': 'phone', 'value': '123456789'}
        ]
      };
      final existing = UserProfile();
      final result = FhirMapper.mapPatient(json, existing);

      expect(result.name, 'John Doe');
      expect(result.sex, 'male');
      expect(result.birthDate, DateTime(1990, 1, 1));
      expect(result.email, 'john@example.com');
      expect(result.phoneNumber, '123456789');
      expect(result.uniqueId, '123');
    });

    test('mapObservation should map LOINC codes to VitalSigns', () {
      final json = {
        'resourceType': 'Observation',
        'code': {
          'coding': [
            {'system': 'http://loinc.org', 'code': '8867-4', 'display': 'Heart rate'}
          ]
        },
        'valueQuantity': {'value': 75, 'unit': 'bpm'},
        'effectiveDateTime': '2023-10-27T10:00:00Z'
      };

      final results = FhirMapper.mapObservation(json);
      expect(results.length, 1);
      expect(results[0].type, VitalSignType.heartRate);
      expect(results[0].value, 75);
    });
  });
}
