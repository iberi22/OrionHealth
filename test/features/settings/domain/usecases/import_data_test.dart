import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/settings/domain/repositories/llm_settings_repository.dart';
import 'package:orionhealth_health/features/settings/domain/usecases/import_data.dart';

class MockLlmSettingsRepository extends Mock implements LlmSettingsRepository {}

void main() {
  late ImportData usecase;
  late MockLlmSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockLlmSettingsRepository();
    usecase = ImportData(mockRepository);
  });

  const tData = '{"data": "test"}';

  test('should call importData from repository', () async {
    // arrange
    when(() => mockRepository.importData(any())).thenAnswer((_) async => {});

    // act
    await usecase(tData);

    // assert
    verify(() => mockRepository.importData(tData)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
