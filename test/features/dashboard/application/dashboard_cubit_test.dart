import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/dashboard/application/dashboard_cubit.dart';
import 'package:orionhealth_health/features/dashboard/application/dashboard_state.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/activity_item.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:orionhealth_health/features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';
import 'package:orionhealth_health/features/dashboard/domain/usecases/get_recent_activity_usecase.dart';

class MockGetDashboardStatsUseCase extends Mock implements GetDashboardStatsUseCase {}
class MockGetRecentActivityUseCase extends Mock implements GetRecentActivityUseCase {}

void main() {
  late DashboardCubit cubit;
  late MockGetDashboardStatsUseCase mockGetDashboardStats;
  late MockGetRecentActivityUseCase mockGetRecentActivity;

  setUp(() {
    mockGetDashboardStats = MockGetDashboardStatsUseCase();
    mockGetRecentActivity = MockGetRecentActivityUseCase();
    cubit = DashboardCubit(mockGetDashboardStats, mockGetRecentActivity);
  });

  tearDown(() {
    cubit.close();
  });

  group('DashboardCubit', () {
    final tStats = DashboardStats(
      totalMedications: 5,
      reportsCount: 2,
      lastVitalCheck: DateTime.now(),
    );
    final tActivities = [
      ActivityItem(
        id: '1',
        title: 'Activity 1',
        timestamp: DateTime.now(),
        type: ActivityType.vitalCheck,
      ),
    ];

    test('initial state is DashboardInitial', () {
      expect(cubit.state, DashboardInitial());
    });

    test('emits [DashboardLoading, DashboardLoaded] when loadDashboardData is successful', () async {
      // arrange
      when(() => mockGetDashboardStats()).thenAnswer((_) async => tStats);
      when(() => mockGetRecentActivity()).thenAnswer((_) async => tActivities);

      // act
      final future = cubit.loadDashboardData();

      // assert
      expect(cubit.state, DashboardLoading());
      await future;
      expect(cubit.state, DashboardLoaded(stats: tStats, activities: tActivities));
    });

    test('emits [DashboardLoading, DashboardError] when loadDashboardData fails', () async {
      // arrange
      when(() => mockGetDashboardStats()).thenThrow(Exception('Failed to load stats'));

      // act
      final future = cubit.loadDashboardData();

      // assert
      await future;
      expect(cubit.state, isA<DashboardError>());
    });
  });
}
