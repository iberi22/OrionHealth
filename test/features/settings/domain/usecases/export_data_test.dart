import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/settings/domain/repositories/llm_settings_repository.dart';
import 'package:orionhealth_health/features/settings/domain/usecases/export_data.dart';

class MockLlmSettingsRepository extends Mock implements LlmSettingsRepository {}

void main() {
  late ExportData usecase;
  late MockLlmSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockLlmSettingsRepository();
    usecase = ExportData(mockRepository);
  });

  const tExportedData = '{"data": "test"}';

  test('should call exportData from repository', () async {
    // arrange
    when(() => mockRepository.exportData()).thenAnswer((_) async => tExportedData);

    // act
    final result = await usecase();

    // assert
    expect(result, tExportedData);
    verify(() => mockRepository.exportData()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
