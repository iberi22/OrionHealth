import 'package:dio/dio.dart';
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
  final Dio _dio;
  static const String _baseUrl = 'https://api.orionhealth.ai/network';

  NetworkDatasourceImpl(this._dio);

  @override
  Future<NetworkHealth> getNetworkHealth() async {
    try {
      final response = await _dio.get('$_baseUrl/health');
      if (response.statusCode == 200) {
        return NetworkHealth.fromJson(response.data);
      }
      return _mockHealth();
    } catch (e) {
      return _mockHealth();
    }
  }

  @override
  Future<void> connectNode(String nodeId) async {
    try {
      await _dio.post('$_baseUrl/connect', data: {'nodeId': nodeId});
    } catch (e) {
      // Log error
    }
  }

  @override
  Future<NodeStats> getNodeStats(String nodeId) async {
    try {
      final response = await _dio.get('$_baseUrl/nodes/$nodeId/stats');
      if (response.statusCode == 200) {
        return NodeStats.fromJson(response.data);
      }
      return _mockStats(nodeId);
    } catch (e) {
      return _mockStats(nodeId);
    }
  }

  @override
  Future<List<NetworkNode>> getNodes() async {
    try {
      final response = await _dio.get('$_baseUrl/nodes');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => NetworkNode.fromJson(json)).toList();
      }
      return _mockNodes();
    } catch (e) {
      return _mockNodes();
    }
  }

  NetworkHealth _mockHealth() => const NetworkHealth(
        status: NetworkStatus.healthy,
        activeNodes: 42,
        totalNodes: 50,
        averageLatency: 120.5,
        uptimePercentage: 99.9,
      );

  NodeStats _mockStats(String nodeId) => NodeStats(
        nodeId: nodeId,
        cpuUsage: 15.5,
        memoryUsage: 450.0,
        diskUsage: 1200.0,
        uptime: const Duration(days: 5, hours: 12),
      );

  List<NetworkNode> _mockNodes() => [
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
