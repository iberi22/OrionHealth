import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../domain/services/llm_adapter.dart';

@lazySingleton
class LlmAdapterFactory {
  final GetIt _getIt = GetIt.instance;
  final SettingsRepository _settingsRepository;

  LlmAdapterFactory(this._settingsRepository);

  Future<LlmAdapter> getAdapter() async {
    final config = await _settingsRepository.getLlmConfig();
    final providerType = config?.providerType ?? 'local';

    switch (providerType) {
      case 'gemini':
        return _getIt<LlmAdapter>(instanceName: 'gemini');
      case 'openai':
        return _getIt<LlmAdapter>(instanceName: 'openai');
      case 'mock':
        return _getIt<LlmAdapter>(instanceName: 'mock');
      case 'local':
      default:
        return _getIt<LlmAdapter>(instanceName: 'gemma');
    }
  }
}
