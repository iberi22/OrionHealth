import 'package:injectable/injectable.dart';
import '../../domain/entities/network_health.dart';
import '../../domain/entities/network_node.dart';
import '../../domain/entities/node_stats.dart';

abstract class NetworkDatasource {
  Future<NetworkHealth> getNetworkHealth();
  Future<void> connectNode(String nodeId);
  Future<NodeStats> getNodeStats(String nodeId);
  Future<List<NetworkNode>> getNodes();
}

@LazySingleton(as: NetworkDatasource)
class NetworkDatasourceImpl implements NetworkDatasource {
  @override
  Future<NetworkHealth> getNetworkHealth() async {
    // Mock implementation for now
    return const NetworkHealth(
      status: NetworkStatus.healthy,
      activeNodes: 42,
      totalNodes: 50,
      averageLatency: 120.5,
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
      cpuUsage: 15.5,
      memoryUsage: 450.0,
      diskUsage: 1200.0,
      uptime: const Duration(days: 5, hours: 12),
    );
  }

  @override
  Future<List<NetworkNode>> getNodes() async {
    // Mock implementation
    return [
      NetworkNode(
        id: 'node-1',
        name: 'Primary Hub',
        address: '192.168.1.100',
        status: NodeStatus.online,
        lastSeen: DateTime.now(),
      ),
      NetworkNode(
        id: 'node-2',
        name: 'Relay Alpha',
        address: '192.168.1.101',
        status: NodeStatus.online,
        lastSeen: DateTime.now(),
      ),
      NetworkNode(
        id: 'node-3',
        name: 'Storage Beta',
        address: '192.168.1.102',
        status: NodeStatus.offline,
        lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }
}
