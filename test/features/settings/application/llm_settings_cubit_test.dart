import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/llm_adapter.dart';
import 'package:orionhealth_health/features/settings/application/llm_settings_cubit.dart';
import 'package:orionhealth_health/features/settings/domain/entities/llm_config.dart';
import 'package:orionhealth_health/features/settings/domain/repositories/llm_settings_repository.dart';
import 'package:orionhealth_health/features/settings/domain/services/device_capability_service.dart';

class MockLlmSettingsRepository extends Mock implements LlmSettingsRepository {}
class MockDeviceCapabilityService extends Mock implements DeviceCapabilityService {}
class MockLlmAdapter extends Mock implements LlmAdapter {}

void main() {
  late LlmSettingsCubit cubit;
  late MockLlmSettingsRepository mockRepository;
  late MockDeviceCapabilityService mockDeviceCapabilityService;
  late MockLlmAdapter mockLlmAdapter;

  final testConfig = LlmConfig(
    selectedModel: 'gemini-2.0-flash',
    localModelId: 'gemma-3-270m',
  );

  const testCapability = DeviceCapability(
    tier: DeviceCapabilityTier.medium,
    totalMemoryMb: 4096,
    availableMemoryMb: 2048,
    processorCount: 8,
    supportsGeminiCloud: true,
    recommendedModel: 'gemini-2.0-flash',
  );

  setUp(() {
    mockRepository = MockLlmSettingsRepository();
    mockDeviceCapabilityService = MockDeviceCapabilityService();
    mockLlmAdapter = MockLlmAdapter();

    registerFallbackValue(LlmConfig());

    when(() => mockRepository.getLlmConfig()).thenAnswer((_) async => testConfig);
    when(() => mockRepository.saveLlmConfig(any())).thenAnswer((_) async {});
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

  group('LlmSettingsCubit', () {
    test('initial state is LlmSettingsInitial', () {
      expect(cubit.state, isA<LlmSettingsInitial>());
    });

    test('loadSettings emits Loading then Loaded with config from repository', () async {
      await cubit.loadSettings();

      expect(cubit.state, isA<LlmSettingsLoaded>());
      final loadedState = cubit.state as LlmSettingsLoaded;
      expect(loadedState.config.selectedModel, testConfig.selectedModel);
    });

    test('loadSettings emits error when repository fails', () async {
      when(() => mockRepository.getLlmConfig()).thenThrow(Exception('DB error'));

      await cubit.loadSettings();

      expect(cubit.state, isA<LlmSettingsError>());
      expect((cubit.state as LlmSettingsError).message, contains('DB error'));
    });

    test('loadSettings creates default config if none exists', () async {
      when(() => mockRepository.getLlmConfig()).thenAnswer((_) async => null);

      await cubit.loadSettings();

      expect(cubit.state, isA<LlmSettingsLoaded>());
      verify(() => mockRepository.saveLlmConfig(any())).called(1);
    });

    test('updateSelectedModel saves config and updates state', () async {
      await cubit.loadSettings();
      await cubit.updateSelectedModel('new-model');
      expect((cubit.state as LlmSettingsLoaded).config.selectedModel, 'new-model');
      verify(() => mockRepository.saveLlmConfig(any())).called(greaterThan(0));
    });

    test('updateUseCloudApi updates state', () async {
      await cubit.loadSettings();
      await cubit.updateUseCloudApi(false);
      expect((cubit.state as LlmSettingsLoaded).config.useCloudApi, false);
      verify(() => mockRepository.saveLlmConfig(any())).called(greaterThan(0));
    });

    test('updateAllowCloudApiCalls updates state', () async {
      await cubit.loadSettings();
      await cubit.updateAllowCloudApiCalls(false);
      expect((cubit.state as LlmSettingsLoaded).config.allowCloudApiCalls, false);
      verify(() => mockRepository.saveLlmConfig(any())).called(greaterThan(0));
    });

    test('updateProviderType updates state', () async {
      await cubit.loadSettings();
      await cubit.updateProviderType('openai');
      expect((cubit.state as LlmSettingsLoaded).config.providerType, 'openai');
      verify(() => mockRepository.saveLlmConfig(any())).called(greaterThan(0));
    });

    test('updateApiKey updates state', () async {
      await cubit.loadSettings();
      await cubit.updateApiKey('new-key');
      expect((cubit.state as LlmSettingsLoaded).config.apiKey, 'new-key');
      verify(() => mockRepository.saveLlmConfig(any())).called(greaterThan(0));
    });

    test('updateBaseUrl updates state', () async {
      await cubit.loadSettings();
      await cubit.updateBaseUrl('https://example.com');
      expect((cubit.state as LlmSettingsLoaded).config.baseUrl, 'https://example.com');
      verify(() => mockRepository.saveLlmConfig(any())).called(greaterThan(0));
    });

    test('updateCloudModel updates state', () async {
      await cubit.loadSettings();
      await cubit.updateCloudModel('gpt-4');
      expect((cubit.state as LlmSettingsLoaded).config.cloudModel, 'gpt-4');
      verify(() => mockRepository.saveLlmConfig(any())).called(greaterThan(0));
    });

    test('updateLocalModel updates state', () async {
      await cubit.loadSettings();
      await cubit.updateLocalModel('phi-2');
      expect((cubit.state as LlmSettingsLoaded).config.localModelId, 'phi-2');
      verify(() => mockRepository.saveLlmConfig(any())).called(greaterThan(0));
    });

    test('downloadModel updates progress and handles completion', () async {
      final progressController = StreamController<int>();
      when(() => mockLlmAdapter.installModel(
        modelId: any(named: 'modelId'),
        url: any(named: 'url'),
      )).thenAnswer((_) => progressController.stream);

      await cubit.loadSettings();
      await cubit.downloadModel('gemma-3-270m');

      expect((cubit.state as LlmSettingsLoaded).downloadProgress['gemma-3-270m'], 0.0);

      progressController.add(50);
      await Future.delayed(Duration.zero);
      expect((cubit.state as LlmSettingsLoaded).downloadProgress['gemma-3-270m'], 0.5);

      when(() => mockLlmAdapter.listInstalledModels()).thenAnswer((_) async => ['gemma-3-270m']);

      await progressController.close();
      await Future.delayed(Duration.zero);

      final finalState = cubit.state as LlmSettingsLoaded;
      expect(finalState.downloadProgress.containsKey('gemma-3-270m'), isFalse);
      expect(finalState.installedModels, contains('gemma-3-270m'));
    });

    test('downloadModel handles error', () async {
      final progressController = StreamController<int>();
      when(() => mockLlmAdapter.installModel(
        modelId: any(named: 'modelId'),
        url: any(named: 'url'),
      )).thenAnswer((_) => progressController.stream);

      await cubit.loadSettings();
      await cubit.downloadModel('gemma-3-270m');

      progressController.addError('Download failed');
      await Future.delayed(Duration.zero);

      final state = cubit.state as LlmSettingsLoaded;
      expect(state.downloadProgress.containsKey('gemma-3-270m'), isFalse);
      expect(state.connectionError, contains('Download failed'));
    });

    test('cancelDownload stops subscription and clears progress', () async {
      final progressController = StreamController<int>();
      when(() => mockLlmAdapter.installModel(
        modelId: any(named: 'modelId'),
        url: any(named: 'url'),
      )).thenAnswer((_) => progressController.stream);
      when(() => mockLlmAdapter.cancelDownload(any())).thenAnswer((_) async {});

      await cubit.loadSettings();
      await cubit.downloadModel('gemma-3-270m');

      expect((cubit.state as LlmSettingsLoaded).downloadProgress.containsKey('gemma-3-270m'), isTrue);

      await cubit.cancelDownload('gemma-3-270m');

      expect((cubit.state as LlmSettingsLoaded).downloadProgress.containsKey('gemma-3-270m'), isFalse);
      expect(progressController.hasListener, isFalse);
    });

    test('deleteModel uninstalls and refreshes list, handles error', () async {
      when(() => mockLlmAdapter.uninstallModel(any())).thenAnswer((_) async {});
      when(() => mockLlmAdapter.listInstalledModels()).thenAnswer((_) async => []);

      await cubit.loadSettings();
      await cubit.deleteModel('gemma-3-270m');

      expect((cubit.state as LlmSettingsLoaded).installedModels, isEmpty);
      verify(() => mockLlmAdapter.uninstallModel('gemma-3-270m')).called(1);

      when(() => mockLlmAdapter.uninstallModel(any())).thenThrow(Exception('Delete error'));
      await cubit.deleteModel('gemma-3-270m');
      expect((cubit.state as LlmSettingsLoaded).connectionError, contains('Delete error'));
    });

    test('verifyConnection for local provider returns verified true', () async {
      await cubit.loadSettings();
      await cubit.updateProviderType('local');
      await cubit.verifyConnection();

      final loadedState = cubit.state as LlmSettingsLoaded;
      expect(loadedState.connectionVerified, isTrue);
    });

    test('verifyConnection for gemini handles API key', () async {
      await cubit.loadSettings();
      await cubit.updateProviderType('gemini');

      // Test without key (Platform.environment should be empty in tests)
      await cubit.verifyConnection();
      expect((cubit.state as LlmSettingsLoaded).connectionVerified, isFalse);
      expect((cubit.state as LlmSettingsLoaded).connectionError, contains('GEMINI_API_KEY'));
    });

    test('verifyConnection for openai fails (cannot easily mock http.get directly without DI or wrapper)', () async {
       await cubit.loadSettings();
       await cubit.updateProviderType('openai');
       await cubit.updateApiKey('test-key');

       await cubit.verifyConnection();

       final loadedState = cubit.state as LlmSettingsLoaded;
       expect(loadedState.connectionVerified, isFalse);
    });
  });
}
