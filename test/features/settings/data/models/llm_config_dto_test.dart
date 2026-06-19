import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/settings/data/models/llm_config_dto.dart';
import 'package:orionhealth_health/features/settings/domain/entities/llm_config.dart';

void main() {
  group('LlmConfigDto', () {
    test('should have correct default values', () {
      const dto = LlmConfigDto();
      expect(dto.selectedModel, 'gemini-2.0-flash');
      expect(dto.useCloudApi, true);
      expect(dto.allowCloudApiCalls, true);
      expect(dto.deviceCapabilityTier, 'medium');
      expect(dto.providerType, 'local');
    });

    test('fromEntity should create a DTO from an entity', () {
      final entity = LlmConfig(
        selectedModel: 'model1',
        useCloudApi: false,
        allowCloudApiCalls: false,
        deviceCapabilityTier: 'low',
        recommendedModel: 'rec1',
        providerType: 'openai',
        apiKey: 'key1',
        baseUrl: 'base1',
        cloudModel: 'cloud1',
        localModelId: 'local1',
      );

      final dto = LlmConfigDto.fromEntity(entity);

      expect(dto.selectedModel, 'model1');
      expect(dto.useCloudApi, false);
      expect(dto.allowCloudApiCalls, false);
      expect(dto.deviceCapabilityTier, 'low');
      expect(dto.recommendedModel, 'rec1');
      expect(dto.providerType, 'openai');
      expect(dto.apiKey, 'key1');
      expect(dto.baseUrl, 'base1');
      expect(dto.cloudModel, 'cloud1');
      expect(dto.localModelId, 'local1');
    });

    test('toEntity should create an entity from a DTO', () {
      const dto = LlmConfigDto(
        selectedModel: 'model1',
        useCloudApi: false,
        allowCloudApiCalls: false,
        deviceCapabilityTier: 'low',
        recommendedModel: 'rec1',
        providerType: 'openai',
        apiKey: 'key1',
        baseUrl: 'base1',
        cloudModel: 'cloud1',
        localModelId: 'local1',
      );

      final entity = dto.toEntity();

      expect(entity.selectedModel, 'model1');
      expect(entity.useCloudApi, false);
      expect(entity.allowCloudApiCalls, false);
      expect(entity.deviceCapabilityTier, 'low');
      expect(entity.recommendedModel, 'rec1');
      expect(entity.providerType, 'openai');
      expect(entity.apiKey, 'key1');
      expect(entity.baseUrl, 'base1');
      expect(entity.cloudModel, 'cloud1');
      expect(entity.localModelId, 'local1');
    });

    test('toJson should return a correct map', () {
      const dto = LlmConfigDto(
        selectedModel: 'model1',
        useCloudApi: true,
        recommendedModel: 'rec1',
        apiKey: 'key1',
      );

      final json = dto.toJson();

      expect(json['selectedModel'], 'model1');
      expect(json['useCloudApi'], true);
      expect(json['recommendedModel'], 'rec1');
      expect(json['apiKey'], 'key1');
      expect(json.containsKey('baseUrl'), isFalse);
    });

    test('fromJson should create a DTO from a map', () {
      final json = {
        'selectedModel': 'model1',
        'useCloudApi': false,
        'deviceCapabilityTier': 'high',
        'providerType': 'gemini',
        'localModelId': 'local1',
      };

      final dto = LlmConfigDto.fromJson(json);

      expect(dto.selectedModel, 'model1');
      expect(dto.useCloudApi, false);
      expect(dto.deviceCapabilityTier, 'high');
      expect(dto.providerType, 'gemini');
      expect(dto.localModelId, 'local1');
      expect(dto.apiKey, isNull);
    });

    test('fromJson should use default values for missing fields', () {
      final dto = LlmConfigDto.fromJson({});
      expect(dto.selectedModel, 'gemini-2.0-flash');
      expect(dto.useCloudApi, true);
    });
  });
}
