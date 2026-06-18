import '../entities/app_settings.dart';
import '../repositories/llm_settings_repository.dart';

class UpdateNotifications {
  final LlmSettingsRepository repository;
  UpdateNotifications(this.repository);

  Future<void> call(bool enabled) async {
    final settings = await repository.getAppSettings() ?? AppSettings();
    await repository.saveAppSettings(settings.copyWith(notificationsEnabled: enabled));
  }
}
