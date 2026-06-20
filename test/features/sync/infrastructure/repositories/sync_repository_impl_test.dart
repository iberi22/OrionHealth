import 'package:bonsoir/bonsoir.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/sync/infrastructure/services/fhir_client.dart';
import 'package:orionhealth_health/features/sync/infrastructure/repositories/sync_repository.dart';
import 'package:orionhealth_health/features/sync/infrastructure/services/node_discovery_service.dart';
import 'package:orionhealth_health/features/sync/domain/repositories/sync_repository.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class MockFhirClient extends Mock implements FhirClient {}
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
class MockNodeDiscoveryService extends Mock implements NodeDiscoveryService {}
class MockBonsoirService extends Mock implements BonsoirService {}

void main() {
  late SyncRepository syncRepository;
  late MockFhirClient mockFhirClient;
  late MockFlutterSecureStorage mockSecureStorage;
  late MockNodeDiscoveryService mockDiscoveryService;
  late Isar isar;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    mockFhirClient = MockFhirClient();
    mockSecureStorage = MockFlutterSecureStorage();
    mockDiscoveryService = MockNodeDiscoveryService();
    when(() => mockDiscoveryService.currentNodes).thenReturn([]);

    final tempDir = await Directory.systemTemp.createTemp();
    isar = await Isar.open(
      [UserProfileSchema, MedicationSchema, AllergySchema, VitalSignSchema],
      directory: tempDir.path,
    );

    syncRepository = SyncRepositoryImpl(
      mockFhirClient,
      isar,
      mockSecureStorage,
      mockDiscoveryService,
    );

    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    await isar.close();
  });

  group('SyncRepositoryImpl', () {
    test('getAccessToken returns token from secure storage', () async {
      when(() => mockSecureStorage.read(key: 'ihce_access_token'))
          .thenAnswer((_) async => 'fake_token');

      final result = await syncRepository.getAccessToken();

      expect(result, 'fake_token');
    });

    test('saveAccessToken writes token to secure storage', () async {
      when(() => mockSecureStorage.write(
            key: 'ihce_access_token',
            value: any(named: 'value'),
          )).thenAnswer((_) async {});

      await syncRepository.saveAccessToken('new_token');

      verify(() => mockSecureStorage.write(
            key: 'ihce_access_token',
            value: 'new_token',
          )).called(1);
    });

    test('getLastSyncTime returns null when no timestamp is saved', () async {
      final result = await syncRepository.getLastSyncTime();
      expect(result, isNull);
    });

    test('getLastSyncTime/setLastSyncTime correctly persists timestamp', () async {
      final now = DateTime.now();
      // Round to milliseconds since that's how it's stored
      final nowMs = DateTime.fromMillisecondsSinceEpoch(now.millisecondsSinceEpoch);

      await syncRepository.setLastSyncTime(nowMs);
      final result = await syncRepository.getLastSyncTime();

      expect(result, nowMs);
    });

    test('getDiscoveredNodes returns mapped nodes from discovery service', () async {
      final mockNode = MockBonsoirService();
      when(() => mockNode.name).thenReturn('Node1');
      when(() => mockNode.hostname).thenReturn('192.168.1.5');
      when(() => mockNode.port).thenReturn(9124);
      when(() => mockNode.attributes).thenReturn({'nodeId': 'id123'});

      when(() => mockDiscoveryService.currentNodes).thenReturn([mockNode]);

      final result = await syncRepository.getDiscoveredNodes();

      expect(result.length, 1);
      expect(result.first.id, 'id123');
      expect(result.first.name, 'Node1');
      expect(result.first.host, '192.168.1.5');
      expect(result.first.port, 9124);
    });

    test('syncPatient updates user profile in Isar', () async {
      // Setup existing profile
      final profile = UserProfile(uniqueId: 'user1', epsPatientId: 'eps123', name: 'Old Name');
      await isar.writeTxn(() => isar.userProfiles.put(profile));

      final patientData = {
        'resourceType': 'Patient',
        'id': 'eps123',
        'name': [
          {
            'given': ['New'],
            'family': 'Name'
          }
        ]
      };

      when(() => mockFhirClient.getPatient('eps123', 'token'))
          .thenAnswer((_) async => patientData);

      await syncRepository.syncPatient('eps123', 'token');

      final updatedProfile = await isar.userProfiles.where().findFirst();
      expect(updatedProfile?.name, 'New Name');
    });

    test('syncAll coordinates patient and rda sync', () async {
      // Setup profile with token
      final profile = UserProfile(uniqueId: 'user1', epsPatientId: 'eps123');
      await isar.writeTxn(() => isar.userProfiles.put(profile));

      when(() => mockSecureStorage.read(key: 'ihce_access_token'))
          .thenAnswer((_) async => 'token');

      when(() => mockFhirClient.getPatient(any(), any()))
          .thenAnswer((_) async => {'resourceType': 'Patient', 'id': 'eps123'});

      when(() => mockFhirClient.getRDA(any(), any()))
          .thenAnswer((_) async => {'resourceType': 'Bundle', 'entry': []});

      await syncRepository.syncAll();

      verify(() => mockFhirClient.getPatient('eps123', 'token')).called(1);
      verify(() => mockFhirClient.getRDA('eps123', 'token')).called(1);
    });


    test('syncRda should not create duplicate medications', () async {
      // Setup
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

      when(() => mockFhirClient.getRDA(any(), any()))
          .thenAnswer((_) async => rdaBundle);

      // Perform first sync
      await syncRepository.syncRda('pat123', 'fake_token');
      expect(await isar.medications.count(), 1);

      // Perform second sync with same data
      await syncRepository.syncRda('pat123', 'fake_token');
      expect(await isar.medications.count(), 1, reason: 'Should not create duplicate medication');
    });

    test('syncRda should update existing medication if data changed', () async {
      // Setup
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

      when(() => mockFhirClient.getRDA(any(), any())).thenAnswer((_) async => rdaBundle1);

      await syncRepository.syncRda('pat123', 'fake_token');
      var med = await isar.medications.where().findFirst();
      expect(med?.notes, 'Initial note');

      // Second sync with updated note
      final medicationJson2 = Map<String, dynamic>.from(medicationJson1);
      medicationJson2['note'] = [{'text': 'Updated note'}];
      final rdaBundle2 = Map<String, dynamic>.from(rdaBundle1);
      rdaBundle2['entry'][1]['resource'] = medicationJson2;

      when(() => mockFhirClient.getRDA(any(), any())).thenAnswer((_) async => rdaBundle2);

      await syncRepository.syncRda('pat123', 'fake_token');

      expect(await isar.medications.count(), 1);
      med = await isar.medications.where().findFirst();
      expect(med?.notes, 'Updated note');
    });

    test('syncRda should not duplicate vitals with same type and timestamp', () async {
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

      when(() => mockFhirClient.getRDA(any(), any())).thenAnswer((_) async => rdaBundle);

      await syncRepository.syncRda('pat123', 'fake_token');
      expect(await isar.vitalSigns.count(), 1);

      await syncRepository.syncRda('pat123', 'fake_token');
      expect(await isar.vitalSigns.count(), 1);
    });
  });
}
