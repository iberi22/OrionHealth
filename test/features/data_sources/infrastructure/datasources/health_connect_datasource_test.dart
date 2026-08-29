import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/data_sources/infrastructure/datasources/health_connect_datasource.dart';
import '../../../../helpers/mock_health.dart';

class FakeDateTime extends Fake implements DateTime {}

void main() {
  late HealthConnectDataSourceImpl dataSource;
  late MockHealthWrapper mockWrapper;
  late MockHealth mockHealth;

  final expectedTypes = [HealthDataType.STEPS, HealthDataType.HEART_RATE];

  setUpAll(() {
    registerFallbackValue(HealthDataType.STEPS);
    registerFallbackValue(FakeDateTime());
  });

  setUp(() {
    mockWrapper = MockHealthWrapper();
    mockHealth = MockHealth();
    when(() => mockWrapper.health).thenReturn(mockHealth);
    dataSource = HealthConnectDataSourceImpl(mockWrapper);
  });

  group('HealthConnectDataSourceImpl', () {
    group('isAvailable', () {
      test('returns true if permissions check succeeds', () async {
        when(
          () => mockHealth.hasPermissions(any()),
        ).thenAnswer((_) async => true);

        final result = await dataSource.isAvailable();

        expect(result, isTrue);
        verify(() => mockHealth.hasPermissions([])).called(1);
      });

      test(
        'returns false if permissions check returns false or null',
        () async {
          when(
            () => mockHealth.hasPermissions(any()),
          ).thenAnswer((_) async => null);

          final result = await dataSource.isAvailable();

          expect(result, isFalse);
        },
      );

      test('returns false if health is null', () async {
        when(() => mockWrapper.health).thenReturn(null);

        final result = await dataSource.isAvailable();

        expect(result, isFalse);
      });

      test(
        'returns false if health permissions check throws exception',
        () async {
          when(
            () => mockHealth.hasPermissions(any()),
          ).thenThrow(Exception('Device error'));

          final result = await dataSource.isAvailable();

          expect(result, isFalse);
        },
      );
    });

    group('requestPermissions', () {
      test(
        'calls health package with correct types and returns true',
        () async {
          when(
            () => mockHealth.requestAuthorization(expectedTypes),
          ).thenAnswer((_) async => true);

          final result = await dataSource.requestPermissions();

          expect(result, isTrue);
          verify(
            () => mockHealth.requestAuthorization(expectedTypes),
          ).called(1);
        },
      );

      test('returns false if requestAuthorization fails', () async {
        when(
          () => mockHealth.requestAuthorization(any()),
        ).thenAnswer((_) async => false);

        final result = await dataSource.requestPermissions();

        expect(result, isFalse);
      });

      test('returns false if health is null', () async {
        when(() => mockWrapper.health).thenReturn(null);

        final result = await dataSource.requestPermissions();

        expect(result, isFalse);
      });

      test('returns false if requestAuthorization throws exception', () async {
        when(
          () => mockHealth.requestAuthorization(any()),
        ).thenThrow(Exception('Auth failed'));

        final result = await dataSource.requestPermissions();

        expect(result, isFalse);
      });
    });

    group('syncData', () {
      test('calls health package with correct types and date range', () async {
        when(
          () => mockHealth.getHealthDataFromTypes(
            types: any(named: 'types'),
            startTime: any(named: 'startTime'),
            endTime: any(named: 'endTime'),
          ),
        ).thenAnswer((_) async => []);

        await dataSource.syncData();

        verify(
          () => mockHealth.getHealthDataFromTypes(
            types: expectedTypes,
            startTime: any(named: 'startTime'),
            endTime: any(named: 'endTime'),
          ),
        ).called(1);
      });

      test('handles null health gracefully', () async {
        when(() => mockWrapper.health).thenReturn(null);

        await dataSource.syncData();
      });

      test(
        'handles exception from getHealthDataFromTypes gracefully',
        () async {
          when(
            () => mockHealth.getHealthDataFromTypes(
              types: any(named: 'types'),
              startTime: any(named: 'startTime'),
              endTime: any(named: 'endTime'),
            ),
          ).thenThrow(Exception('Sync error'));

          await dataSource.syncData();
        },
      );
    });
  });
}
