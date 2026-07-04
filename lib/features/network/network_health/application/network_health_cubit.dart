import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../domain/entities/network_health.dart';
import '../domain/entities/network_node.dart';
import '../domain/repositories/network_repository.dart';

enum NetworkHealthStatus { initial, loading, loaded, error }

class NetworkHealthState extends Equatable {
  final NetworkHealth? networkHealth;
  final List<NetworkNode> nodes;
  final NetworkHealthStatus status;
  final String? errorMessage;

  const NetworkHealthState({
    this.networkHealth,
    this.nodes = const [],
    this.status = NetworkHealthStatus.initial,
    this.errorMessage,
  });

  NetworkHealthState copyWith({
    NetworkHealth? networkHealth,
    List<NetworkNode>? nodes,
    NetworkHealthStatus? status,
    String? errorMessage,
  }) {
    return NetworkHealthState(
      networkHealth: networkHealth ?? this.networkHealth,
      nodes: nodes ?? this.nodes,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [networkHealth, nodes, status, errorMessage];
}

@injectable
class NetworkHealthCubit extends Cubit<NetworkHealthState> {
  final NetworkRepository _repository;

  NetworkHealthCubit(this._repository) : super(const NetworkHealthState());

  Future<void> loadNetworkHealth() async {
    emit(state.copyWith(status: NetworkHealthStatus.loading));
    try {
      final health = await _repository.getNetworkHealth();
      final nodes = await _repository.getNodes();
      emit(state.copyWith(
        status: NetworkHealthStatus.loaded,
        networkHealth: health,
        nodes: nodes,
      ));
    } catch (e) {
      emit(state.copyWith(status: NetworkHealthStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> connectToNode(String nodeId) async {
    try {
      await _repository.connectNode(nodeId);
      await loadNetworkHealth();
    } catch (e) {
      emit(state.copyWith(status: NetworkHealthStatus.error, errorMessage: e.toString()));
    }
  }
}
