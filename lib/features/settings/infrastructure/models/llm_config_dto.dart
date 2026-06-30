import '../../domain/entities/llm_config.dart';

class LlmConfigDto {
  final String selectedModel;
  final bool useCloudApi;
  final bool allowCloudApiCalls;
  final String deviceCapabilityTier;
  final String? recommendedModel;
  final String providerType;
  final String? apiKey;
  final String? baseUrl;
  final String? cloudModel;
  final String? localModelId;

  const LlmConfigDto({
    this.selectedModel = 'gemini-2.0-flash',
    this.useCloudApi = true,
    this.allowCloudApiCalls = true,
    this.deviceCapabilityTier = 'medium',
    this.recommendedModel,
    this.providerType = 'local',
    this.apiKey,
    this.baseUrl,
    this.cloudModel,
    this.localModelId,
  });

  factory LlmConfigDto.fromEntity(LlmConfig e) => LlmConfigDto(
        selectedModel: e.selectedModel,
        useCloudApi: e.useCloudApi,
        allowCloudApiCalls: e.allowCloudApiCalls,
        deviceCapabilityTier: e.deviceCapabilityTier,
        recommendedModel: e.recommendedModel,
        providerType: e.providerType,
        apiKey: e.apiKey,
        baseUrl: e.baseUrl,
        cloudModel: e.cloudModel,
        localModelId: e.localModelId,
      );

  LlmConfig toEntity() => LlmConfig(
        selectedModel: selectedModel,
        useCloudApi: useCloudApi,
        allowCloudApiCalls: allowCloudApiCalls,
        deviceCapabilityTier: deviceCapabilityTier,
        recommendedModel: recommendedModel,
        providerType: providerType,
        apiKey: apiKey,
        baseUrl: baseUrl,
        cloudModel: cloudModel,
        localModelId: localModelId,
      );

  Map<String, dynamic> toJson() => {
        'selectedModel': selectedModel,
        'useCloudApi': useCloudApi,
        'allowCloudApiCalls': allowCloudApiCalls,
        'deviceCapabilityTier': deviceCapabilityTier,
        if (recommendedModel != null) 'recommendedModel': recommendedModel,
        'providerType': providerType,
        if (apiKey != null) 'apiKey': apiKey,
        if (baseUrl != null) 'baseUrl': baseUrl,
        if (cloudModel != null) 'cloudModel': cloudModel,
        if (localModelId != null) 'localModelId': localModelId,
      };

  factory LlmConfigDto.fromJson(Map<String, dynamic> j) => LlmConfigDto(
        selectedModel: j['selectedModel'] as String? ?? 'gemini-2.0-flash',
        useCloudApi: j['useCloudApi'] as bool? ?? true,
        allowCloudApiCalls: j['allowCloudApiCalls'] as bool? ?? true,
        deviceCapabilityTier: j['deviceCapabilityTier'] as String? ?? 'medium',
        recommendedModel: j['recommendedModel'] as String?,
        providerType: j['providerType'] as String? ?? 'local',
        apiKey: j['apiKey'] as String?,
        baseUrl: j['baseUrl'] as String?,
        cloudModel: j['cloudModel'] as String?,
        localModelId: j['localModelId'] as String?,
      );
}
