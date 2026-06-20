import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/settings/domain/entities/app_settings.dart';

void main() {
  group('AppSettings Entity', () {
    test('copyWith should change specified values', () {
      final settings = AppSettings(themeMode: 'dark');
      final updated = settings.copyWith(themeMode: 'light');
      expect(updated.themeMode, 'light');
      expect(updated.languageCode, settings.languageCode);
    });

    test('toString returns correct format', () {
      final settings = AppSettings(themeMode: 'system', languageCode: 'en');
      expect(settings.toString(), contains('themeMode: system'));
      expect(settings.toString(), contains('languageCode: en'));
    });

    test('default values are correct', () {
      final settings = AppSettings();
      expect(settings.themeMode, 'dark');
      expect(settings.languageCode, 'es');
      expect(settings.notificationsEnabled, true);
    });
  });
}
