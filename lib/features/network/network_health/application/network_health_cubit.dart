import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../domain/usecases/connect_node.dart';
import '../domain/usecases/get_network_health.dart';
import '../domain/repositories/network_repository.dart';
import 'network_health_state.dart';

@injectable
class NetworkHealthCubit extends Cubit<NetworkHealthState> {
  final GetNetworkHealth _getNetworkHealth;
  final ConnectNode _connectNode;
  final NetworkRepository _repository; // Using repository directly for getNodes

  NetworkHealthCubit(
    this._getNetworkHealth,
    this._connectNode,
    this._repository,
  ) : super(const NetworkHealthState());

  Future<void> loadNetworkStatus() async {
    emit(state.copyWith(status: NetworkHealthStatus.loading));
    try {
      final health = await _getNetworkHealth();
      final nodes = await _repository.getNodes();
      emit(state.copyWith(
        status: NetworkHealthStatus.loaded,
        health: health,
        nodes: nodes,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NetworkHealthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> connectToNode(String nodeId) async {
    try {
      await _connectNode(nodeId);
      await loadNetworkStatus();
    } catch (e) {
      emit(state.copyWith(
        status: NetworkHealthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
