import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/home/infrastructure/datasources/home_remote_datasource.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late HomeRemoteDataSource datasource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    datasource = HomeRemoteDataSource(mockDio);
  });

  group('HomeRemoteDataSource', () {
    const baseUrl = 'https://api.orionhealth.ai/home';

    test('getHomeModules returns list on success', () async {
      final mockData = [
        {
          'title': 'Module 1',
          'icon': 0xe123,
          'color': 0xFF42A5F5,
          'route': '/route1'
        },
      ];

      when(() => mockDio.get('$baseUrl/modules'))
          .thenAnswer((_) async => Response(
                data: mockData,
                statusCode: 200,
                requestOptions: RequestOptions(path: '$baseUrl/modules'),
              ));

      final result = await datasource.getHomeModules();
      expect(result, hasLength(1));
      expect(result.first.title, 'Module 1');
      expect(result.first.route, '/route1');
    });

    test('getHomeModules returns empty list on error', () async {
      when(() => mockDio.get('$baseUrl/modules'))
          .thenThrow(DioException(requestOptions: RequestOptions(path: '$baseUrl/modules')));

      final result = await datasource.getHomeModules();
      expect(result, isEmpty);
    });

    test('getHealthSummary returns summary on success', () async {
      final mockData = {'summary': 'Remote summary content'};

      when(() => mockDio.get('$baseUrl/summary'))
          .thenAnswer((_) async => Response(
                data: mockData,
                statusCode: 200,
                requestOptions: RequestOptions(path: '$baseUrl/summary'),
              ));

      final result = await datasource.getHealthSummary();
      expect(result, 'Remote summary content');
    });

    test('getHealthSummary returns error message on DioException', () async {
      when(() => mockDio.get('$baseUrl/summary'))
          .thenThrow(DioException(requestOptions: RequestOptions(path: '$baseUrl/summary')));

      final result = await datasource.getHealthSummary();
      expect(result, contains('Error de conexión'));
    });

    test('getHealthSummary returns error message on non-200 status', () async {
      when(() => mockDio.get('$baseUrl/summary'))
          .thenAnswer((_) async => Response(
                data: {},
                statusCode: 404,
                requestOptions: RequestOptions(path: '$baseUrl/summary'),
              ));

      final result = await datasource.getHealthSummary();
      expect(result, contains('Error al obtener'));
    });
  });
}
