import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class UpdateTheme {
  final SettingsRepository repository;
  UpdateTheme(this.repository);

  Future<void> call(String themeMode) async {
    final settings = await repository.getAppSettings() ?? AppSettings();
    await repository.saveAppSettings(settings.copyWith(themeMode: themeMode));
  }
}
