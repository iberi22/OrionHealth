import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/activity_item.dart';
import 'package:orionhealth_health/features/dashboard/domain/repositories/dashboard_repository.dart';

class MockDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardStats> getDashboardStats() async {
    return const DashboardStats(totalPatients: 0, activeAppointments: 0, pendingReports: 0);
  }

  @override
  Future<List<ActivityItem>> getRecentActivity() async {
    return [];
  }
}

void main() {
  late MockDashboardRepository repository;

  setUp(() {
    repository = MockDashboardRepository();
  });

  group('DashboardRepository', () {
    test('getDashboardStats should return DashboardStats', () async {
      final stats = await repository.getDashboardStats();
      expect(stats, isA<DashboardStats>());
    });

    test('getRecentActivity should return list', () async {
      final activities = await repository.getRecentActivity();
      expect(activities, isA<List<ActivityItem>>());
    });
  });
}
