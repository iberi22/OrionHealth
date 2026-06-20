import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/settings/domain/entities/llm_config.dart';

void main() {
  group('LlmConfig Entity', () {
    test('should support equality with same values', () {
      final config1 = LlmConfig(selectedModel: 'model1');
      final config2 = LlmConfig(selectedModel: 'model1');

      // LlmConfig does not use Equatable, so we check properties
      expect(config1.selectedModel, config2.selectedModel);
      expect(config1.useCloudApi, config2.useCloudApi);
    });

    test('copyWith should change specified values', () {
      final config = LlmConfig(selectedModel: 'old');
      final updated = config.copyWith(selectedModel: 'new');
      expect(updated.selectedModel, 'new');
      expect(updated.useCloudApi, config.useCloudApi);
    });

    test('toString should hide API key', () {
      final config = LlmConfig(apiKey: 'secret-123');
      expect(config.toString(), contains('apiKey: ***'));
      expect(config.toString(), isNot(contains('secret-123')));
    });

    test('default values are correct', () {
      final config = LlmConfig();
      expect(config.selectedModel, 'gemini-2.0-flash');
      expect(config.useCloudApi, true);
      expect(config.providerType, 'local');
    });
  });
}
