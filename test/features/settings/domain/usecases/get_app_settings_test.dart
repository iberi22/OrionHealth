import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/settings/domain/entities/app_settings.dart';
import 'package:orionhealth_health/features/settings/domain/repositories/llm_settings_repository.dart';
import 'package:orionhealth_health/features/settings/domain/usecases/get_app_settings.dart';

class MockLlmSettingsRepository extends Mock implements LlmSettingsRepository {}

void main() {
  late GetAppSettings usecase;
  late MockLlmSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockLlmSettingsRepository();
    usecase = GetAppSettings(mockRepository);
  });

  final tAppSettings = AppSettings();

  test('should get app settings from the repository', () async {
    // arrange
    when(() => mockRepository.getAppSettings()).thenAnswer((_) async => tAppSettings);

    // act
    final result = await usecase();

    // assert
    expect(result, tAppSettings);
    verify(() => mockRepository.getAppSettings()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
