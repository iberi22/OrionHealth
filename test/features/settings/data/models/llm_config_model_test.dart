import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/settings/data/models/llm_config_dto.dart';
import 'package:orionhealth_health/features/settings/domain/entities/llm_config.dart';

void main() {
  group('LlmConfigDto', () {
    final tDto = LlmConfigDto(
      selectedModel: 'test-model',
      apiKey: 'test-key',
    );

    final tEntity = LlmConfig(
      selectedModel: 'test-model',
      apiKey: 'test-key',
    );

    test('fromEntity should return a valid DTO', () {
      final result = LlmConfigDto.fromEntity(tEntity);
      expect(result.selectedModel, tEntity.selectedModel);
      expect(result.apiKey, tEntity.apiKey);
    });

    test('toEntity should return a valid Entity', () {
      final result = tDto.toEntity();
      expect(result.selectedModel, tDto.selectedModel);
      expect(result.apiKey, tDto.apiKey);
    });

    test('fromJson should return a valid DTO', () {
      final Map<String, dynamic> jsonMap = {
        'selectedModel': 'test-model',
        'apiKey': 'test-key',
      };
      final result = LlmConfigDto.fromJson(jsonMap);
      expect(result.selectedModel, 'test-model');
      expect(result.apiKey, 'test-key');
    });

    test('toJson should return a JSON map containing proper data', () {
      final result = tDto.toJson();
      final expectedMap = {
        'selectedModel': 'test-model',
        'useCloudApi': true,
        'allowCloudApiCalls': true,
        'deviceCapabilityTier': 'medium',
        'providerType': 'local',
        'apiKey': 'test-key',
      };
      expect(result, expectedMap);
    });
  });
}
