import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/settings/domain/entities/app_settings.dart';
import 'package:orionhealth_health/features/settings/domain/repositories/llm_settings_repository.dart';
import 'package:orionhealth_health/features/settings/domain/usecases/update_language.dart';

class MockLlmSettingsRepository extends Mock implements LlmSettingsRepository {}

void main() {
  late UpdateLanguage usecase;
  late MockLlmSettingsRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(AppSettings());
  });

  setUp(() {
    mockRepository = MockLlmSettingsRepository();
    usecase = UpdateLanguage(mockRepository);
  });

  const tLanguageCode = 'en';

  test('should update language code in app settings', () async {
    // arrange
    final tAppSettings = AppSettings(languageCode: 'es');
    when(() => mockRepository.getAppSettings()).thenAnswer((_) async => tAppSettings);
    when(() => mockRepository.saveAppSettings(any())).thenAnswer((_) async => {});

    // act
    await usecase(tLanguageCode);

    // assert
    verify(() => mockRepository.getAppSettings()).called(1);
    verify(() => mockRepository.saveAppSettings(any(that: isA<AppSettings>().having((s) => s.languageCode, 'languageCode', tLanguageCode)))).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should use default AppSettings if repository returns null', () async {
    // arrange
    when(() => mockRepository.getAppSettings()).thenAnswer((_) async => null);
    when(() => mockRepository.saveAppSettings(any())).thenAnswer((_) async => {});

    // act
    await usecase(tLanguageCode);

    // assert
    verify(() => mockRepository.getAppSettings()).called(1);
    verify(() => mockRepository.saveAppSettings(any(that: isA<AppSettings>().having((s) => s.languageCode, 'languageCode', tLanguageCode)))).called(1);
  });
}
