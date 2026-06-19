import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/settings/domain/entities/app_settings.dart';

void main() {
  group('AppSettings', () {
    test('should have correct default values', () {
      final settings = AppSettings();
      expect(settings.themeMode, 'dark');
      expect(settings.languageCode, 'es');
      expect(settings.notificationsEnabled, true);
    });

    test('copyWith should return a new object with updated values', () {
      final settings = AppSettings(
        themeMode: 'light',
        languageCode: 'en',
        notificationsEnabled: false,
      );
      settings.id = 1;

      final updated = settings.copyWith(
        themeMode: 'system',
        languageCode: 'fr',
        notificationsEnabled: true,
      );

      expect(updated.id, 1);
      expect(updated.themeMode, 'system');
      expect(updated.languageCode, 'fr');
      expect(updated.notificationsEnabled, true);
    });

    test('copyWith should use original values if parameters are null', () {
      final settings = AppSettings(
        themeMode: 'light',
        languageCode: 'en',
      );
      final updated = settings.copyWith();

      expect(updated.themeMode, 'light');
      expect(updated.languageCode, 'en');
    });

    test('toString should return a descriptive string', () {
      final settings = AppSettings(
        themeMode: 'dark',
        languageCode: 'es',
        notificationsEnabled: true,
      );
      settings.id = 5;

      final str = settings.toString();
      expect(str, contains('AppSettings'));
      expect(str, contains('id: 5'));
      expect(str, contains('themeMode: dark'));
      expect(str, contains('languageCode: es'));
      expect(str, contains('notificationsEnabled: true'));
    });
  });
}
