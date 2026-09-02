import 'dart:ffi';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:medical_standards/medical_standards.dart' as ms;
import 'package:orionhealth_health/features/sync/application/sync_cubit.dart';
import 'package:orionhealth_health/features/sync/application/sync_state.dart';
import 'package:orionhealth_health/features/sync/domain/entities/sync_node.dart';
import 'package:orionhealth_health/features/sync/domain/services/node_discovery_service.dart';
import 'package:orionhealth_health/features/sync/infrastructure/repositories/sync_repository_impl.dart';
import 'package:orionhealth_health/features/sync/infrastructure/services/fhir_client.dart';
import 'package:orionhealth_health/features/sync/infrastructure/services/sync_service_impl.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockFhirClient extends Mock implements FhirClient {}
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
class MockNodeDiscoveryService extends Mock implements NodeDiscoveryService {}
class MockMedicalStandardsSyncService extends Mock implements ms.SyncService {}

void main() {
  late SyncRepositoryImpl syncRepository;
  late SyncServiceImpl syncService;
  late MockFhirClient mockFhirClient;
  late MockFlutterSecureStorage mockSecureStorage;
  late MockNodeDiscoveryService mockDiscoveryService;
  late MockMedicalStandardsSyncService mockMedicalStandardsSync;
  late Isar isar;

  setUpAll(() async {
    await Isar.initializeIsarCore(libraries: {Abi.linuxX64: '/tmp/libisar.so'});
  });

  setUp(() async {
    mockFhirClient = MockFhirClient();
    mockSecureStorage = MockFlutterSecureStorage();
    mockDiscoveryService = MockNodeDiscoveryService();
    mockMedicalStandardsSync = MockMedicalStandardsSyncService();

    when(() => mockDiscoveryService.currentNodes).thenReturn([]);
    when(() => mockSecureStorage.read(key: 'ihce_access_token'))
        .thenAnswer((_) async => 'valid_offline_token');

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

    syncService = SyncServiceImpl(
      syncRepository,
      mockMedicalStandardsSync,
    );

    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    await isar.close();
  });

  group('Offline Unit Tests - Sync Layer', () {
    test('syncPatient graceful failure on network disconnect (SocketException)', () async {
      final profile = UserProfile(uniqueId: 'usr1', epsPatientId: 'eps_offline_1', name: 'Offline User');
      await isar.writeTxn(() => isar.collection<UserProfile>().put(profile));

      when(() => mockFhirClient.getPatient('eps_offline_1', 'token'))
          .thenThrow(const SocketException('No Internet Connection (Airplane Mode)'));

      // Should handle SocketException without crashing
      await syncRepository.syncPatient('eps_offline_1', 'token');

      final storedProfile = await isar.collection<UserProfile>().where().findFirst();
      expect(storedProfile?.name, 'Offline User');
    });

    test('syncRda graceful failure when network is unreachable', () async {
      when(() => mockFhirClient.getRDA('eps_offline_1', 'token'))
          .thenThrow(const SocketException('Failed host lookup'));

      await syncRepository.syncRda('eps_offline_1', 'token');

      expect(await isar.collection<Medication>().count(), 0);
      expect(await isar.collection<Allergy>().count(), 0);
      expect(await isar.collection<VitalSign>().count(), 0);
    });

    test('SyncServiceImpl performFullSync fallback when offline (no peer nodes)', () async {
      final profile = UserProfile(uniqueId: 'usr1', epsPatientId: 'eps_offline_1');
      await isar.writeTxn(() => isar.collection<UserProfile>().put(profile));

      when(() => mockDiscoveryService.currentNodes).thenReturn([]);
      when(() => mockMedicalStandardsSync.syncAll()).thenAnswer((_) async => []);
      when(() => mockFhirClient.getPatient(any(), any()))
          .thenAnswer((_) async => {'resourceType': 'Patient', 'id': 'eps_offline_1'});
      when(() => mockFhirClient.getRDA(any(), any()))
          .thenAnswer((_) async => {'resourceType': 'Bundle', 'entry': []});

      await syncService.performFullSync();

      // Verified fallback to default remote sync without peer IP
      verify(() => mockMedicalStandardsSync.syncAll()).called(1);
      verifyNever(() => mockMedicalStandardsSync.syncAll(peerIp: any(named: 'peerIp')));
    });

    test('SyncServiceImpl performFullSync uses peer node when online peer exists', () async {
      final profile = UserProfile(uniqueId: 'usr1', epsPatientId: 'eps_offline_1');
      await isar.writeTxn(() => isar.collection<UserProfile>().put(profile));

      const peer = SyncNode(id: 'p1', name: 'Peer 1', host: '192.168.1.50', port: 8080);
      when(() => mockDiscoveryService.currentNodes).thenReturn([peer]);
      when(() => mockMedicalStandardsSync.syncAll(peerIp: '192.168.1.50:8080'))
          .thenAnswer((_) async => []);
      when(() => mockFhirClient.getPatient(any(), any()))
          .thenAnswer((_) async => {'resourceType': 'Patient', 'id': 'eps_offline_1'});
      when(() => mockFhirClient.getRDA(any(), any()))
          .thenAnswer((_) async => {'resourceType': 'Bundle', 'entry': []});

      await syncService.performFullSync();

      verify(() => mockMedicalStandardsSync.syncAll(peerIp: '192.168.1.50:8080')).called(1);
    });

    test('FhirSyncCubit handles offline error state transitions', () async {
      final mockSyncService = MockSyncService();
      final mockDiscovery = MockNodeDiscoveryService();

      when(() => mockSyncService.getLastSyncTime()).thenAnswer((_) async => null);
      when(() => mockDiscovery.discoveredNodes).thenAnswer((_) => const Stream.empty());
      when(() => mockDiscovery.currentNodes).thenReturn([]);
      when(() => mockSyncService.performFullSync())
          .thenThrow(const SocketException('Airplane mode active'));

      final cubit = FhirSyncCubit(mockSyncService, mockDiscovery);

      expect(cubit.state.status, SyncPageStatus.initial);

      await cubit.performSync();

      expect(cubit.state.status, SyncPageStatus.failure);
      expect(cubit.state.errorMessage, contains('Airplane mode active'));

      cubit.close();
    });
  });
}

class MockSyncService extends Mock implements ms.SyncService, SyncServiceImpl {}
