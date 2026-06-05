import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/sync/data/fhir_client.dart';
import 'package:orionhealth_health/features/sync/data/sync_repository.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class MockFhirClient extends Mock implements FhirClient {}
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late SyncRepository syncRepository;
  late MockFhirClient mockFhirClient;
  late MockFlutterSecureStorage mockSecureStorage;
  late Isar isar;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    mockFhirClient = MockFhirClient();
    mockSecureStorage = MockFlutterSecureStorage();

    final tempDir = await Directory.systemTemp.createTemp();
    isar = await Isar.open(
      [UserProfileSchema, MedicationSchema, AllergySchema, VitalSignSchema],
      directory: tempDir.path,
    );

    syncRepository = SyncRepository(
      mockFhirClient,
      isar,
      mockSecureStorage,
    );

    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    await isar.close();
  });

  group('SyncRepository Conflict Resolution', () {
    test('syncAll should not create duplicate medications', () async {
      // Setup
      when(() => mockSecureStorage.read(key: 'ihce_access_token'))
          .thenAnswer((_) async => 'fake_token');

      await isar.writeTxn(() async {
        await isar.userProfiles.put(UserProfile(epsPatientId: 'pat123'));
      });

      final medicationJson = {
        'resourceType': 'MedicationStatement',
        'status': 'active',
        'medicationCodeableConcept': {'text': 'Ibuprofeno'},
        'effectiveDateTime': '2023-10-27T10:00:00Z'
      };

      final rdaBundle = {
        'resourceType': 'Bundle',
        'entry': [
          {
            'resource': {
              'resourceType': 'Composition',
              'id': 'comp1',
              'section': [
                {
                  'title': 'Medications',
                  'entry': [
                    {'reference': 'MedicationStatement/1'}
                  ]
                }
              ]
            }
          },
          {
            'fullUrl': 'MedicationStatement/1',
            'resource': medicationJson
          }
        ]
      };

      when(() => mockFhirClient.getPatient(any(), any()))
          .thenAnswer((_) async => {'resourceType': 'Patient', 'id': 'pat123'});
      when(() => mockFhirClient.getRDA(any(), any()))
          .thenAnswer((_) async => rdaBundle);

      // Perform first sync
      await syncRepository.syncAll();
      expect(await isar.medications.count(), 1);

      // Perform second sync with same data
      await syncRepository.syncAll();
      expect(await isar.medications.count(), 1, reason: 'Should not create duplicate medication');
    });

    test('syncAll should update existing medication if data changed', () async {
      // Setup
      when(() => mockSecureStorage.read(key: 'ihce_access_token'))
          .thenAnswer((_) async => 'fake_token');

      await isar.writeTxn(() async {
        await isar.userProfiles.put(UserProfile(epsPatientId: 'pat123'));
      });

      final medicationJson1 = {
        'resourceType': 'MedicationStatement',
        'status': 'active',
        'medicationCodeableConcept': {'text': 'Ibuprofeno'},
        'effectiveDateTime': '2023-10-27T10:00:00Z',
        'note': [{'text': 'Initial note'}]
      };

      final rdaBundle1 = {
        'resourceType': 'Bundle',
        'entry': [
          {
            'resource': {
              'resourceType': 'Composition',
              'id': 'comp1',
              'section': [{'title': 'Meds', 'entry': [{'reference': 'MedicationStatement/1'}]}]
            }
          },
          {'fullUrl': 'MedicationStatement/1', 'resource': medicationJson1}
        ]
      };

      when(() => mockFhirClient.getPatient(any(), any())).thenAnswer((_) async => {});
      when(() => mockFhirClient.getRDA(any(), any())).thenAnswer((_) async => rdaBundle1);

      await syncRepository.syncAll();
      var med = await isar.medications.where().findFirst();
      expect(med?.notes, 'Initial note');

      // Second sync with updated note
      final medicationJson2 = Map<String, dynamic>.from(medicationJson1);
      medicationJson2['note'] = [{'text': 'Updated note'}];
      final rdaBundle2 = Map<String, dynamic>.from(rdaBundle1);
      rdaBundle2['entry'][1]['resource'] = medicationJson2;

      when(() => mockFhirClient.getRDA(any(), any())).thenAnswer((_) async => rdaBundle2);

      await syncRepository.syncAll();

      expect(await isar.medications.count(), 1);
      med = await isar.medications.where().findFirst();
      expect(med?.notes, 'Updated note');
    });

    test('syncAll should not duplicate vitals with same type and timestamp', () async {
       when(() => mockSecureStorage.read(key: 'ihce_access_token'))
          .thenAnswer((_) async => 'fake_token');

      await isar.writeTxn(() async {
        await isar.userProfiles.put(UserProfile(epsPatientId: 'pat123'));
      });

      final observationJson = {
        'resourceType': 'Observation',
        'code': {
          'coding': [{'system': 'http://loinc.org', 'code': '8867-4'}]
        },
        'valueQuantity': {'value': 80, 'unit': 'bpm'},
        'effectiveDateTime': '2023-10-27T10:00:00Z'
      };

      final rdaBundle = {
        'resourceType': 'Bundle',
        'entry': [
          {
            'resource': {
              'resourceType': 'Composition',
              'section': [{'title': 'Vitals', 'entry': [{'reference': 'Observation/1'}]}]
            }
          },
          {'fullUrl': 'Observation/1', 'resource': observationJson}
        ]
      };

      when(() => mockFhirClient.getPatient(any(), any())).thenAnswer((_) async => {});
      when(() => mockFhirClient.getRDA(any(), any())).thenAnswer((_) async => rdaBundle);

      await syncRepository.syncAll();
      expect(await isar.vitalSigns.count(), 1);

      await syncRepository.syncAll();
      expect(await isar.vitalSigns.count(), 1);
    });
  });
}
