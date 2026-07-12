import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/utils/health_wrapper.dart';
import 'package:orionhealth_health/features/data_sources/infrastructure/datasources/health_connect_datasource.dart';

class MockHealth extends Mock implements Health {}

class MockHealthWrapper extends Mock implements HealthWrapper {}

void main() {
  late HealthConnectDataSourceImpl dataSource;
  late MockHealthWrapper mockWrapper;
  late MockHealth mockHealth;

  setUp(() {
    mockWrapper = MockHealthWrapper();
    mockHealth = MockHealth();
    when(() => mockWrapper.health).thenReturn(mockHealth);
    dataSource = HealthConnectDataSourceImpl(mockWrapper);
  });

  group('HealthConnectDataSourceImpl', () {
    test('isAvailable returns true if permissions check succeeds', () async {
      when(() => mockHealth.hasPermissions([])).thenAnswer((_) async => true);

      final result = await dataSource.isAvailable();

      expect(result, isTrue);
    });

    test('isAvailable returns false if permissions check fails or returns null', () async {
      when(() => mockHealth.hasPermissions([])).thenAnswer((_) async => null);

      final result = await dataSource.isAvailable();

      expect(result, isFalse);
    });

    test('requestPermissions calls health package with correct types', () async {
      final types = [HealthDataType.STEPS, HealthDataType.HEART_RATE];
      when(() => mockHealth.requestAuthorization(types)).thenAnswer((_) async => true);

      final result = await dataSource.requestPermissions();

      expect(result, isTrue);
      verify(() => mockHealth.requestAuthorization(types)).called(1);
    });

    test('syncData calls health package with correct types and date range', () async {
      when(() => mockHealth.getHealthDataFromTypes(
            types: any(named: 'types'),
            startTime: any(named: 'startTime'),
            endTime: any(named: 'endTime'),
          )).thenAnswer((_) async => []);

      await dataSource.syncData();

      verify(() => mockHealth.getHealthDataFromTypes(
            types: [HealthDataType.STEPS, HealthDataType.HEART_RATE],
            startTime: any(named: 'startTime'),
            endTime: any(named: 'endTime'),
          )).called(1);
    });

    test('isAvailable returns false if health is null', () async {
      when(() => mockWrapper.health).thenReturn(null);
      final result = await dataSource.isAvailable();
      expect(result, isFalse);
    });

    test('requestPermissions returns false if health is null', () async {
      when(() => mockWrapper.health).thenReturn(null);
      final result = await dataSource.requestPermissions();
      expect(result, isFalse);
    });

    test('syncData does nothing if health is null', () async {
      when(() => mockWrapper.health).thenReturn(null);
      await dataSource.syncData();
      // Should not throw
    });
  });
}
