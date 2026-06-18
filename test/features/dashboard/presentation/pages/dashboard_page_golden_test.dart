import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/dashboard/application/dashboard_cubit.dart';
import 'package:orionhealth_health/features/dashboard/application/dashboard_state.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/activity_item.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:orionhealth_health/features/dashboard/presentation/pages/home_dashboard_page.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import '../../../../core/golden_test_utils.dart';

class MockLlmService extends Mock implements LlmService {}
class MockDashboardCubit extends Mock implements DashboardCubit {}

void main() {
  late MockLlmService mockLlmService;
  late MockDashboardCubit mockDashboardCubit;

  setUp(() async {
    mockLlmService = MockLlmService();
    mockDashboardCubit = MockDashboardCubit();
    if (!GetIt.I.isRegistered<LlmService>()) {
      GetIt.I.registerSingleton<LlmService>(mockLlmService);
    }

    when(() => mockDashboardCubit.loadDashboardData()).thenAnswer((_) async {});
    when(() => mockDashboardCubit.close()).thenAnswer((_) async {});
    when(() => mockDashboardCubit.stream).thenAnswer((_) => const Stream.empty());

    final stats = DashboardStats(totalMedications: 5, reportsCount: 2);
    final activities = [
      ActivityItem(
        id: '1',
        title: 'Checkup',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: ActivityType.vitalCheck,
      ),
    ];
    when(() => mockDashboardCubit.state).thenReturn(DashboardLoaded(stats: stats, activities: activities));
  });

  tearDown(() {
    // We don't unregister because we are using registerSingleton only if not registered
  });

  group('Dashboard Golden Tests', () {
    testWidgets('Home Dashboard Page', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
          home: BlocProvider<DashboardCubit>.value(
            value: mockDashboardCubit,
            child: const HomeDashboardPage(),
          ),
        )
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(HomeDashboardPage),
        matchesGoldenFile("goldens/home_dashboard_page.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
