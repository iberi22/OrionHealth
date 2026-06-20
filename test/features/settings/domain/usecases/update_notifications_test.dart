import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/settings/domain/entities/app_settings.dart';
import 'package:orionhealth_health/features/settings/domain/repositories/llm_settings_repository.dart';
import 'package:orionhealth_health/features/settings/domain/usecases/update_notifications.dart';

class MockLlmSettingsRepository extends Mock implements LlmSettingsRepository {}

void main() {
  late UpdateNotifications usecase;
  late MockLlmSettingsRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(AppSettings());
  });

  setUp(() {
    mockRepository = MockLlmSettingsRepository();
    usecase = UpdateNotifications(mockRepository);
  });

  const tEnabled = false;

  test('should update notifications enabled in app settings', () async {
    // arrange
    final tAppSettings = AppSettings(notificationsEnabled: true);
    when(() => mockRepository.getAppSettings()).thenAnswer((_) async => tAppSettings);
    when(() => mockRepository.saveAppSettings(any())).thenAnswer((_) async => {});

    // act
    await usecase(tEnabled);

    // assert
    verify(() => mockRepository.getAppSettings()).called(1);
    verify(() => mockRepository.saveAppSettings(any(that: isA<AppSettings>().having((s) => s.notificationsEnabled, 'notificationsEnabled', tEnabled)))).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
