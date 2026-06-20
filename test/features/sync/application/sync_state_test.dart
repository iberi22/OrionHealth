import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/sync/application/sync_state.dart';
import 'package:orionhealth_health/features/sync/domain/entities/sync_node.dart';

void main() {
  group('SyncState', () {
    test('supports value equality', () {
      final lastSync = DateTime(2023, 1, 1);
      const nodes = [
        SyncNode(id: '1', name: 'Node 1', host: 'localhost', port: 8080),
      ];

      expect(
        SyncState(
          status: SyncStatus.initial,
          lastSyncTime: lastSync,
          errorMessage: 'error',
          discoveredNodes: nodes,
        ),
        SyncState(
          status: SyncStatus.initial,
          lastSyncTime: lastSync,
          errorMessage: 'error',
          discoveredNodes: nodes,
        ),
      );
    });

    test('copyWith works correctly', () {
      final lastSync = DateTime(2023, 1, 1);
      final newSync = DateTime(2023, 2, 2);
      const nodes = [
        SyncNode(id: '1', name: 'Node 1', host: 'localhost', port: 8080),
      ];
      const newNodes = [
        SyncNode(id: '2', name: 'Node 2', host: 'localhost', port: 8081),
      ];

      final state = SyncState(
        status: SyncStatus.initial,
        lastSyncTime: lastSync,
        errorMessage: 'error',
        discoveredNodes: nodes,
      );

      final updatedState = state.copyWith(
        status: SyncStatus.success,
        lastSyncTime: newSync,
        errorMessage: 'no error',
        discoveredNodes: newNodes,
      );

      expect(updatedState.status, SyncStatus.success);
      expect(updatedState.lastSyncTime, newSync);
      expect(updatedState.errorMessage, 'no error');
      expect(updatedState.discoveredNodes, newNodes);

      final partiallyUpdated = state.copyWith(status: SyncStatus.loading);
      expect(partiallyUpdated.status, SyncStatus.loading);
      expect(partiallyUpdated.lastSyncTime, lastSync);
      expect(partiallyUpdated.errorMessage, 'error');
      expect(partiallyUpdated.discoveredNodes, nodes);
    });
  });
}
