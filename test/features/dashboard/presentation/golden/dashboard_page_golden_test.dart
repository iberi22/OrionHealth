import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orionhealth_health/features/dashboard/presentation/pages/home_dashboard_page.dart';
import 'package:orionhealth_health/features/dashboard/application/dashboard_cubit.dart';
import 'package:orionhealth_health/features/dashboard/application/dashboard_state.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/activity_item.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';
import '../../../../core/golden_test_utils.dart';

class MockLlmService extends Mock implements LlmService {}
class MockDashboardCubit extends Mock implements DashboardCubit {}

void main() {
  late MockLlmService mockLlmService;
  late MockDashboardCubit mockDashboardCubit;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    mockLlmService = MockLlmService();
    mockDashboardCubit = MockDashboardCubit();

    when(() => mockDashboardCubit.loadDashboardData()).thenAnswer((_) async {});
    when(() => mockDashboardCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockDashboardCubit.close()).thenAnswer((_) async {});

    GetIt.I.reset();
    GetIt.I.registerSingleton<LlmService>(mockLlmService);
  });

  tearDown(() {
    if (GetIt.I.isRegistered<LlmService>()) {
      GetIt.I.unregister<LlmService>();
    }
  });

  Widget buildPage() {
    return BlocProvider<DashboardCubit>.value(
      value: mockDashboardCubit,
      child: wrapWithMaterial(const HomeDashboardPage()),
    );
  }

  group('Dashboard Page Golden Tests', () {
    testWidgets('Dashboard Loaded State', (tester) async {
      // Use a larger height to see activities at the bottom
      tester.view.physicalSize = const Size(360, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      setupGoldenTest(tester);
      // override setupGoldenTest size for this specific test if needed,
      // but setupGoldenTest sets it back to 360x640.
      // So I should call setupGoldenTest FIRST then override.
      setupGoldenTest(tester);
      tester.view.physicalSize = const Size(360, 1200);

      final activities = [
        ActivityItem(
          id: '1',
          title: 'Heart rate check',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          type: ActivityType.vitalCheck,
        ),
        ActivityItem(
          id: '2',
          title: 'Vitamin D taken',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          type: ActivityType.medicationTaken,
        ),
      ];

      when(() => mockDashboardCubit.state).thenReturn(DashboardLoaded(
        stats: const DashboardStats(totalMedications: 5, reportsCount: 2),
        activities: activities,
      ));

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(HomeDashboardPage),
        matchesGoldenFile("goldens/dashboard_loaded.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Dashboard Loading State', (tester) async {
      setupGoldenTest(tester);
      when(() => mockDashboardCubit.state).thenReturn(const DashboardLoading());

      await tester.pumpWidget(buildPage());
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(HomeDashboardPage),
        matchesGoldenFile("goldens/dashboard_loading.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Dashboard Empty State', (tester) async {
      setupGoldenTest(tester);
      when(() => mockDashboardCubit.state).thenReturn(const DashboardLoaded(
        stats: DashboardStats(totalMedications: 0, reportsCount: 0),
        activities: [],
      ));

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(HomeDashboardPage),
        matchesGoldenFile("goldens/dashboard_empty.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Dashboard Error State', (tester) async {
      setupGoldenTest(tester);
      when(() => mockDashboardCubit.state).thenReturn(const DashboardError('Failed to load dashboard data'));

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(HomeDashboardPage),
        matchesGoldenFile("goldens/dashboard_error.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
