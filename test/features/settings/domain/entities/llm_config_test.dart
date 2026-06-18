import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/settings/domain/entities/llm_config.dart';

void main() {
  group('LlmConfig', () {
    test('should have correct default values', () {
      final config = LlmConfig();
      expect(config.selectedModel, 'gemini-2.0-flash');
      expect(config.useCloudApi, true);
      expect(config.allowCloudApiCalls, true);
      expect(config.deviceCapabilityTier, 'medium');
      expect(config.providerType, 'local');
      expect(config.cloudModel, 'gpt-4o');
      expect(config.recommendedModel, isNull);
      expect(config.apiKey, isNull);
      expect(config.baseUrl, isNull);
      expect(config.localModelId, isNull);
    });

    test('copyWith should return a new object with updated values', () {
      final config = LlmConfig(
        selectedModel: 'model1',
        useCloudApi: true,
        allowCloudApiCalls: true,
        deviceCapabilityTier: 'low',
        recommendedModel: 'rec1',
        providerType: 'openai',
        apiKey: 'key1',
        baseUrl: 'base1',
        cloudModel: 'cloud1',
        localModelId: 'local1',
      );
      config.id = 1;

      final updated = config.copyWith(
        selectedModel: 'model2',
        useCloudApi: false,
        allowCloudApiCalls: false,
        deviceCapabilityTier: 'high',
        recommendedModel: 'rec2',
        providerType: 'gemini',
        apiKey: 'key2',
        baseUrl: 'base2',
        cloudModel: 'cloud2',
        localModelId: 'local2',
      );

      expect(updated.id, 1);
      expect(updated.selectedModel, 'model2');
      expect(updated.useCloudApi, false);
      expect(updated.allowCloudApiCalls, false);
      expect(updated.deviceCapabilityTier, 'high');
      expect(updated.recommendedModel, 'rec2');
      expect(updated.providerType, 'gemini');
      expect(updated.apiKey, 'key2');
      expect(updated.baseUrl, 'base2');
      expect(updated.cloudModel, 'cloud2');
      expect(updated.localModelId, 'local2');
    });

    test('copyWith should use original values if parameters are null', () {
      final config = LlmConfig(
        selectedModel: 'model1',
        apiKey: 'key1',
      );
      final updated = config.copyWith();

      expect(updated.selectedModel, 'model1');
      expect(updated.apiKey, 'key1');
    });

    test('toString should return a descriptive string and mask apiKey', () {
      final config = LlmConfig(
        selectedModel: 'test-model',
        apiKey: 'secret-key',
      );
      config.id = 10;

      final str = config.toString();
      expect(str, contains('LlmConfig'));
      expect(str, contains('id: 10'));
      expect(str, contains('selectedModel: test-model'));
      expect(str, contains('apiKey: ***'));
      expect(str, isNot(contains('secret-key')));
    });

    test('toString should handle null apiKey', () {
      final config = LlmConfig(apiKey: null);
      expect(config.toString(), contains('apiKey: null'));
    });
  });
}
