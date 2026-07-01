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
    datasource = HomeRemoteDataSource();
  });

  group('HomeRemoteDataSource', () {
    test('getHomeModules returns empty list (placeholder)', () async {
      final result = await datasource.getHomeModules();
      expect(result, isEmpty);
    });
  });
}
