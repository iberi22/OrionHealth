import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/sync/application/sync_cubit.dart';
import 'package:orionhealth_health/features/sync/application/sync_state.dart';
import 'package:orionhealth_health/features/sync/domain/entities/sync_node.dart';
import 'package:orionhealth_health/features/sync/domain/services/sync_service.dart';
import 'package:orionhealth_health/features/sync/infrastructure/services/node_discovery_service.dart';

class MockSyncService extends Mock implements SyncService {}

class MockNodeDiscoveryService extends Mock implements NodeDiscoveryService {}

void main() {
  late MockSyncService service;
  late MockNodeDiscoveryService nodeDiscovery;
  late FhirSyncCubit cubit;

  setUp(() {
    service = MockSyncService();
    nodeDiscovery = MockNodeDiscoveryService();
    when(() => service.getLastSyncTime()).thenAnswer((_) async => null);
    when(
      () => nodeDiscovery.discoveredNodes,
    ).thenAnswer((_) => const Stream.empty());
    when(() => nodeDiscovery.currentNodes).thenReturn(<SyncNode>[]);
    cubit = FhirSyncCubit(service, nodeDiscovery);
  });

  tearDown(() {
    cubit.close();
  });

  group('FhirSyncCubit', () {
    test('initial state has initial status', () {
      expect(cubit.state.status, SyncPageStatus.initial);
    });

    group('performSync', () {
      test('emits loading then success on success', () async {
        final tLastSync = DateTime.now();
        when(() => service.performFullSync()).thenAnswer((_) async {});
        when(
          () => service.getLastSyncTime(),
        ).thenAnswer((_) async => tLastSync);

        final expected = [
          SyncState(status: SyncPageStatus.loading, lastSyncTime: null),
          SyncState(status: SyncPageStatus.success, lastSyncTime: tLastSync),
        ];

        expectLater(cubit.stream, emitsInOrder(expected));
        await cubit.performSync();
      });

      test('emits loading then failure on error', () async {
        when(
          () => service.performFullSync(),
        ).thenThrow(Exception('sync failed'));
        when(() => service.getLastSyncTime()).thenAnswer((_) async => null);

        final expected = [
          SyncState(status: SyncPageStatus.loading, lastSyncTime: null),
          SyncState(
            status: SyncPageStatus.failure,
            errorMessage: 'Exception: sync failed',
          ),
        ];

        expectLater(cubit.stream, emitsInOrder(expected));
        await cubit.performSync();
      });
    });

    group('SyncState', () {
      test('supports value equality', () {
        expect(
          const SyncState(status: SyncPageStatus.initial),
          const SyncState(status: SyncPageStatus.initial),
        );
        expect(
          SyncState(status: SyncPageStatus.success, lastSyncTime: DateTime(2024)),
          SyncState(status: SyncPageStatus.success, lastSyncTime: DateTime(2024)),
        );
      });

      test('copyWith preserves unchanged fields', () {
        const state = SyncState(status: SyncPageStatus.loading);
        final copied = state.copyWith();
        expect(copied.status, SyncPageStatus.loading);
      });
    });
  });
}
