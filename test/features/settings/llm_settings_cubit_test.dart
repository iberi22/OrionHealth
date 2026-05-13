import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/llm_adapter.dart';
import 'package:orionhealth_health/features/local_agent/domain/entities/local_model_descriptor.dart';
import 'package:orionhealth_health/features/settings/application/llm_settings_cubit.dart';
import 'package:orionhealth_health/features/settings/domain/entities/llm_config.dart';
import 'package:orionhealth_health/features/settings/domain/repositories/llm_settings_repository.dart';
import 'package:orionhealth_health/features/settings/domain/services/device_capability_service.dart';

class MockLlmSettingsRepository extends Mock implements LlmSettingsRepository {}
class MockDeviceCapabilityService extends Mock implements DeviceCapabilityService {}
class MockLlmAdapter extends Mock implements LlmAdapter {
  @override
  Future<void> cancelDownload(String? modelId) async {}

  @override
  Future<void> uninstallModel(String? modelId) async {}
}

void main() {
  late LlmSettingsCubit cubit;
  late MockLlmSettingsRepository mockRepository;
  late MockDeviceCapabilityService mockDeviceCapabilityService;
  late MockLlmAdapter mockLlmAdapter;

  final testConfig = LlmConfig(
    selectedModel: 'gemini-2.0-flash',
    localModelId: 'gemma-3-270m',
  );

  final testCapability = DeviceCapability(
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

    when(() => mockRepository.getLlmConfig()).thenAnswer((_) async => testConfig);
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

  test('loadSettings updates installed models', () async {
    when(() => mockLlmAdapter.listInstalledModels()).thenAnswer((_) async => ['gemma-3-270m']);

    await cubit.loadSettings();

    expect(cubit.state, isA<LlmSettingsLoaded>());
    final loadedState = cubit.state as LlmSettingsLoaded;
    expect(loadedState.installedModels, contains('gemma-3-270m'));
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

    await cubit.loadSettings();
    await cubit.downloadModel('gemma-3-270m');

    expect((cubit.state as LlmSettingsLoaded).downloadProgress.containsKey('gemma-3-270m'), isTrue);

    await cubit.cancelDownload('gemma-3-270m');

    expect((cubit.state as LlmSettingsLoaded).downloadProgress.containsKey('gemma-3-270m'), isFalse);
    expect(progressController.hasListener, isFalse);
  });

  test('deleteModel uninstalls and refreshes list', () async {
    when(() => mockLlmAdapter.listInstalledModels()).thenAnswer((_) async => []);

    await cubit.loadSettings();
    await cubit.deleteModel('gemma-3-270m');

    expect((cubit.state as LlmSettingsLoaded).installedModels, isEmpty);
  });
}
