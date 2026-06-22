import 'package:injectable/injectable.dart';
import '../models/dashboard_stats_dto.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardStatsDto> getRemoteDashboardStats();
  Future<List<ActivityItemDto>> getRemoteRecentActivity();
}

@LazySingleton(as: DashboardRemoteDataSource)
class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  // In a real app, this would use Dio to fetch from an API
  // For now, we'll return mock data or throw if not implemented

  @override
  Future<DashboardStatsDto> getRemoteDashboardStats() async {
    // Simulating remote fetch
    return const DashboardStatsDto(
      totalMedications: 0,
      reportsCount: 0,
    );
  }

  @override
  Future<List<ActivityItemDto>> getRemoteRecentActivity() async {
    return [];
  }
}
