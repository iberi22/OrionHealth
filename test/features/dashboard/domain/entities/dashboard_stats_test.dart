import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/dashboard_stats.dart';

void main() {
  group('DashboardStats', () {
    final now = DateTime.now();

    test('supports value equality', () {
      expect(
        DashboardStats(
          totalMedications: 5,
          reportsCount: 3,
          lastVitalCheck: now,
        ),
        DashboardStats(
          totalMedications: 5,
          reportsCount: 3,
          lastVitalCheck: now,
        ),
      );
    });

    test('props are correct', () {
      final stats = DashboardStats(
        totalMedications: 10,
        reportsCount: 7,
        lastVitalCheck: now,
      );
      expect(stats.props, [10, 7, now]);
    });

    test('lastVitalCheck can be null', () {
      final stats = DashboardStats(
        totalMedications: 0,
        reportsCount: 0,
      );
      expect(stats.lastVitalCheck, isNull);
    });

    test('supports different values', () {
      final stats1 = DashboardStats(totalMedications: 3, reportsCount: 1);
      final stats2 = DashboardStats(totalMedications: 5, reportsCount: 2);
      expect(stats1, isNot(equals(stats2)));
    });
  });
}
