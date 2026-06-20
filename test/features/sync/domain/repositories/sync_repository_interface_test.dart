import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/sync/domain/repositories/sync_repository.dart';
import 'package:orionhealth_health/features/sync/domain/entities/sync_node.dart';

class MockSyncRepository extends Mock implements SyncRepository {}

void main() {
  late MockSyncRepository mockSyncRepository;

  setUp(() {
    mockSyncRepository = MockSyncRepository();
  });

  group('SyncRepository interface', () {
    test('getAccessToken returns token', () async {
      when(() => mockSyncRepository.getAccessToken()).thenAnswer((_) async => 'fake_token');
      final result = await mockSyncRepository.getAccessToken();
      expect(result, 'fake_token');
    });

    test('saveAccessToken saves token', () async {
      when(() => mockSyncRepository.saveAccessToken(any())).thenAnswer((_) async => {});
      await mockSyncRepository.saveAccessToken('new_token');
      verify(() => mockSyncRepository.saveAccessToken('new_token')).called(1);
    });

    test('getLastSyncTime returns time', () async {
      final now = DateTime.now();
      when(() => mockSyncRepository.getLastSyncTime()).thenAnswer((_) async => now);
      final result = await mockSyncRepository.getLastSyncTime();
      expect(result, now);
    });

    test('syncAll performs sync', () async {
      when(() => mockSyncRepository.syncAll()).thenAnswer((_) async => {});
      await mockSyncRepository.syncAll();
      verify(() => mockSyncRepository.syncAll()).called(1);
    });

    test('syncIfStale returns boolean', () async {
      when(() => mockSyncRepository.syncIfStale()).thenAnswer((_) async => true);
      final result = await mockSyncRepository.syncIfStale();
      expect(result, isTrue);
    });

    test('getDiscoveredNodes returns list of nodes', () {
      final nodes = [
        const SyncNode(id: '1', name: 'Node 1', host: 'localhost', port: 8080),
      ];
      when(() => mockSyncRepository.getDiscoveredNodes()).thenReturn(nodes);
      final result = mockSyncRepository.getDiscoveredNodes();
      expect(result, nodes);
    });
  });
}
