import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/dashboard/application/dashboard_cubit.dart';
import 'package:orionhealth_health/features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';
import 'package:orionhealth_health/features/dashboard/domain/usecases/get_recent_activity_usecase.dart';
import 'package:orionhealth_health/features/dashboard/application/dashboard_state.dart';

class MockGetDashboardStats extends Mock implements GetDashboardStatsUseCase {}
class MockGetRecentActivity extends Mock implements GetRecentActivityUseCase {}

void main() {
  late DashboardCubit cubit;
  late MockGetDashboardStats mockGetDashboardStats;
  late MockGetRecentActivity mockGetRecentActivity;

  setUp(() {
    mockGetDashboardStats = MockGetDashboardStats();
    mockGetRecentActivity = MockGetRecentActivity();
    cubit = DashboardCubit(mockGetDashboardStats, mockGetRecentActivity);
  });

  test('initial state is DashboardInitial', () {
    expect(cubit.state, isA<DashboardInitial>());
  });
}
