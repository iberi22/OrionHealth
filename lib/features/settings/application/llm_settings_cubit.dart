import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import '../domain/entities/llm_config.dart';
import '../domain/repositories/llm_settings_repository.dart';
import '../domain/services/device_capability_service.dart';
import '../../local_agent/domain/services/llm_adapter.dart';
import '../../local_agent/domain/entities/local_model_descriptor.dart';

part 'llm_settings_state.dart';

/// Available Gemini cloud models
const List<String> availableGeminiModels = [
  'gemini-2.0-flash',
  'gemini-2.0-flash-lite',
  'gemini-2.5-flash',
  'gemini-2.5-pro',
];

/// Available cloud provider types
const List<String> availableCloudProviders = ['openai', 'gemini'];

/// Available OpenAI-compatible models
const List<String> availableOpenaiModels = [
  'gpt-4o',
  'gpt-4o-mini',
  'gpt-5.4',
  'claude-3-opus',
  'claude-3-sonnet',
];

@injectable
class LlmSettingsCubit extends Cubit<LlmSettingsState> {
  final LlmSettingsRepository _repository;
  final DeviceCapabilityService _deviceCapabilityService;
  final LlmAdapter _llmAdapter;
  final Map<String, StreamSubscription<int>> _downloadSubscriptions = {};

  LlmSettingsCubit(
    this._repository,
    this._deviceCapabilityService,
    @Named('gemma') this._llmAdapter,
  ) : super(LlmSettingsInitial());

  Future<void> loadSettings() async {
    emit(LlmSettingsLoading());
    try {
      final config = await _repository.getLlmConfig();
      final capability = await _deviceCapabilityService.detectCapability();

      if (config != null) {
        emit(LlmSettingsLoaded(
          config: config.copyWith(
            deviceCapabilityTier: capability.tier.name,
            recommendedModel: capability.recommendedModel,
          ),
          deviceCapability: capability,
        ));
      } else {
        // Create default config based on device capability
        final defaultConfig = LlmConfig(
          selectedModel: capability.recommendedModel,
          useCloudApi: true,
          allowCloudApiCalls: true,
          deviceCapabilityTier: capability.tier.name,
          recommendedModel: capability.recommendedModel,
        );
        await _repository.saveLlmConfig(defaultConfig);
        emit(LlmSettingsLoaded(
          config: defaultConfig,
          deviceCapability: capability,
        ));
      }
      await _refreshInstalledModels();
    } catch (e) {
      emit(LlmSettingsError(e.toString()));
    }
  }

  Future<void> updateSelectedModel(String model) async {
    final currentState = state;
    if (currentState is LlmSettingsLoaded) {
      final updatedConfig = currentState.config.copyWith(selectedModel: model);
      await _repository.saveLlmConfig(updatedConfig);
      emit(currentState.copyWith(config: updatedConfig));
    }
  }

  Future<void> updateUseCloudApi(bool useCloud) async {
    final currentState = state;
    if (currentState is LlmSettingsLoaded) {
      final updatedConfig = currentState.config.copyWith(useCloudApi: useCloud);
      await _repository.saveLlmConfig(updatedConfig);
      emit(currentState.copyWith(config: updatedConfig));
    }
  }

  Future<void> updateAllowCloudApiCalls(bool allow) async {
    final currentState = state;
    if (currentState is LlmSettingsLoaded) {
      final updatedConfig = currentState.config.copyWith(allowCloudApiCalls: allow);
      await _repository.saveLlmConfig(updatedConfig);
      emit(currentState.copyWith(config: updatedConfig));
    }
  }

  /// Update the provider type ('local', 'openai', 'gemini')
  Future<void> updateProviderType(String type) async {
    final currentState = state;
    if (currentState is LlmSettingsLoaded) {
      final updatedConfig = currentState.config.copyWith(providerType: type);
      await _repository.saveLlmConfig(updatedConfig);
      emit(currentState.copyWith(config: updatedConfig));
    }
  }

  /// Update the API key for the custom provider
  Future<void> updateApiKey(String apiKey) async {
    final currentState = state;
    if (currentState is LlmSettingsLoaded) {
      final updatedConfig = currentState.config.copyWith(apiKey: apiKey);
      await _repository.saveLlmConfig(updatedConfig);
      emit(currentState.copyWith(config: updatedConfig));
    }
  }

  /// Update the base URL for the custom provider
  Future<void> updateBaseUrl(String url) async {
    final currentState = state;
    if (currentState is LlmSettingsLoaded) {
      final updatedConfig = currentState.config.copyWith(baseUrl: url);
      await _repository.saveLlmConfig(updatedConfig);
      emit(currentState.copyWith(config: updatedConfig));
    }
  }

  /// Update the cloud model name
  Future<void> updateCloudModel(String model) async {
    final currentState = state;
    if (currentState is LlmSettingsLoaded) {
      final updatedConfig = currentState.config.copyWith(cloudModel: model);
      await _repository.saveLlmConfig(updatedConfig);
      emit(currentState.copyWith(config: updatedConfig));
    }
  }

