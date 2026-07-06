import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/network/network_health/domain/entities/network_health.dart';
import 'package:orionhealth_health/features/network/network_health/infrastructure/datasources/network_datasource.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late NetworkDatasourceImpl datasource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    datasource = NetworkDatasourceImpl(mockDio);
  });

  group('NetworkDatasourceImpl', () {
    const baseUrl = 'https://api.orionhealth.ai/network';

    test('getNetworkHealth returns data from API on success', () async {
      final mockData = {
        'status': 'healthy',
        'activeNodes': 10,
        'totalNodes': 12,
        'averageLatency': 50.0,
        'uptimePercentage': 99.0
      };

      when(() => mockDio.get('$baseUrl/health'))
          .thenAnswer((_) async => Response(
                data: mockData,
                statusCode: 200,
                requestOptions: RequestOptions(path: '$baseUrl/health'),
              ));

      final result = await datasource.getNetworkHealth();
      expect(result.status, NetworkStatus.healthy);
      expect(result.activeNodes, 10);
    });

    test('getNetworkHealth returns mock data on error', () async {
      when(() => mockDio.get('$baseUrl/health'))
          .thenThrow(DioException(requestOptions: RequestOptions(path: '$baseUrl/health')));

      final result = await datasource.getNetworkHealth();
      expect(result.activeNodes, 42); // Mock value
    });

    test('connectNode calls API', () async {
      when(() => mockDio.post('$baseUrl/connect', data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                statusCode: 200,
                requestOptions: RequestOptions(path: '$baseUrl/connect'),
              ));

      await datasource.connectNode('node-1');

      verify(() => mockDio.post('$baseUrl/connect', data: {'nodeId': 'node-1'})).called(1);
    });

    test('getNodeStats returns data from API on success', () async {
      final mockData = {
        'nodeId': 'node-1',
        'cpuUsage': 20.0,
        'memoryUsage': 1000.0,
        'diskUsage': 5000.0,
        'uptimeSeconds': 3600
      };

      when(() => mockDio.get('$baseUrl/nodes/node-1/stats'))
          .thenAnswer((_) async => Response(
                data: mockData,
                statusCode: 200,
                requestOptions: RequestOptions(path: '$baseUrl/nodes/node-1/stats'),
              ));

      final result = await datasource.getNodeStats('node-1');
      expect(result.nodeId, 'node-1');
      expect(result.cpuUsage, 20.0);
    });

    test('getNodes returns data from API on success', () async {
      final mockData = [
        {
          'id': 'node-1',
          'name': 'Node 1',
          'address': '1.1.1.1',
          'status': 'online',
          'lastSeen': DateTime.now().toIso8601String()
        }
      ];

      when(() => mockDio.get('$baseUrl/nodes'))
          .thenAnswer((_) async => Response(
                data: mockData,
                statusCode: 200,
                requestOptions: RequestOptions(path: '$baseUrl/nodes'),
              ));

      final result = await datasource.getNodes();
      expect(result, hasLength(1));
      expect(result.first.id, 'node-1');
    });
  });
}
