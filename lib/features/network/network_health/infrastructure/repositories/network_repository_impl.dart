import 'package:injectable/injectable.dart';
import '../../domain/entities/network_health.dart';
import '../../domain/entities/network_node.dart';
import '../../domain/entities/node_stats.dart';
import '../../domain/repositories/network_repository.dart';

@LazySingleton(as: NetworkRepository)
class NetworkRepositoryImpl implements NetworkRepository {
  @override
  Future<NetworkHealth> getNetworkHealth() async {
    // Mock implementation for now as we are focusing on application/presentation
    return const NetworkHealth(
      status: NetworkStatus.healthy,
      activeNodes: 12,
      totalNodes: 15,
      averageLatency: 45.0,
      uptimePercentage: 99.9,
    );
  }

  @override
  Future<void> connectNode(String nodeId) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<NodeStats> getNodeStats(String nodeId) async {
    // Mock implementation
    return NodeStats(
      nodeId: nodeId,
      cpuUsage: 0.5,
      memoryUsage: 0.6,
      diskUsage: 0.7,
      uptime: const Duration(days: 1),
    );
  }

  @override
  Future<List<NetworkNode>> getNodes() async {
    // Mock implementation
    return [
      NetworkNode(
        id: '1',
        name: 'Primary Node',
        address: '192.168.1.1',
        status: NodeStatus.online,
        lastSeen: DateTime.now(),
      ),
      NetworkNode(
        id: '2',
        name: 'Secondary Node',
        address: '192.168.1.2',
        status: NodeStatus.online,
        lastSeen: DateTime.now(),
      ),
    ];
  }
}
