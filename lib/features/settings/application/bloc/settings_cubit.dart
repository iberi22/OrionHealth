import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/llm_config.dart';
import '../../domain/repositories/settings_repository.dart';

part 'settings_state.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repository;

  SettingsCubit(this._repository) : super(SettingsInitial());

  Future<void> loadSettings() async {
    emit(SettingsLoading());
    try {
      final config = await _repository.getLlmConfig();
      emit(SettingsLoaded(config));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> updateConfig(LlmConfig config) async {
    try {
      await _repository.saveLlmConfig(config);
      emit(SettingsLoaded(config));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> setUseLocalModel(bool useLocal) async {
    if (state is SettingsLoaded) {
      final currentConfig = (state as SettingsLoaded).config;
      final newConfig = currentConfig.copyWith(useLocalModel: useLocal);
      await updateConfig(newConfig);
    }
  }

  Future<void> setModelName(String modelName) async {
    if (state is SettingsLoaded) {
      final currentConfig = (state as SettingsLoaded).config;
      final newConfig = currentConfig.copyWith(modelName: modelName);
      await updateConfig(newConfig);
    }
  }

  Future<void> setApiKey(String apiKey) async {
    if (state is SettingsLoaded) {
      final currentConfig = (state as SettingsLoaded).config;
      final newConfig = currentConfig.copyWith(apiKey: apiKey);
      await updateConfig(newConfig);
    }
  }
}