  /// Update the local model identifier
  Future<void> updateLocalModel(String modelId) async {
    final currentState = state;
    if (currentState is LlmSettingsLoaded) {
      final updatedConfig = currentState.config.copyWith(localModelId: modelId);
      await _repository.saveLlmConfig(updatedConfig);
      emit(currentState.copyWith(config: updatedConfig));
    }
  }

  Future<void> _refreshInstalledModels() async {
    final currentState = state;
    if (currentState is LlmSettingsLoaded) {
      try {
        final installedModelsList = await (_llmAdapter as dynamic).listInstalledModels();
        final installedModels = Set<String>.from(installedModelsList as Iterable);
        emit(currentState.copyWith(installedModels: installedModels));
      } catch (e) {
        // Handle error or silenty fail
      }
    }
  }

  void downloadModel(String modelId) {
    final currentState = state;
    if (currentState is LlmSettingsLoaded) {
      final model = kAvailableLocalModels.firstWhere((m) => m.id == modelId);

      // Cancel existing subscription if any
      _downloadSubscriptions[modelId]?.cancel();

      final subscription = (_llmAdapter as dynamic).installModel(
        modelType: model.modelType,
        url: model.url,
        modelId: modelId,
      ).listen(
        (progress) {
          final updatedState = state;
          if (updatedState is LlmSettingsLoaded) {
            final newProgress = Map<String, double>.from(updatedState.downloadProgress);
            newProgress[modelId] = progress / 100.0;
            emit(updatedState.copyWith(downloadProgress: newProgress));
          }
        },
        onDone: () {
          _downloadSubscriptions.remove(modelId);
          final updatedState = state;
          if (updatedState is LlmSettingsLoaded) {
            final newProgress = Map<String, double>.from(updatedState.downloadProgress);
            newProgress.remove(modelId);
            emit(updatedState.copyWith(downloadProgress: newProgress));
            _refreshInstalledModels();
          }
        },
        onError: (e) {
          _downloadSubscriptions.remove(modelId);
          final updatedState = state;
          if (updatedState is LlmSettingsLoaded) {
            final newProgress = Map<String, double>.from(updatedState.downloadProgress);
            newProgress.remove(modelId);
            emit(updatedState.copyWith(downloadProgress: newProgress));
          }
        },
      );

      _downloadSubscriptions[modelId] = subscription;
    }
  }

  void cancelDownload(String modelId) {
    _downloadSubscriptions[modelId]?.cancel();
    _downloadSubscriptions.remove(modelId);
    try {
      (_llmAdapter as dynamic).cancelDownload(modelId);
    } catch (e) {
      // cancelDownload might not be implemented or fail
    }

    final currentState = state;
    if (currentState is LlmSettingsLoaded) {
      final newProgress = Map<String, double>.from(currentState.downloadProgress);
      newProgress.remove(modelId);
      emit(currentState.copyWith(downloadProgress: newProgress));
    }
  }

  Future<void> deleteModel(String modelId) async {
    try {
      await (_llmAdapter as dynamic).uninstallModel(modelId);
      await _refreshInstalledModels();
    } catch (e) {
      // Handle error
    }
  }

  @override
  Future<void> close() {
    for (final sub in _downloadSubscriptions.values) {
      sub.cancel();
    }
    return super.close();
  }

  /// Verify API connection by making a test request
  Future<void> verifyConnection() async {
    final currentState = state;
    if (currentState is LlmSettingsLoaded) {
      emit(currentState.copyWith(
        connectionVerified: null,
        connectionError: null,
      ));

      try {
        final config = currentState.config;
        final baseUrl = config.baseUrl ?? 'https://api.openai.com/v1';
        final apiKey = config.apiKey ?? '';

        if (config.providerType == 'openai' && apiKey.isNotEmpty) {
          // Test OpenAI-compatible connection
          final verified = await _testOpenAIConnection(baseUrl, apiKey);
          emit(currentState.copyWith(
            connectionVerified: verified,
            connectionError: verified ? null : 'Connection failed. Check URL and API key.',
          ));
        } else if (config.providerType == 'gemini') {
          // Gemini uses env var, just report as true if configured
          final hasKey = Platform.environment['GEMINI_API_KEY']?.isNotEmpty ?? false;
          emit(currentState.copyWith(
            connectionVerified: hasKey,
            connectionError: hasKey ? null : 'GEMINI_API_KEY not configured.',
          ));
        } else {
          // Local provider doesn't need connection verification
          emit(currentState.copyWith(
            connectionVerified: true,
            connectionError: null,
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(
          connectionVerified: false,
          connectionError: e.toString(),
        ));
      }
    }
  }

  /// Test an OpenAI-compatible API connection
  Future<bool> _testOpenAIConnection(String baseUrl, String apiKey) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/models'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
