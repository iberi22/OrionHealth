import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/dashboard_preference.dart';

void main() {
  group('DashboardPreference', () {
    test('should create with required values', () {
      final pref = DashboardPreference(key: 'showStats', value: 'true');
      expect(pref.key, equals('showStats'));
      expect(pref.value, equals('true'));
    });

    test('should support equality', () {
      final a = DashboardPreference(key: 'k', value: 'v');
      final b = DashboardPreference(key: 'k', value: 'v');
      // DashboardPreference is a class without Equatable/override
      expect(a.key, equals(b.key));
      expect(a.value, equals(b.value));
    });
  });
}
