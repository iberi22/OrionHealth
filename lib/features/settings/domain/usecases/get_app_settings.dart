import '../entities/app_settings.dart';
import '../repositories/llm_settings_repository.dart';

class GetAppSettings {
  final LlmSettingsRepository repository;
  GetAppSettings(this.repository);

  Future<AppSettings?> call() => repository.getAppSettings();
}
