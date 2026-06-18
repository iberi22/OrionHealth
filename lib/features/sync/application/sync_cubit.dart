import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../domain/services/sync_service.dart';
import '../domain/entities/sync_node.dart';
import '../infrastructure/services/node_discovery_service.dart';
import 'sync_state.dart';

@injectable
class FhirSyncCubit extends Cubit<SyncState> {
  final SyncService _syncService;
  final NodeDiscoveryService _nodeDiscoveryService;
  StreamSubscription? _nodesSubscription;

  FhirSyncCubit(this._syncService, this._nodeDiscoveryService) : super(const SyncState()) {
    _loadLastSyncTime();
    _listenToDiscoveredNodes();
  }

  Future<void> _loadLastSyncTime() async {
    final lastSync = await _syncService.getLastSyncTime();
    emit(state.copyWith(lastSyncTime: lastSync));
  }

  void _listenToDiscoveredNodes() {
    _nodesSubscription?.cancel();
    _nodesSubscription = _nodeDiscoveryService.discoveredNodes.listen((bonsoirNodes) {
      final syncNodes = bonsoirNodes.map((node) => SyncNode(
        id: node.attributes['nodeId'] ?? node.name,
        name: node.name,
        host: node.hostname ?? 'unknown',
        port: node.port,
      )).toList();
      emit(state.copyWith(discoveredNodes: syncNodes));
    });

    // Initial nodes
    final initialNodes = _nodeDiscoveryService.currentNodes.map((node) => SyncNode(
      id: node.attributes['nodeId'] ?? node.name,
      name: node.name,
      host: node.hostname ?? 'unknown',
      port: node.port,
    )).toList();
    if (initialNodes.isNotEmpty) {
      emit(state.copyWith(discoveredNodes: initialNodes));
    }
  }

  Future<void> performSync() async {
    emit(state.copyWith(status: SyncStatus.loading));
    try {
      await _syncService.performFullSync();
      final lastSync = await _syncService.getLastSyncTime();
      emit(state.copyWith(
        status: SyncStatus.success,
        lastSyncTime: lastSync,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SyncStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    _nodesSubscription?.cancel();
    return super.close();
  }
}
