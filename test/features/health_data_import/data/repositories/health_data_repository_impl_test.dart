import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:health/health.dart';
import 'package:orionhealth_health/features/health_data_import/data/repositories/health_data_repository_impl.dart';
import 'package:orionhealth_health/features/health_data_import/data/datasources/health_data_sensor_datasource.dart';
import 'package:orionhealth_health/features/health_data_import/data/datasources/health_data_file_datasource.dart';

class MockHealthDataSensorDataSource extends Mock implements HealthDataSensorDataSource {}
class MockHealthDataFileDataSource extends Mock implements HealthDataFileDataSource {}

void main() {
  late HealthDataImportRepositoryImpl repository;
  late MockHealthDataSensorDataSource mockSensorDataSource;
  late MockHealthDataFileDataSource mockFileDataSource;

  setUp(() {
    mockSensorDataSource = MockHealthDataSensorDataSource();
    mockFileDataSource = MockHealthDataFileDataSource();
    repository = HealthDataImportRepositoryImpl(
      mockSensorDataSource,
      mockFileDataSource,
    );
  });

  group('HealthDataImportRepositoryImpl', () {
    test('hasPermissions should delegate to sensor data source', () async {
      final types = [HealthDataType.STEPS];
      when(() => mockSensorDataSource.hasPermissions(types))
          .thenAnswer((_) async => true);

      final result = await repository.hasPermissions(types);

      expect(result, true);
      verify(() => mockSensorDataSource.hasPermissions(types)).called(1);
    });

    test('requestAuthorization should delegate to sensor data source', () async {
      final types = [HealthDataType.STEPS];
      when(() => mockSensorDataSource.requestAuthorization(types, any()))
          .thenAnswer((_) async => true);

      final result = await repository.requestAuthorization(types);

      expect(result, true);
      verify(() => mockSensorDataSource.requestAuthorization(types, any())).called(1);
    });

    test('fetchHealthData should delegate to sensor data source', () async {
      final type = HealthDataType.STEPS;
      final start = DateTime.now();
      final end = DateTime.now();
      when(() => mockSensorDataSource.fetchData(type, start, end))
          .thenAnswer((_) async => []);

      final result = await repository.fetchHealthData(type, start, end);

      expect(result, isEmpty);
      verify(() => mockSensorDataSource.fetchData(type, start, end)).called(1);
    });

    test('pickAndExtractFromFile should delegate to file data source', () async {
      when(() => mockFileDataSource.pickAndExtractText())
          .thenAnswer((_) async => 'extracted text');

      final result = await repository.pickAndExtractFromFile();

      expect(result, 'extracted text');
      verify(() => mockFileDataSource.pickAndExtractText()).called(1);
    });
  });
}
