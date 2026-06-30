import 'package:isar/isar.dart';

part 'llm_config.g.dart';

@collection
class LlmConfig {
  Id id = Isar.autoIncrement;

  /// Selected model identifier (e.g., 'gemini-2.0-flash', 'gemini-2.5-flash')
  String selectedModel;

  /// Whether to use cloud API or local Gemma via GemmaLlmAdapter
  bool useCloudApi;

  /// Whether cloud API calls are allowed (privacy toggle)
  bool allowCloudApiCalls;

  /// Device capability tier: 'low', 'medium', 'high'
  String deviceCapabilityTier;

  /// Recommended model based on device capability
  String? recommendedModel;

  /// Provider type: 'local', 'openai', 'gemini'
  String providerType;

  /// User-provided API key for custom provider (OpenAI-compatible or Anthropic)
  String? apiKey;

  /// Base url for custom provider (e.g., https://api.openai.com/v1)
  String? baseUrl;

  /// Selected cloud model name (e.g., 'gpt-4o', 'claude-3-opus')
  String? cloudModel;

  /// Local model identifier (e.g., 'qwen3-0.6b', 'deepseek-r1')
  String? localModelId;

  LlmConfig({
    this.selectedModel = 'gemini-2.0-flash',
    this.useCloudApi = true,
    this.allowCloudApiCalls = true,
    this.deviceCapabilityTier = 'medium',
    this.recommendedModel,
    this.providerType = 'local',
    this.apiKey,
    this.baseUrl,
    this.cloudModel = 'gpt-4o',
    this.localModelId,
  });

  LlmConfig copyWith({
    String? selectedModel,
    bool? useCloudApi,
    bool? allowCloudApiCalls,
    String? deviceCapabilityTier,
    String? recommendedModel,
    String? providerType,
    String? apiKey,
    String? baseUrl,
    String? cloudModel,
    String? localModelId,
  }) {
    return LlmConfig(
      selectedModel: selectedModel ?? this.selectedModel,
      useCloudApi: useCloudApi ?? this.useCloudApi,
      allowCloudApiCalls: allowCloudApiCalls ?? this.allowCloudApiCalls,
      deviceCapabilityTier: deviceCapabilityTier ?? this.deviceCapabilityTier,
      recommendedModel: recommendedModel ?? this.recommendedModel,
      providerType: providerType ?? this.providerType,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      cloudModel: cloudModel ?? this.cloudModel,
      localModelId: localModelId ?? this.localModelId,
    )..id = id;
  }

  @override
  String toString() {
    return 'LlmConfig(id: $id, selectedModel: $selectedModel, useCloudApi: $useCloudApi, '
        'allowCloudApiCalls: $allowCloudApiCalls, deviceCapabilityTier: $deviceCapabilityTier, '
        'recommendedModel: $recommendedModel, providerType: $providerType, '
        'apiKey: ${apiKey != null ? '***' : null}, baseUrl: $baseUrl, '
        'cloudModel: $cloudModel, localModelId: $localModelId)';
  }
}
