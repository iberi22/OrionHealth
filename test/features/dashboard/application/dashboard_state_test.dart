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
        totalPatients: 10,
        activePatients: 5,
        alertsCount: 2,
      );
      final activities = [
        const ActivityItem(id: '1', title: 'Activity 1', timestamp: null),
      ];

      test('supports value equality', () {
        expect(
          const DashboardLoaded(stats: stats, activities: activities),
          equals(const DashboardLoaded(stats: stats, activities: activities)),
        );
      });

      test('props are correct', () {
        expect(
          const DashboardLoaded(stats: stats, activities: activities).props,
          [stats, activities],
        );
      });

      test('different stats are not equal', () {
        final otherStats = DashboardStats(
          totalPatients: 20,
          activePatients: 10,
          alertsCount: 5,
        );
        expect(
          const DashboardLoaded(stats: stats, activities: activities),
          isNot(
            equals(DashboardLoaded(stats: otherStats, activities: activities)),
          ),
        );
      });

      test('different activities are not equal', () {
        expect(
          const DashboardLoaded(stats: stats, activities: activities),
          isNot(equals(const DashboardLoaded(stats: stats, activities: []))),
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
