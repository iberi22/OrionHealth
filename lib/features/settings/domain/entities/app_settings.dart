import 'package:isar/isar.dart';

part 'app_settings.g.dart';

@collection
class AppSettings {
  Id id = Isar.autoIncrement;

  /// Theme mode: 'light', 'dark', 'system'
  String themeMode;

  /// Language code: 'en', 'es', etc.
  String languageCode;

  /// Whether push notifications are enabled
  bool notificationsEnabled;

  AppSettings({
    this.themeMode = 'dark',
    this.languageCode = 'es',
    this.notificationsEnabled = true,
  });

  AppSettings copyWith({
    String? themeMode,
    String? languageCode,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    )..id = id;
  }

  @override
  String toString() {
    return 'AppSettings(id: $id, themeMode: $themeMode, languageCode: $languageCode, notificationsEnabled: $notificationsEnabled)';
  }
}
