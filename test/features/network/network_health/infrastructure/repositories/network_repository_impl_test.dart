import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/network/network_health/domain/entities/network_health.dart';
import 'package:orionhealth_health/features/network/network_health/domain/entities/network_node.dart';
import 'package:orionhealth_health/features/network/network_health/domain/entities/node_stats.dart';
import 'package:orionhealth_health/features/network/network_health/infrastructure/datasources/network_datasource.dart';
import 'package:orionhealth_health/features/network/network_health/infrastructure/repositories/network_repository_impl.dart';

class MockNetworkDatasource extends Mock implements NetworkDatasource {}

void main() {
  late NetworkRepositoryImpl repository;
  late MockNetworkDatasource mockDatasource;

  setUp(() {
    mockDatasource = MockNetworkDatasource();
    repository = NetworkRepositoryImpl(mockDatasource);
  });

  group('NetworkRepositoryImpl', () {
    test('getNetworkHealth delegates to datasource', () async {
      const health = NetworkHealth(status: NetworkStatus.healthy, activeNodes: 1, totalNodes: 1, averageLatency: 1, uptimePercentage: 1);
      when(() => mockDatasource.getNetworkHealth()).thenAnswer((_) async => health);

      final result = await repository.getNetworkHealth();

      expect(result, health);
      verify(() => mockDatasource.getNetworkHealth()).called(1);
    });

    test('connectNode delegates to datasource', () async {
      when(() => mockDatasource.connectNode(any())).thenAnswer((_) async {});

      await repository.connectNode('node-1');

      verify(() => mockDatasource.connectNode('node-1')).called(1);
    });

    test('getNodeStats delegates to datasource', () async {
      final stats = NodeStats(nodeId: 'node-1', cpuUsage: 1, memoryUsage: 1, diskUsage: 1, uptime: Duration.zero);
      when(() => mockDatasource.getNodeStats(any())).thenAnswer((_) async => stats);

      final result = await repository.getNodeStats('node-1');

      expect(result, stats);
      verify(() => mockDatasource.getNodeStats('node-1')).called(1);
    });

    test('getNodes delegates to datasource', () async {
      final nodes = [NetworkNode(id: '1', name: 'n1', address: 'a', status: NodeStatus.online, lastSeen: DateTime.now())];
      when(() => mockDatasource.getNodes()).thenAnswer((_) async => nodes);

      final result = await repository.getNodes();

      expect(result, nodes);
      verify(() => mockDatasource.getNodes()).called(1);
    });
  });
}
