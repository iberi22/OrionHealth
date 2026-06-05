import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/llm_adapter.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/services/llm_adapter_factory.dart';
import 'package:orionhealth_health/features/settings/domain/entities/llm_config.dart';
import 'package:orionhealth_health/features/settings/domain/repositories/llm_settings_repository.dart';

class MockLlmSettingsRepository extends Mock implements LlmSettingsRepository {}
class MockLlmAdapter extends Mock implements LlmAdapter {}

void main() {
  late LlmAdapterFactory factory;
  late MockLlmSettingsRepository mockSettingsRepo;
  late GetIt getIt;

  setUp(() {
    getIt = GetIt.instance;
    getIt.reset();
    mockSettingsRepo = MockLlmSettingsRepository();
    factory = LlmAdapterFactory(mockSettingsRepo);
  });

  group('LlmAdapterFactory', () {
    test('returns gemma adapter when provider is local', () async {
      final mockGemma = MockLlmAdapter();
      getIt.registerSingleton<LlmAdapter>(mockGemma, instanceName: 'gemma');

      when(() => mockSettingsRepo.getLlmConfig()).thenAnswer((_) async => LlmConfig(
        providerType: 'local',
        selectedModel: 'gemma-3-270m',
      ));

      final adapter = await factory.getAdapter();
      expect(adapter, equals(mockGemma));
    });

    test('returns gemini adapter when provider is gemini', () async {
      final mockGemini = MockLlmAdapter();
      getIt.registerSingleton<LlmAdapter>(mockGemini, instanceName: 'gemini');

      when(() => mockSettingsRepo.getLlmConfig()).thenAnswer((_) async => LlmConfig(
        providerType: 'gemini',
        selectedModel: 'gemini-pro',
      ));

      final adapter = await factory.getAdapter();
      expect(adapter, equals(mockGemini));
    });

    test('returns mock adapter when provider is mock', () async {
      final mockAdapter = MockLlmAdapter();
      getIt.registerSingleton<LlmAdapter>(mockAdapter, instanceName: 'mock');

      when(() => mockSettingsRepo.getLlmConfig()).thenAnswer((_) async => LlmConfig(
        providerType: 'mock',
        selectedModel: 'mock-local',
      ));

      final adapter = await factory.getAdapter();
      expect(adapter, equals(mockAdapter));
    });

    test('defaults to gemma when config is missing', () async {
      final mockGemma = MockLlmAdapter();
      getIt.registerSingleton<LlmAdapter>(mockGemma, instanceName: 'gemma');

      when(() => mockSettingsRepo.getLlmConfig()).thenAnswer((_) async => null);

      final adapter = await factory.getAdapter();
      expect(adapter, equals(mockGemma));
    });
  });
}
