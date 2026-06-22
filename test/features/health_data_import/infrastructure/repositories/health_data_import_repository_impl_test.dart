import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/health_data_import/infrastructure/health_data_import_repository_impl.dart';
import 'package:orionhealth_health/features/health_data_import/infrastructure/data_source.dart';

class MockSensorHealthDataSource extends Mock implements SensorHealthDataSource {}
class MockFileHealthDataSource extends Mock implements FileHealthDataSource {}

void main() {
  late HealthDataImportRepositoryImpl repository;
  late MockSensorHealthDataSource mockSensor;
  late MockFileHealthDataSource mockFile;

  setUp(() {
    mockSensor = MockSensorHealthDataSource();
    mockFile = MockFileHealthDataSource();
    repository = HealthDataImportRepositoryImpl(mockSensor, mockFile);
  });

  group('HealthDataImportRepositoryImpl (Infra)', () {
    test('hasPermissions proxies to sensor data source', () async {
      when(() => mockSensor.hasPermissions(any())).thenAnswer((_) async => true);
      final result = await repository.hasPermissions([HealthDataType.STEPS]);
      expect(result, isTrue);
      verify(() => mockSensor.hasPermissions([HealthDataType.STEPS])).called(1);
    });

    test('pickAndExtractFromFile proxies to file data source', () async {
      when(() => mockFile.pickAndExtractText()).thenAnswer((_) async => 'extracted text');
      final result = await repository.pickAndExtractFromFile();
      expect(result, 'extracted text');
      verify(() => mockFile.pickAndExtractText()).called(1);
    });
  });
}
