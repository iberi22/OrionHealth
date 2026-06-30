import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/llm_adapter.dart';
import 'package:orionhealth_health/features/settings/application/llm_settings_cubit.dart';
import 'package:orionhealth_health/features/settings/domain/entities/app_settings.dart';
import 'package:orionhealth_health/features/settings/domain/entities/llm_config.dart';
import 'package:orionhealth_health/features/settings/domain/repositories/settings_repository.dart';
import 'package:orionhealth_health/features/settings/domain/services/device_capability_service.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}
class MockDeviceCapabilityService extends Mock implements DeviceCapabilityService {}
class MockLlmAdapter extends Mock implements LlmAdapter {}

void main() {
  late LlmSettingsCubit cubit;
  late MockSettingsRepository mockRepository;
  late MockDeviceCapabilityService mockDeviceCapabilityService;
  late MockLlmAdapter mockLlmAdapter;

  final testConfig = LlmConfig(
    selectedModel: 'gemini-2.0-flash',
  );

  final testAppSettings = AppSettings(
    themeMode: 'dark',
    languageCode: 'en',
    notificationsEnabled: true,
  );

  const testCapability = DeviceCapability(
    tier: DeviceCapabilityTier.medium,
    totalMemoryMb: 4096,
    availableMemoryMb: 2048,
    processorCount: 8,
    supportsGeminiCloud: true,
    recommendedModel: 'gemini-2.0-flash',
  );

  setUpAll(() {
    registerFallbackValue(LlmConfig());
    registerFallbackValue(AppSettings());
  });

  setUp(() {
    mockRepository = MockSettingsRepository();
    mockDeviceCapabilityService = MockDeviceCapabilityService();
    mockLlmAdapter = MockLlmAdapter();

    when(() => mockRepository.getLlmConfig()).thenAnswer((_) async => testConfig);
    when(() => mockRepository.saveLlmConfig(any())).thenAnswer((_) async {});
    when(() => mockRepository.getAppSettings()).thenAnswer((_) async => testAppSettings);
    when(() => mockRepository.saveAppSettings(any())).thenAnswer((_) async {});
    when(() => mockDeviceCapabilityService.detectCapability()).thenAnswer((_) async => testCapability);
    when(() => mockLlmAdapter.listInstalledModels()).thenAnswer((_) async => []);

    cubit = LlmSettingsCubit(
      mockRepository,
      mockDeviceCapabilityService,
      mockLlmAdapter,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('LlmSettingsCubit Extra Tests', () {
    test('updateThemeMode updates state and saves to repository', () async {
      await cubit.loadSettings();
      await cubit.updateThemeMode('light');

      expect((cubit.state as LlmSettingsLoaded).appSettings.themeMode, 'light');
      verify(() => mockRepository.saveAppSettings(any())).called(1);
    });

    test('updateLanguage updates state and saves to repository', () async {
      await cubit.loadSettings();
      await cubit.updateLanguage('es');

      expect((cubit.state as LlmSettingsLoaded).appSettings.languageCode, 'es');
      verify(() => mockRepository.saveAppSettings(any())).called(1);
    });

    test('updateNotificationsEnabled updates state and saves to repository', () async {
      await cubit.loadSettings();
      await cubit.updateNotificationsEnabled(false);

      expect((cubit.state as LlmSettingsLoaded).appSettings.notificationsEnabled, false);
      verify(() => mockRepository.saveAppSettings(any())).called(1);
    });

    test('exportData updates state with exported data', () async {
      const exportString = '{"data": "test"}';
      when(() => mockRepository.exportData()).thenAnswer((_) async => exportString);

      await cubit.loadSettings();
      await cubit.exportData();

      expect((cubit.state as LlmSettingsLoaded).exportData, exportString);
    });

    test('exportData handles errors', () async {
      when(() => mockRepository.exportData()).thenThrow(Exception('Export error'));

      await cubit.loadSettings();
      await cubit.exportData();

      expect((cubit.state as LlmSettingsLoaded).connectionError, contains('Export error'));
    });

    test('importData calls repository and reloads settings', () async {
      const importString = '{"data": "test"}';
      when(() => mockRepository.importData(any())).thenAnswer((_) async {});

      await cubit.loadSettings();
      await cubit.importData(importString);

      verify(() => mockRepository.importData(importString)).called(1);
      verify(() => mockRepository.getLlmConfig()).called(2); // Initial load + after import
    });

    test('importData handles errors', () async {
      when(() => mockRepository.importData(any())).thenThrow(Exception('Import error'));

      await cubit.loadSettings();
      await cubit.importData('bad data');

      expect((cubit.state as LlmSettingsLoaded).connectionError, contains('Import error'));
    });
  });
}
