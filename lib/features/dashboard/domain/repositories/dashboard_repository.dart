import '../entities/dashboard_stats.dart';
import '../entities/activity_item.dart';

abstract class DashboardRepository {
  Future<DashboardStats> getDashboardStats();
  Future<List<ActivityItem>> getRecentActivity();
}
