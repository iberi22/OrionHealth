import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/sync/domain/repositories/sync_repository.dart';
import 'package:orionhealth_health/features/sync/domain/entities/sync_node.dart';

class MockSyncRepository extends Mock implements SyncRepository {}

void main() {
  late SyncRepository repository;

  setUp(() {
    repository = MockSyncRepository();
  });

  group('SyncRepository Domain Interface Smoke Test', () {
    test('getAccessToken smoke test', () async {
      when(() => repository.getAccessToken()).thenAnswer((_) async => 'fake_token');
      final result = await repository.getAccessToken();
      expect(result, 'fake_token');
      verify(() => repository.getAccessToken()).called(1);
    });

    test('saveAccessToken smoke test', () async {
      when(() => repository.saveAccessToken(any())).thenAnswer((_) async {});
      await repository.saveAccessToken('new_token');
      verify(() => repository.saveAccessToken('new_token')).called(1);
    });

    test('getLastSyncTime smoke test', () async {
      final now = DateTime.now();
      when(() => repository.getLastSyncTime()).thenAnswer((_) async => now);
      final result = await repository.getLastSyncTime();
      expect(result, now);
      verify(() => repository.getLastSyncTime()).called(1);
    });

    test('syncAll smoke test', () async {
      when(() => repository.syncAll()).thenAnswer((_) async {});
      await repository.syncAll();
      verify(() => repository.syncAll()).called(1);
    });

    test('syncIfStale smoke test', () async {
      when(() => repository.syncIfStale()).thenAnswer((_) async => true);
      final result = await repository.syncIfStale();
      expect(result, isTrue);
      verify(() => repository.syncIfStale()).called(1);
    });

    test('getDiscoveredNodes smoke test', () async {
      final nodes = [
        const SyncNode(id: 'node1', name: 'Node 1', host: 'localhost', port: 8080),
      ];
      when(() => repository.getDiscoveredNodes()).thenAnswer((_) async => nodes);
      final result = await repository.getDiscoveredNodes();
      expect(result, nodes);
      verify(() => repository.getDiscoveredNodes()).called(1);
    });
  });
}
