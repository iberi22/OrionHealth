import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/settings/domain/entities/app_settings.dart';
import 'package:orionhealth_health/features/settings/domain/repositories/llm_settings_repository.dart';
import 'package:orionhealth_health/features/settings/domain/usecases/update_theme.dart';

class MockLlmSettingsRepository extends Mock implements LlmSettingsRepository {}

void main() {
  late UpdateTheme usecase;
  late MockLlmSettingsRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(AppSettings());
  });

  setUp(() {
    mockRepository = MockLlmSettingsRepository();
    usecase = UpdateTheme(mockRepository);
  });

  const tThemeMode = 'light';

  test('should update theme mode in app settings', () async {
    // arrange
    final tAppSettings = AppSettings(themeMode: 'dark');
    when(() => mockRepository.getAppSettings()).thenAnswer((_) async => tAppSettings);
    when(() => mockRepository.saveAppSettings(any())).thenAnswer((_) async => {});

    // act
    await usecase(tThemeMode);

    // assert
    verify(() => mockRepository.getAppSettings()).called(1);
    verify(() => mockRepository.saveAppSettings(any(that: isA<AppSettings>().having((s) => s.themeMode, 'themeMode', tThemeMode)))).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
