import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/settings/domain/entities/app_settings.dart';
import 'package:orionhealth_health/features/settings/domain/repositories/settings_repository.dart';
import 'package:orionhealth_health/features/settings/domain/usecases/update_language.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late UpdateLanguage usecase;
  late MockSettingsRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(AppSettings());
  });

  setUp(() {
    mockRepository = MockSettingsRepository();
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
