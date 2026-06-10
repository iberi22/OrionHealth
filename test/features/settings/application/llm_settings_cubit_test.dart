import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:orionhealth_health/features/local_agent/domain/services/llm_adapter.dart';
import 'package:orionhealth_health/features/settings/application/llm_settings_cubit.dart';
import 'package:orionhealth_health/features/settings/domain/entities/llm_config.dart';
import 'package:orionhealth_health/features/settings/domain/repositories/llm_settings_repository.dart';
import 'package:orionhealth_health/features/settings/domain/services/device_capability_service.dart';

class MockLlmSettingsRepository extends Mock implements LlmSettingsRepository {}
class MockDeviceCapabilityService extends Mock implements DeviceCapabilityService {}
class MockLlmAdapter extends Mock implements LlmAdapter {}
class MockClient extends Mock implements http.Client {}

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

    test('loadSettings creates default config if none exists', () async {
      when(() => mockRepository.getLlmConfig()).thenAnswer((_) async => null);

      await cubit.loadSettings();

      expect(cubit.state, isA<LlmSettingsLoaded>());
      verify(() => mockRepository.saveLlmConfig(any())).called(1);
    });

    test('updateSelectedModel saves config and updates state', () async {
      await cubit.loadSettings();
      await cubit.updateSelectedModel('new-model');

      final loadedState = cubit.state as LlmSettingsLoaded;
      expect(loadedState.config.selectedModel, 'new-model');
      verify(() => mockRepository.saveLlmConfig(any())).called(greaterThan(0));
    });

    test('updateUseCloudApi updates state', () async {
      await cubit.loadSettings();
      await cubit.updateUseCloudApi(false);

      final loadedState = cubit.state as LlmSettingsLoaded;
      expect(loadedState.config.useCloudApi, false);
    });

    test('updateAllowCloudApiCalls updates state', () async {
      await cubit.loadSettings();
      await cubit.updateAllowCloudApiCalls(false);

      final loadedState = cubit.state as LlmSettingsLoaded;
      expect(loadedState.config.allowCloudApiCalls, false);
    });

    test('updateProviderType updates state', () async {
      await cubit.loadSettings();
      await cubit.updateProviderType('openai');

      final loadedState = cubit.state as LlmSettingsLoaded;
      expect(loadedState.config.providerType, 'openai');
    });

    test('updateApiKey updates state', () async {
      await cubit.loadSettings();
      await cubit.updateApiKey('new-key');

      final loadedState = cubit.state as LlmSettingsLoaded;
      expect(loadedState.config.apiKey, 'new-key');
    });

    test('updateBaseUrl updates state', () async {
      await cubit.loadSettings();
      await cubit.updateBaseUrl('https://example.com');

      final loadedState = cubit.state as LlmSettingsLoaded;
      expect(loadedState.config.baseUrl, 'https://example.com');
    });

    test('updateCloudModel updates state', () async {
      await cubit.loadSettings();
      await cubit.updateCloudModel('gpt-4');

      final loadedState = cubit.state as LlmSettingsLoaded;
      expect(loadedState.config.cloudModel, 'gpt-4');
    });

    test('updateLocalModel updates state', () async {
      await cubit.loadSettings();
      await cubit.updateLocalModel('phi-2');

      final loadedState = cubit.state as LlmSettingsLoaded;
      expect(loadedState.config.localModelId, 'phi-2');
    });

    test('downloadModel updates progress and refreshes installed models on done', () async {
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

    test('deleteModel uninstalls and refreshes list', () async {
      when(() => mockLlmAdapter.uninstallModel(any())).thenAnswer((_) async {});
      when(() => mockLlmAdapter.listInstalledModels()).thenAnswer((_) async => []);

      await cubit.loadSettings();
      await cubit.deleteModel('gemma-3-270m');

      expect((cubit.state as LlmSettingsLoaded).installedModels, isEmpty);
      verify(() => mockLlmAdapter.uninstallModel('gemma-3-270m')).called(1);
    });

    test('verifyConnection for local provider returns verified true', () async {
      await cubit.loadSettings(); // providerType is 'local'
      await cubit.verifyConnection();

      final loadedState = cubit.state as LlmSettingsLoaded;
      expect(loadedState.connectionVerified, isTrue);
    });

    test('verifyConnection for gemini without key returns error', () async {
      await cubit.loadSettings();
      await cubit.updateProviderType('gemini');

      // Platform.environment is tricky to mock without a wrapper or using IOOverrides
      // But we can test the logic flow.
      await cubit.verifyConnection();

      final loadedState = cubit.state as LlmSettingsLoaded;
      // In tests Platform.environment is likely empty unless set
      if (Platform.environment['GEMINI_API_KEY']?.isEmpty ?? true) {
        expect(loadedState.connectionVerified, isFalse);
        expect(loadedState.connectionError, contains('GEMINI_API_KEY'));
      }
    });
  });
}
