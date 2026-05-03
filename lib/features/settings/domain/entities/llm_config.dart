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

  LlmConfig({
    this.selectedModel = 'gemini-2.0-flash',
    this.useCloudApi = true,
    this.allowCloudApiCalls = true,
    this.deviceCapabilityTier = 'medium',
    this.recommendedModel,
  });

  LlmConfig copyWith({
    String? selectedModel,
    bool? useCloudApi,
    bool? allowCloudApiCalls,
    String? deviceCapabilityTier,
    String? recommendedModel,
  }) {
    return LlmConfig(
      selectedModel: selectedModel ?? this.selectedModel,
      useCloudApi: useCloudApi ?? this.useCloudApi,
      allowCloudApiCalls: allowCloudApiCalls ?? this.allowCloudApiCalls,
      deviceCapabilityTier: deviceCapabilityTier ?? this.deviceCapabilityTier,
      recommendedModel: recommendedModel ?? this.recommendedModel,
    )..id = id;
  }

  @override
  String toString() {
    return 'LlmConfig(id: $id, selectedModel: $selectedModel, useCloudApi: $useCloudApi, '
        'allowCloudApiCalls: $allowCloudApiCalls, deviceCapabilityTier: $deviceCapabilityTier, '
        'recommendedModel: $recommendedModel)';
  }
}
