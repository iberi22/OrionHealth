import 'package:equatable/equatable.dart';
import '../domain/entities/network_health.dart';
import '../domain/entities/network_node.dart';

enum NetworkHealthStatus { initial, loading, loaded, error }

class NetworkHealthState extends Equatable {
  final NetworkHealthStatus status;
  final NetworkHealth? health;
  final List<NetworkNode> nodes;
  final String? errorMessage;

  const NetworkHealthState({
    this.status = NetworkHealthStatus.initial,
    this.health,
    this.nodes = const [],
    this.errorMessage,
  });

  NetworkHealthState copyWith({
    NetworkHealthStatus? status,
    NetworkHealth? health,
    List<NetworkNode>? nodes,
    String? errorMessage,
  }) {
    return NetworkHealthState(
      status: status ?? this.status,
      health: health ?? this.health,
      nodes: nodes ?? this.nodes,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, health, nodes, errorMessage];
}
