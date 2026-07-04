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
    when(() => mockDashboardCubit.close()).thenAnswer((_) async {});

    GetIt.I.reset();
    GetIt.I.registerSingleton<LlmService>(mockLlmService);
  });

  tearDown(() {
    GetIt.I.reset();
  });

  Widget createWidgetUnderTest() {
    return BlocProvider<DashboardCubit>.value(
      value: mockDashboardCubit,
      child: wrapWithMaterial(const HomeDashboardPage()),
    );
  }

  group('HomeDashboardPage Golden Tests', () {
    testWidgets('Dashboard Loading State', (tester) async {
      when(() => mockDashboardCubit.state).thenReturn(const DashboardLoading());
      when(() => mockDashboardCubit.stream).thenAnswer((_) => Stream.value(const DashboardLoading()));

      setupGoldenTest(tester, size: const Size(360, 1000));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await expectLater(
        find.byType(HomeDashboardPage),
        matchesGoldenFile('goldens/dashboard_page_loading.png'),
      );
    });

    testWidgets('Dashboard Error State', (tester) async {
      when(() => mockDashboardCubit.state).thenReturn(const DashboardError('Error loading dashboard data'));
      when(() => mockDashboardCubit.stream).thenAnswer((_) => Stream.value(const DashboardError('Error loading dashboard data')));

      setupGoldenTest(tester, size: const Size(360, 1000));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await expectLater(
        find.byType(HomeDashboardPage),
        matchesGoldenFile('goldens/dashboard_page_error.png'),
      );
    });

    testWidgets('Dashboard Empty State', (tester) async {
      const stats = DashboardStats(totalMedications: 0, reportsCount: 0);
      when(() => mockDashboardCubit.state).thenReturn(const DashboardLoaded(
        stats: stats,
        activities: [],
      ));
      when(() => mockDashboardCubit.stream).thenAnswer((_) => Stream.value(const DashboardLoaded(
        stats: stats,
        activities: [],
      )));

      setupGoldenTest(tester, size: const Size(360, 1000));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(HomeDashboardPage),
        matchesGoldenFile('goldens/dashboard_page_empty.png'),
      );
    });

    testWidgets('Dashboard Loaded State', (tester) async {
      setupGoldenTest(tester, size: const Size(360, 1200));
      final fixedNow = DateTime(2023, 10, 27, 10, 30);
      final stats = DashboardStats(
        totalMedications: 5,
        reportsCount: 3,
        lastVitalCheck: fixedNow,
      );
      final activities = [
        ActivityItem(
          id: '1',
          title: 'Presión arterial registrada',
          timestamp: fixedNow.subtract(const Duration(minutes: 15)),
          type: ActivityType.vitalCheck,
        ),
        ActivityItem(
          id: '2',
          title: 'Medicamento tomado: Ibuprofeno',
          timestamp: fixedNow.subtract(const Duration(hours: 2)),
          type: ActivityType.medicationTaken,
        ),
        ActivityItem(
          id: '3',
          title: 'Nuevo reporte generado',
          timestamp: fixedNow.subtract(const Duration(days: 1)),
          type: ActivityType.reportGenerated,
        ),
      ];

      when(() => mockDashboardCubit.state).thenReturn(DashboardLoaded(
        stats: stats,
        activities: activities,
      ));
      when(() => mockDashboardCubit.stream).thenAnswer((_) => Stream.value(DashboardLoaded(
        stats: stats,
        activities: activities,
      )));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(HomeDashboardPage),
        matchesGoldenFile('goldens/dashboard_page_loaded.png'),
      );
    });
  });
}
