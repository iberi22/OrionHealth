import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class UpdateLanguage {
  final SettingsRepository repository;
  UpdateLanguage(this.repository);

  Future<void> call(String languageCode) async {
    final settings = await repository.getAppSettings() ?? AppSettings();
    await repository.saveAppSettings(settings.copyWith(languageCode: languageCode));
  }
}
