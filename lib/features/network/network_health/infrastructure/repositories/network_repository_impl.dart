import 'package:injectable/injectable.dart';
import '../../domain/entities/network_health.dart';
import '../../domain/entities/network_node.dart';
import '../../domain/entities/node_stats.dart';
import '../../domain/repositories/network_repository.dart';
import '../datasources/network_datasource.dart';

@LazySingleton(as: NetworkRepository)
class NetworkRepositoryImpl implements NetworkRepository {
  final NetworkDatasource _datasource;

  NetworkRepositoryImpl(this._datasource);

  @override
  Future<NetworkHealth> getNetworkHealth() {
    return _datasource.getNetworkHealth();
  }

  @override
  Future<void> connectNode(String nodeId) {
    return _datasource.connectNode(nodeId);
  }

  @override
  Future<NodeStats> getNodeStats(String nodeId) {
    return _datasource.getNodeStats(nodeId);
  }

  @override
  Future<List<NetworkNode>> getNodes() {
    return _datasource.getNodes();
  }
}
