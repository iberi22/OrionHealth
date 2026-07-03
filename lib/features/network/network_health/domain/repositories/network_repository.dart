import '../entities/network_health.dart';
import '../entities/node_stats.dart';
import '../entities/network_node.dart';

abstract class NetworkRepository {
  Future<NetworkHealth> getNetworkHealth();
  Future<void> connectNode(String nodeId);
  Future<NodeStats> getNodeStats(String nodeId);
  Future<List<NetworkNode>> getNodes();
}
