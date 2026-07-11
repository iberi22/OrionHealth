import 'package:equatable/equatable.dart';
import '../domain/entities/sync_node.dart';

enum SyncPageStatus { initial, loading, success, failure }

class SyncState extends Equatable {
  final SyncPageStatus status;
  final DateTime? lastSyncTime;
  final String? errorMessage;
  final List<SyncNode> discoveredNodes;

  const SyncState({
    this.status = SyncPageStatus.initial,
    this.lastSyncTime,
    this.errorMessage,
    this.discoveredNodes = const [],
  });

  SyncState copyWith({
    SyncPageStatus? status,
    DateTime? lastSyncTime,
    String? errorMessage,
    List<SyncNode>? discoveredNodes,
  }) {
    return SyncState(
      status: status ?? this.status,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      errorMessage: errorMessage ?? this.errorMessage,
      discoveredNodes: discoveredNodes ?? this.discoveredNodes,
    );
  }

  @override
  List<Object?> get props => [status, lastSyncTime, errorMessage, discoveredNodes];
}
