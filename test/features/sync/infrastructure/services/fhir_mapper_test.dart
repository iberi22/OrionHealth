import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/sync/infrastructure/services/fhir_mapper.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';

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

    test('mapPatient should prioritize official name and text', () {
      final json = {
        'resourceType': 'Patient',
        'name': [
          {'family': 'Smith', 'given': ['Jane'], 'use': 'usual'},
          {'text': 'Jane Official Smith', 'use': 'official'}
        ]
      };
      final existing = UserProfile();
      final result = FhirMapper.mapPatient(json, existing);
      expect(result.name, 'Jane Official Smith');
    });

    test('mapMedicationStatement should map correctly (codeable)', () {
      final json = {
        'resourceType': 'MedicationStatement',
        'status': 'active',
        'medicationCodeableConcept': {
          'text': 'Aspirin 81mg'
        },
        'effectiveDateTime': '2023-01-01T00:00:00Z'
      };
      final result = FhirMapper.mapMedicationStatement(json);
      expect(result!.name, 'Aspirin 81mg');
      expect(result.isActive, true);
    });

    test('mapMedicationStatement should map MedicationRequest and authoredOn', () {
      final json = {
        'resourceType': 'MedicationRequest',
        'status': 'completed',
        'medicationReference': {
          'display': 'Ibuprofen'
        },
        'authoredOn': '2023-02-01'
      };
      final result = FhirMapper.mapMedicationStatement(json);
      expect(result!.name, 'Ibuprofen');
      expect(result.isActive, true);
      expect(result.startDate, DateTime(2023, 2, 1));
    });

    test('mapAllergyIntolerance should map correctly', () {
      final json = {
        'resourceType': 'AllergyIntolerance',
        'code': {'text': 'Peanuts'},
        'criticality': 'high'
      };
      final result = FhirMapper.mapAllergyIntolerance(json);
      expect(result!.allergen, 'Peanuts');
      expect(result.severity, AllergySeverity.severe);
    });

    test('mapAllergyIntolerance should fallback to substance', () {
      final json = {
        'resourceType': 'AllergyIntolerance',
        'reaction': [
          {
            'substance': {'text': 'Latex'}
          }
        ]
      };
      final result = FhirMapper.mapAllergyIntolerance(json);
      expect(result!.allergen, 'Latex');
    });

    test('mapConditionCode should handle ICD-10 and fallbacks', () {
      final json1 = {
        'code': {
          'coding': [
            {'system': 'other', 'code': 'ABC'},
            {'system': 'http://hl7.org/fhir/sid/icd-10', 'code': 'I10'}
          ]
        }
      };
      expect(FhirMapper.mapConditionCode(json1), 'I10');

      final json2 = {
        'code': {
          'coding': [{'code': 'XYZ'}]
        }
      };
      expect(FhirMapper.mapConditionCode(json2), 'XYZ');

      final json3 = {
        'code': {'text': 'Hypertension'}
      };
      expect(FhirMapper.mapConditionCode(json3), 'Hypertension');
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

    test('mapObservation should handle components', () {
      final json = {
        'resourceType': 'Observation',
        'component': [
          {
            'code': {'coding': [{'system': 'http://loinc.org', 'code': '8480-6'}]},
            'valueQuantity': {'value': 120}
          },
          {
            'code': {'coding': [{'system': 'http://loinc.org', 'code': '8462-4'}]},
            'valueQuantity': {'value': 80}
          }
        ],
        'effectiveDateTime': '2023-10-27T10:00:00Z'
      };

      final results = FhirMapper.mapObservation(json);
      expect(results.length, 2);
      expect(results.any((v) => v.type == VitalSignType.bloodPressureSystolic && v.value == 120), true);
      expect(results.any((v) => v.type == VitalSignType.bloodPressureDiastolic && v.value == 80), true);
    });

    test('_mapLoincToVitalType should handle display name fallback', () {
      final json = {
        'resourceType': 'Observation',
        'code': {
          'coding': [
            {'display': 'Body temperature'}
          ]
        },
        'valueQuantity': {'value': 36.5},
        'effectiveDateTime': '2023-10-27T10:00:00Z'
      };
      final results = FhirMapper.mapObservation(json);
      expect(results[0].type, VitalSignType.temperature);
    });
  });
}
