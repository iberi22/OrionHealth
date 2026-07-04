import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orionhealth_health/features/dashboard/presentation/pages/home_dashboard_page.dart';
import 'package:orionhealth_health/features/dashboard/application/dashboard_cubit.dart';
import 'package:orionhealth_health/features/dashboard/application/dashboard_state.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/dashboard_stats.dart';
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

  group('Dashboard Golden Tests', () {
    testWidgets('Home Dashboard Page - Loaded', (tester) async {
      setupGoldenTest(tester);

      when(() => mockDashboardCubit.state).thenReturn(const DashboardLoaded(
        stats: DashboardStats(totalMedications: 5, reportsCount: 3),
        activities: [],
      ));

      await tester.pumpWidget(
        BlocProvider<DashboardCubit>.value(
          value: mockDashboardCubit,
          child: wrapWithMaterial(const HomeDashboardPage()),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(HomeDashboardPage),
        matchesGoldenFile("goldens/dashboard_page_loaded.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Home Dashboard Page - Loading', (tester) async {
      setupGoldenTest(tester);

      when(() => mockDashboardCubit.state).thenReturn(const DashboardLoading());

      await tester.pumpWidget(
        BlocProvider<DashboardCubit>.value(
          value: mockDashboardCubit,
          child: wrapWithMaterial(const HomeDashboardPage()),
        ),
      );
      await tester.pump();

      await expectLater(
        find.byType(HomeDashboardPage),
        matchesGoldenFile("goldens/dashboard_page_loading.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
