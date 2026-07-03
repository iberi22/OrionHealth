import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/health_data_import/domain/services/health_data_import_service.dart';
import 'package:orionhealth_health/features/health_data_import/domain/usecases/health_import_usecases.dart';
import 'package:orionhealth_health/features/health_data_import/domain/entities/health_data_source.dart';

class MockHealthDataImportService extends Mock implements HealthDataImportService {}

void main() {
  late GetAvailableSourcesUseCase getSourcesUseCase;
  late RequestHealthAuthUseCase requestAuthUseCase;
  late MockHealthDataImportService mockService;

  setUp(() {
    mockService = MockHealthDataImportService();
    getSourcesUseCase = GetAvailableSourcesUseCase(mockService);
    requestAuthUseCase = RequestHealthAuthUseCase(mockService);
  });

  group('GetAvailableSourcesUseCase', () {
    test('should return list of available sources from service', () async {
      final tSources = [HealthDataSource.googleFit];
      when(() => mockService.getAvailableSources()).thenAnswer((_) async => tSources);

      final result = await getSourcesUseCase();

      expect(result, tSources);
      verify(() => mockService.getAvailableSources()).called(1);
    });
  });

  group('RequestHealthAuthUseCase', () {
    test('should return auth result from service', () async {
      const tSource = HealthDataSource.appleHealth;
      when(() => mockService.requestAuthorization(tSource)).thenAnswer((_) async => true);

      final result = await requestAuthUseCase(tSource);

      expect(result, true);
      verify(() => mockService.requestAuthorization(tSource)).called(1);
    });
  });
}
