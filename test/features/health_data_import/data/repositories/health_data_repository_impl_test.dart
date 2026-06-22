import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/health_data_import/data/repositories/health_data_repository_impl.dart';
import 'package:orionhealth_health/features/health_data_import/data/datasources/health_data_sensor_datasource.dart';
import 'package:orionhealth_health/features/health_data_import/data/datasources/health_data_file_datasource.dart';

class MockSensorDataSource extends Mock implements HealthDataSensorDataSource {}
class MockFileDataSource extends Mock implements HealthDataFileDataSource {}

void main() {
  late HealthDataImportRepositoryImpl repository;
  late MockSensorDataSource mockSensor;
  late MockFileDataSource mockFile;

  setUp(() {
    mockSensor = MockSensorDataSource();
    mockFile = MockFileDataSource();
    repository = HealthDataImportRepositoryImpl(mockSensor, mockFile);
  });

  group('HealthDataImportRepositoryImpl (Data)', () {
    test('hasPermissions proxies to sensor data source', () async {
      when(() => mockSensor.hasPermissions(any())).thenAnswer((_) async => true);
      final result = await repository.hasPermissions([HealthDataType.STEPS]);
      expect(result, isTrue);
    });
  });
}
