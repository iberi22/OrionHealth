import '../entities/app_settings.dart';
import '../repositories/llm_settings_repository.dart';

class UpdateTheme {
  final LlmSettingsRepository repository;
  UpdateTheme(this.repository);

  Future<void> call(String themeMode) async {
    final settings = await repository.getAppSettings() ?? AppSettings();
    await repository.saveAppSettings(settings.copyWith(themeMode: themeMode));
  }
}
