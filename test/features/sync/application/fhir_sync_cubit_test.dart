import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/sync/application/sync_cubit.dart';
import 'package:orionhealth_health/features/sync/application/sync_state.dart';
import 'package:orionhealth_health/features/sync/domain/entities/sync_node.dart';
import 'package:orionhealth_health/features/sync/domain/services/sync_service.dart';
import 'package:orionhealth_health/features/sync/domain/services/node_discovery_service.dart';

class MockSyncService extends Mock implements SyncService {}
class MockNodeDiscoveryService extends Mock implements NodeDiscoveryService {}

void main() {
  late FhirSyncCubit cubit;
  late MockSyncService mockSyncService;
  late MockNodeDiscoveryService mockNodeDiscoveryService;
  late StreamController<List<SyncNode>> nodesController;

  setUp(() {
    mockSyncService = MockSyncService();
    mockNodeDiscoveryService = MockNodeDiscoveryService();
    nodesController = StreamController<List<SyncNode>>.broadcast();

    when(() => mockSyncService.getLastSyncTime()).thenAnswer((_) async => null);
    when(() => mockNodeDiscoveryService.discoveredNodes).thenAnswer((_) => nodesController.stream);
    when(() => mockNodeDiscoveryService.currentNodes).thenReturn([]);

    cubit = FhirSyncCubit(mockSyncService, mockNodeDiscoveryService);
  });

  tearDown(() {
    nodesController.close();
    cubit.close();
  });

  test('initial state is correct', () {
    expect(cubit.state, const SyncState());
  });

  test('loads last sync time on initialization', () async {
    final lastSync = DateTime(2023, 1, 1);
    when(() => mockSyncService.getLastSyncTime()).thenAnswer((_) async => lastSync);

    // Re-initialize to trigger constructor logic with the new mock value
    cubit = FhirSyncCubit(mockSyncService, mockNodeDiscoveryService);

    await Future.delayed(Duration.zero);
    expect(cubit.state.lastSyncTime, lastSync);
  });

  test('updates discovered nodes when service emits new nodes', () async {
    final nodes = [
      const SyncNode(id: '1', name: 'Node 1', host: '192.168.1.1', port: 8080),
    ];

    nodesController.add(nodes);

    await Future.delayed(Duration.zero);
    expect(cubit.state.discoveredNodes, nodes);
  });

  test('performSync updates status to success on completion', () async {
    when(() => mockSyncService.performFullSync()).thenAnswer((_) async {});
    final lastSync = DateTime.now();
    when(() => mockSyncService.getLastSyncTime()).thenAnswer((_) async => lastSync);

    await cubit.performSync();

    expect(cubit.state.status, SyncStatus.success);
    expect(cubit.state.lastSyncTime, lastSync);
  });

  test('performSync updates status to failure on error', () async {
    when(() => mockSyncService.performFullSync()).thenThrow(Exception('Sync failed'));

    await cubit.performSync();

    expect(cubit.state.status, SyncStatus.failure);
    expect(cubit.state.errorMessage, 'Exception: Sync failed');
  });
}
