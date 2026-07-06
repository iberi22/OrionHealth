import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/health_data_import/domain/repositories/health_data_import_repository.dart';

class MockHealthDataImportRepository extends Mock implements HealthDataImportRepository {}

void main() {
  late MockHealthDataImportRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(HealthDataType.STEPS);
  });

  setUp(() {
    mockRepository = MockHealthDataImportRepository();
  });

  group('HealthDataImportRepository Interface', () {
    test('can be mocked and called', () async {
      when(() => mockRepository.hasPermissions(any())).thenAnswer((_) async => true);
      when(() => mockRepository.requestAuthorization(any())).thenAnswer((_) async => true);
      when(() => mockRepository.fetchHealthData(any(), any(), any())).thenAnswer((_) async => []);
      when(() => mockRepository.pickAndExtractFromFile()).thenAnswer((_) async => 'extracted text');

      final hasPerm = await mockRepository.hasPermissions([HealthDataType.STEPS]);
      final reqAuth = await mockRepository.requestAuthorization([HealthDataType.STEPS]);
      final data = await mockRepository.fetchHealthData(HealthDataType.STEPS, DateTime.now(), DateTime.now());
      final text = await mockRepository.pickAndExtractFromFile();

      expect(hasPerm, isTrue);
      expect(reqAuth, isTrue);
      expect(data, isEmpty);
      expect(text, 'extracted text');

      verify(() => mockRepository.hasPermissions(any())).called(1);
      verify(() => mockRepository.requestAuthorization(any())).called(1);
      verify(() => mockRepository.fetchHealthData(any(), any(), any())).called(1);
      verify(() => mockRepository.pickAndExtractFromFile()).called(1);
    });
  });
}
