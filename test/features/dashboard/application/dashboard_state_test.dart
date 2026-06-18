import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/dashboard/application/dashboard_state.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/activity_item.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/dashboard_stats.dart';

void main() {
  group('DashboardState', () {
    group('DashboardInitial', () {
      test('supports value equality', () {
        expect(const DashboardInitial(), equals(const DashboardInitial()));
      });

      test('props are empty', () {
        expect(const DashboardInitial().props, []);
      });
    });

    group('DashboardLoading', () {
      test('supports value equality', () {
        expect(const DashboardLoading(), equals(const DashboardLoading()));
      });

      test('props are empty', () {
        expect(const DashboardLoading().props, []);
      });
    });

    group('DashboardLoaded', () {
      final stats = DashboardStats(
        totalMedications: 10,
        reportsCount: 5,
        lastVitalCheck: DateTime(2023, 1, 1),
      );
      final activities = [
        ActivityItem(
          id: '1',
          title: 'Activity 1',
          timestamp: DateTime(2023, 1, 1),
          type: ActivityType.vitalCheck,
        ),
      ];

      test('supports value equality', () {
        expect(
          DashboardLoaded(stats: stats, activities: activities),
          equals(DashboardLoaded(stats: stats, activities: activities)),
        );
      });

      test('props are correct', () {
        expect(
          DashboardLoaded(stats: stats, activities: activities).props,
          [stats, activities],
        );
      });

      test('different stats are not equal', () {
        final otherStats = DashboardStats(
          totalMedications: 20,
          reportsCount: 10,
          lastVitalCheck: DateTime(2023, 1, 1),
        );
        expect(
          DashboardLoaded(stats: stats, activities: activities),
          isNot(
            equals(DashboardLoaded(stats: otherStats, activities: activities)),
          ),
        );
      });

      test('different activities are not equal', () {
        expect(
          DashboardLoaded(stats: stats, activities: activities),
          isNot(equals(DashboardLoaded(stats: stats, activities: const []))),
        );
      });
    });

    group('DashboardError', () {
      test('supports value equality', () {
        expect(
          const DashboardError('err'),
          equals(const DashboardError('err')),
        );
      });

      test('different messages are not equal', () {
        expect(
          const DashboardError('err1'),
          isNot(equals(const DashboardError('err2'))),
        );
      });

      test('props contain message', () {
        expect(const DashboardError('test error').props, ['test error']);
      });
    });
  });
}
