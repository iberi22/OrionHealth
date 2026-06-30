import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/settings/domain/entities/app_settings.dart';

void main() {
  group('AppSettings Entity (Data layer perspective)', () {
    // AppSettings is used directly with Isar in this project (as seen in SettingsLocalDataSource),
    // so it doesn't have a separate DTO. We test its persistence-related aspects if any.

    test('should be able to create from default constructor', () {
      final settings = AppSettings();
      expect(settings.themeMode, 'dark');
    });

    test('copyWith should maintain ID', () {
      final settings = AppSettings()..id = 123;
      final updated = settings.copyWith(themeMode: 'light');
      expect(updated.id, 123);
      expect(updated.themeMode, 'light');
    });
  });
}
