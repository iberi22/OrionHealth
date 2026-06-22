import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/config/build_config.dart';

void main() {
  group('BuildConfig', () {
    test('default flavor should be dev', () {
      // In tests, if not provided via --dart-define, it defaults to 'dev'
      expect(BuildConfig.flavor, 'dev');
      expect(BuildConfig.isDev, isTrue);
      expect(BuildConfig.isStaging, isFalse);
      expect(BuildConfig.isProd, isFalse);
    });

    test('isTest should be true in test environment', () {
      expect(BuildConfig.isTest, isTrue);
    });
  });
}
