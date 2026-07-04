import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/dashboard/application/dashboard_state.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/dashboard_stats.dart';

void main() {
  group('DashboardState Types', () {
    test('DashboardInitial is a DashboardState', () {
      expect(const DashboardInitial(), isA<DashboardState>());
    });

    test('DashboardLoading is a DashboardState', () {
      expect(const DashboardLoading(), isA<DashboardState>());
    });

    test('DashboardLoaded is a DashboardState', () {
      const stats = DashboardStats(
        totalMedications: 0,
        reportsCount: 0,
      );
      expect(const DashboardLoaded(stats: stats, activities: []), isA<DashboardState>());
    });

    test('DashboardError is a DashboardState', () {
      expect(const DashboardError('error'), isA<DashboardState>());
    });
  });
}
