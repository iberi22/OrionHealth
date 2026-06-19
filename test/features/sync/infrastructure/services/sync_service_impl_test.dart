import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/sync/infrastructure/services/sync_service_impl.dart';
import 'package:orionhealth_health/features/sync/domain/repositories/sync_repository.dart';
import 'package:medical_standards/medical_standards.dart' as ms;
import 'package:orionhealth_health/features/sync/domain/entities/sync_node.dart';

class MockSyncRepository extends Mock implements SyncRepository {}
class MockMedicalStandardsSyncService extends Mock implements ms.SyncService {}

void main() {
  late SyncServiceImpl syncService;
  late MockSyncRepository mockSyncRepository;
  late MockMedicalStandardsSyncService mockMedicalStandardsSyncService;

  setUp(() {
    mockSyncRepository = MockSyncRepository();
    mockMedicalStandardsSyncService = MockMedicalStandardsSyncService();
    syncService = SyncServiceImpl(mockSyncRepository, mockMedicalStandardsSyncService);
  });

  group('SyncServiceImpl', () {
    test('performFullSync performs sync with medical standards fallback to remote', () async {
      when(() => mockSyncRepository.getDiscoveredNodes()).thenAnswer((_) async => []);
      when(() => mockMedicalStandardsSyncService.syncAll(peerIp: any(named: 'peerIp')))
          .thenAnswer((_) async => <ms.SyncResult>[]);
      when(() => mockSyncRepository.syncAll()).thenAnswer((_) async => {});

      await syncService.performFullSync();

      verify(() => mockMedicalStandardsSyncService.syncAll()).called(1);
      verify(() => mockSyncRepository.syncAll()).called(1);
    });

    test('performFullSync performs sync with medical standards using peer IP', () async {
      final nodes = [
        const SyncNode(id: '1', name: 'Node 1', host: '192.168.1.1', port: 8080),
      ];
      when(() => mockSyncRepository.getDiscoveredNodes()).thenAnswer((_) async => nodes);
      when(() => mockMedicalStandardsSyncService.syncAll(peerIp: any(named: 'peerIp')))
          .thenAnswer((_) async => <ms.SyncResult>[]);
      when(() => mockSyncRepository.syncAll()).thenAnswer((_) async => {});

      await syncService.performFullSync();

      verify(() => mockMedicalStandardsSyncService.syncAll(peerIp: '192.168.1.1:8080')).called(1);
      verify(() => mockSyncRepository.syncAll()).called(1);
    });

    test('getLastSyncTime returns time from repository', () async {
      final now = DateTime.now();
      when(() => mockSyncRepository.getLastSyncTime()).thenAnswer((_) async => now);

      final result = await syncService.getLastSyncTime();

      expect(result, equals(now));
      verify(() => mockSyncRepository.getLastSyncTime()).called(1);
    });
  });
}
