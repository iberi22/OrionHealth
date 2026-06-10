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
    });

    test('copyWith should return a new object with updated values', () {
      final config = LlmConfig(selectedModel: 'model1', apiKey: 'key1');
      config.id = 1;

      final updated = config.copyWith(
        selectedModel: 'model2',
        useCloudApi: false,
      );

      expect(updated.id, 1);
      expect(updated.selectedModel, 'model2');
      expect(updated.useCloudApi, false);
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
  });
}
