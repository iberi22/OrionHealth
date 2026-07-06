import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/data_sources/domain/entities/data_source_entity.dart';
import 'package:orionhealth_health/features/data_sources/infrastructure/datasources/sensor_api_datasource.dart';
import 'package:orionhealth_health/features/data_sources/infrastructure/datasources/file_import_datasource.dart';
import 'package:orionhealth_health/features/data_sources/infrastructure/datasources/health_connect_datasource.dart';
import 'package:orionhealth_health/features/data_sources/infrastructure/repositories/data_source_repository_impl.dart';

class MockSensorApiDataSource extends Mock implements SensorApiDataSource {}
class MockFileImportDataSource extends Mock implements FileImportDataSource {}
class MockHealthConnectDataSource extends Mock implements HealthConnectDataSource {}

void main() {
  late DataSourceRepositoryImpl repository;
  late MockSensorApiDataSource mockSensor;
  late MockFileImportDataSource mockFile;
  late MockHealthConnectDataSource mockHealthConnect;

  setUp(() {
    mockSensor = MockSensorApiDataSource();
    mockFile = MockFileImportDataSource();
    mockHealthConnect = MockHealthConnectDataSource();
    repository = DataSourceRepositoryImpl(mockSensor, mockFile, mockHealthConnect);
  });

  group('DataSourceRepositoryImpl', () {
    test('getDataSources returns all 3 sources', () async {
      final sources = await repository.getDataSources();
      expect(sources.length, 3);
      expect(sources.any((s) => s.type == DataSourceType.sensor), true);
      expect(sources.any((s) => s.type == DataSourceType.file), true);
      expect(sources.any((s) => s.type == DataSourceType.healthConnect), true);
    });

    group('connectDataSource', () {
      test('sensors connection success', () async {
        when(() => mockSensor.requestAuthorization()).thenAnswer((_) async => true);
        await repository.connectDataSource('sensors');
        verify(() => mockSensor.requestAuthorization()).called(1);
      });

      test('sensors connection failure throws exception', () async {
        when(() => mockSensor.requestAuthorization()).thenAnswer((_) async => false);
        expect(() => repository.connectDataSource('sensors'), throwsException);
      });

      test('health_connect connection success', () async {
        when(() => mockHealthConnect.requestPermissions()).thenAnswer((_) async => true);
        await repository.connectDataSource('health_connect');
        verify(() => mockHealthConnect.requestPermissions()).called(1);
      });

      test('health_connect connection failure throws exception', () async {
        when(() => mockHealthConnect.requestPermissions()).thenAnswer((_) async => false);
        expect(() => repository.connectDataSource('health_connect'), throwsException);
      });

      test('files connection does nothing (no exception)', () async {
        await repository.connectDataSource('files');
        verifyZeroInteractions(mockFile);
      });

      test('unknown id throws exception', () async {
        expect(() => repository.connectDataSource('unknown'), throwsException);
      });
    });

    group('syncDataSource', () {
      test('sensors sync calls fetchAndSaveData', () async {
        when(() => mockSensor.fetchAndSaveData()).thenAnswer((_) async => {});
        await repository.syncDataSource('sensors');
        verify(() => mockSensor.fetchAndSaveData()).called(1);
      });

      test('health_connect sync calls syncData', () async {
        when(() => mockHealthConnect.syncData()).thenAnswer((_) async => {});
        await repository.syncDataSource('health_connect');
        verify(() => mockHealthConnect.syncData()).called(1);
      });

      test('files sync calls pickAndProcessFile', () async {
        when(() => mockFile.pickAndProcessFile()).thenAnswer((_) async => 'extracted text');
        await repository.syncDataSource('files');
        verify(() => mockFile.pickAndProcessFile()).called(1);
      });

      test('unknown id throws exception', () async {
        expect(() => repository.syncDataSource('unknown'), throwsException);
      });
    });
  });
}
