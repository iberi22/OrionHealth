import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import '../domain/entities/llm_config.dart';
import '../domain/entities/app_settings.dart';
import '../domain/repositories/settings_repository.dart';
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
  final SettingsRepository _repository;
  final DeviceCapabilityService _deviceCapabilityService;
  final LlmAdapter _llmAdapter;

  final Map<String, StreamSubscription<int>> _downloadSubscriptions = {};

  LlmSettingsCubit(
    this._repository,
    this._deviceCapabilityService,
    @Named('gemma') this._llmAdapter,
  ) : super(LlmSettingsInitial());

  @override
  Future<void> close() {
    for (final subscription in _downloadSubscriptions.values) {
      subscription.cancel();
    }
    return super.close();
  }

  Future<void> loadSettings() async {
    emit(LlmSettingsLoading());
    try {
      final config = await _repository.getLlmConfig();
      final appSettings = await _repository.getAppSettings();
      final capability = await _deviceCapabilityService.detectCapability();

      final currentConfig = config ?? LlmConfig(
        selectedModel: capability.recommendedModel,
        useCloudApi: true,
        allowCloudApiCalls: true,
        deviceCapabilityTier: capability.tier.name,
        recommendedModel: capability.recommendedModel,
      );

      final currentAppSettings = appSettings ?? AppSettings();

      if (config == null) await _repository.saveLlmConfig(currentConfig);
      if (appSettings == null) await _repository.saveAppSettings(currentAppSettings);

      emit(LlmSettingsLoaded(
        config: currentConfig.copyWith(
          deviceCapabilityTier: capability.tier.name,
          recommendedModel: capability.recommendedModel,
        ),
        appSettings: currentAppSettings,
        deviceCapability: capability,
      ));

      await _refreshInstalledModels();
    } catch (e) {
      emit(LlmSettingsError(e.toString()));
    }
  }

  // --- LLM Config Updates ---

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

  Future<void> updateProviderType(String type) async {
    final currentState = state;
    if (currentState is LlmSettingsLoaded) {
      final updatedConfig = currentState.config.copyWith(providerType: type);
      await _repository.saveLlmConfig(updatedConfig);
      emit(currentState.copyWith(config: updatedConfig));
    }
  }

  Future<void> updateApiKey(String apiKey) async {
    final currentState = state;
    if (currentState is LlmSettingsLoaded) {
      final updatedConfig = currentState.config.copyWith(apiKey: apiKey);
      await _repository.saveLlmConfig(updatedConfig);
      emit(currentState.copyWith(config: updatedConfig));
    }
  }

  Future<void> updateBaseUrl(String url) async {
    final currentState = state;
    if (currentState is LlmSettingsLoaded) {
      final updatedConfig = currentState.config.copyWith(baseUrl: url);
      await _repository.saveLlmConfig(updatedConfig);
      emit(currentState.copyWith(config: updatedConfig));
    }
  }

  Future<void> updateCloudModel(String model) async {
    final currentState = state;
    if (currentState is LlmSettingsLoaded) {
      final updatedConfig = currentState.config.copyWith(cloudModel: model);
      await _repository.saveLlmConfig(updatedConfig);
      emit(currentState.copyWith(config: updatedConfig));
    }
  }

  Future<void> updateLocalModel(String modelId) async {
    final currentState = state;
    if (currentState is LlmSettingsLoaded) {
      final updatedConfig = currentState.config.copyWith(localModelId: modelId);
      await _repository.saveLlmConfig(updatedConfig);
      emit(currentState.copyWith(config: updatedConfig));
    }
  }

  // --- General App Settings Updates ---

  Future<void> updateThemeMode(String themeMode) async {
    final currentState = state;
    if (currentState is LlmSettingsLoaded) {
      final updatedSettings = currentState.appSettings.copyWith(themeMode: themeMode);
      await _repository.saveAppSettings(updatedSettings);
      emit(currentState.copyWith(appSettings: updatedSettings));
    }
  }

  Future<void> updateLanguage(String languageCode) async {
    final currentState = state;
    if (currentState is LlmSettingsLoaded) {
      final updatedSettings = currentState.appSettings.copyWith(languageCode: languageCode);
      await _repository.saveAppSettings(updatedSettings);
      emit(currentState.copyWith(appSettings: updatedSettings));
    }
  }

  Future<void> updateNotificationsEnabled(bool enabled) async {
    final currentState = state;
    if (currentState is LlmSettingsLoaded) {
      final updatedSettings = currentState.appSettings.copyWith(notificationsEnabled: enabled);
      await _repository.saveAppSettings(updatedSettings);
      emit(currentState.copyWith(appSettings: updatedSettings));
    }
  }

  // --- Data Operations ---

  Future<void> exportData() async {
    final currentState = state;
    if (currentState is LlmSettingsLoaded) {
      try {
        final data = await _repository.exportData();
        emit(currentState.copyWith(exportData: data));
      } catch (e) {
        emit(currentState.copyWith(connectionError: 'Export failed: $e'));
      }
    }
  }

  Future<void> importData(String data) async {
    final currentState = state;
    if (currentState is LlmSettingsLoaded) {
      try {
        await _repository.importData(data);
        await loadSettings();
      } catch (e) {
        emit(currentState.copyWith(connectionError: 'Import failed: $e'));
      }
    }
  }

  // --- Model Management ---

  Future<void> _refreshInstalledModels() async {
    final currentState = state;
    if (currentState is LlmSettingsLoaded) {
      try {
        final installed = await _llmAdapter.listInstalledModels();
        emit(currentState.copyWith(installedModels: installed.toSet()));
      } catch (_) {}
    }
  }

  Future<void> downloadModel(String modelId) async {
    final currentState = state;
    if (currentState is LlmSettingsLoaded) {
      if (_downloadSubscriptions.containsKey(modelId)) return;

      final descriptor = kAvailableLocalModels.firstWhere(
        (m) => m.id == modelId,
        orElse: () => throw ArgumentError('Unknown model: $modelId'),
      );

      final subscription = _llmAdapter
          .installModel(modelId: modelId, url: descriptor.url)
          .listen(
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
          }
          _refreshInstalledModels();
        },
        onError: (e) {
          _downloadSubscriptions.remove(modelId);
          final updatedState = state;
          if (updatedState is LlmSettingsLoaded) {
            final newProgress = Map<String, double>.from(updatedState.downloadProgress);
            newProgress.remove(modelId);
            emit(updatedState.copyWith(
              downloadProgress: newProgress,
              connectionError: 'Download failed: $e',
            ));
          }
        },
      );

      _downloadSubscriptions[modelId] = subscription;

      final newProgress = Map<String, double>.from(currentState.downloadProgress);
      newProgress[modelId] = 0.0;
      emit(currentState.copyWith(downloadProgress: newProgress));
    }
  }

  Future<void> cancelDownload(String modelId) async {
    final subscription = _downloadSubscriptions.remove(modelId);
    if (subscription != null) {
      await subscription.cancel();
      await _llmAdapter.cancelDownload(modelId);
      final currentState = state;
      if (currentState is LlmSettingsLoaded) {
        final newProgress = Map<String, double>.from(currentState.downloadProgress);
        newProgress.remove(modelId);
        emit(currentState.copyWith(downloadProgress: newProgress));
      }
    }
  }

  Future<void> deleteModel(String modelId) async {
    try {
      await _llmAdapter.uninstallModel(modelId);
      await _refreshInstalledModels();
    } catch (e) {
      final currentState = state;
      if (currentState is LlmSettingsLoaded) {
        emit(currentState.copyWith(connectionError: 'Delete failed: $e'));
      }
    }
  }

  // --- Connection Verification ---

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
          final verified = await _testOpenAIConnection(baseUrl, apiKey);
          emit(currentState.copyWith(
            connectionVerified: verified,
            connectionError: verified ? null : 'Connection failed. Check url and API key.',
          ));
        } else if (config.providerType == 'gemini') {
          final hasKey = Platform.environment['GEMINI_API_KEY']?.isNotEmpty ?? false;
          emit(currentState.copyWith(
            connectionVerified: hasKey,
            connectionError: hasKey ? null : 'GEMINI_API_KEY not configured.',
          ));
        } else {
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
