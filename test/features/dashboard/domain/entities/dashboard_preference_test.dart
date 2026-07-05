import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/dashboard_preference.dart';

void main() {
  group('DashboardPreference', () {
    test('should create with default values', () {
      const pref = DashboardPreference();
      expect(pref.showStats, isTrue);
      expect(pref.showRecentActivity, isTrue);
    });

    test('should support copyWith', () {
      const pref = DashboardPreference();
      final modified = pref.copyWith(showStats: false);
      expect(modified.showStats, isFalse);
      expect(modified.showRecentActivity, isTrue);
    });

    test('should support equality', () {
      const a = DashboardPreference();
      const b = DashboardPreference();
      expect(a, equals(b));
    });
  });
}
