import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/llm_config.dart';
import '../../domain/repositories/llm_settings_repository.dart';
import '../../domain/services/device_capability_service.dart';

part 'llm_settings_state.dart';

/// Available Gemini cloud models
const List<String> availableGeminiModels = [
  'gemini-2.0-flash',
  'gemini-2.0-flash-lite',
  'gemini-2.5-flash',
  'gemini-2.5-pro',
];

@injectable
class LlmSettingsCubit extends Cubit<LlmSettingsState> {
  final LlmSettingsRepository _repository;
  final DeviceCapabilityService _deviceCapabilityService;

  LlmSettingsCubit(
    this._repository,
    this._deviceCapabilityService,
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
}
