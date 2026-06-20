import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/sync/domain/repositories/sync_repository.dart';
import 'package:orionhealth_health/features/sync/domain/entities/sync_node.dart';

class MockSyncRepository extends Mock implements SyncRepository {}

void main() {
  group('SyncRepository Interface', () {
    late MockSyncRepository mockSyncRepository;

    setUp(() {
      mockSyncRepository = MockSyncRepository();
    });

    test('getAccessToken signature verification', () async {
      when(() => mockSyncRepository.getAccessToken()).thenAnswer((_) async => 'token');
      final result = await mockSyncRepository.getAccessToken();
      expect(result, 'token');
    });

    test('saveAccessToken signature verification', () async {
      when(() => mockSyncRepository.saveAccessToken(any())).thenAnswer((_) async => {});
      await mockSyncRepository.saveAccessToken('token');
      verify(() => mockSyncRepository.saveAccessToken('token')).called(1);
    });

    test('getLastSyncTime signature verification', () async {
      final now = DateTime.now();
      when(() => mockSyncRepository.getLastSyncTime()).thenAnswer((_) async => now);
      final result = await mockSyncRepository.getLastSyncTime();
      expect(result, now);
    });

    test('syncAll signature verification', () async {
      when(() => mockSyncRepository.syncAll()).thenAnswer((_) async => {});
      await mockSyncRepository.syncAll();
      verify(() => mockSyncRepository.syncAll()).called(1);
    });

    test('syncIfStale signature verification', () async {
      when(() => mockSyncRepository.syncIfStale()).thenAnswer((_) async => true);
      final result = await mockSyncRepository.syncIfStale();
      expect(result, isTrue);
    });

    test('getDiscoveredNodes signature verification', () async {
      final nodes = [const SyncNode(id: '1', name: 'Node 1', host: 'localhost', port: 8080)];
      when(() => mockSyncRepository.getDiscoveredNodes()).thenAnswer((_) async => nodes);
      final result = await mockSyncRepository.getDiscoveredNodes();
      expect(result, nodes);
    });
  });
}
