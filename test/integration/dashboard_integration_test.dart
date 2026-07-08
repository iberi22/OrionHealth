import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/dashboard/application/dashboard_cubit.dart';
import 'package:orionhealth_health/features/dashboard/application/dashboard_state.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/activity_item.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:orionhealth_health/features/dashboard/presentation/pages/home_dashboard_page.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';
import 'package:orionhealth_health/features/local_agent/presentation/chat_page.dart';
import 'package:orionhealth_health/features/vitals/presentation/pages/vitals_page.dart';
import 'package:orionhealth_health/features/medications/presentation/pages/medications_page.dart';
import 'package:orionhealth_health/features/reports/presentation/pages/reports_page.dart';
import 'package:orionhealth_health/features/health_record/presentation/pages/timeline_page.dart';
import 'package:orionhealth_health/features/medical_research/presentation/pages/medical_research_page.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';

class _MockLlmService extends Mock implements LlmService {}
class _MockDashboardCubit extends Mock implements DashboardCubit {}

void main() {
  final getIt = GetIt.instance;
  late _MockDashboardCubit mockDashboardCubit;

  setUpAll(() {
    getIt.registerLazySingleton<LlmService>(() => _MockLlmService());
    registerFallbackValue(DashboardInitial());
  });

  tearDownAll(() {
    getIt.reset();
  });

  setUp(() {
    mockDashboardCubit = _MockDashboardCubit();
    when(() => mockDashboardCubit.loadDashboardData()).thenAnswer((_) async {});
    when(() => mockDashboardCubit.close()).thenAnswer((_) async {});
    when(() => mockDashboardCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget _buildApp(DashboardState state) {
    when(() => mockDashboardCubit.state).thenReturn(state);
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: BlocProvider<DashboardCubit>.value(
        value: mockDashboardCubit,
        child: const HomeDashboardPage(),
      ),
    );
  }

  group('Dashboard integration tests', () {
    testWidgets('1. Dashboard loads and displays stats correctly',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final now = DateTime(2026, 7, 7);
      final stats = DashboardStats(
        totalMedications: 5,
        reportsCount: 12,
        lastVitalCheck: now,
      );
      final activities = [
        ActivityItem(
          id: 'a1',
          title: 'Presión arterial tomada',
          timestamp: now.subtract(const Duration(hours: 3)),
          type: ActivityType.vitalCheck,
        ),
        ActivityItem(
          id: 'a2',
          title: 'Paracetamol registrado',
          timestamp: now.subtract(const Duration(hours: 6)),
          type: ActivityType.medicationTaken,
        ),
      ];

      await tester.pumpWidget(
        _buildApp(DashboardLoaded(stats: stats, activities: activities)),
      );
      await tester.pumpAndSettle();

      // Verify stats card is present
      expect(find.byKey(const Key('dashboard_stats_card')), findsOneWidget);

      // Verify header
      expect(find.text('ORION HEALTH'), findsOneWidget);

      // Verify stats section header
      expect(find.text('RESUMEN DE SALUD'), findsOneWidget);

      // Verify medication count
      expect(find.text('5'), findsOneWidget);
      expect(find.text('Medicamentos'), findsOneWidget);

      // Verify reports count
      expect(find.text('12'), findsOneWidget);
      expect(find.text('Informes'), findsOneWidget);

      // Verify last vital check date (formatted as dd/mm)
      expect(find.text('7/7'), findsOneWidget);
      expect(find.text('Último Control'), findsOneWidget);

      // Scroll down to see activities
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -800));
      await tester.pumpAndSettle();

      // Verify activity items appear
      expect(find.text('Presión arterial tomada'), findsOneWidget);
      expect(find.text('Paracetamol registrado'), findsOneWidget);
    });

    testWidgets('2. Quick action cards navigate to correct pages',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final stats = DashboardStats(totalMedications: 3, reportsCount: 5);
      await tester.pumpWidget(
        _buildApp(DashboardLoaded(stats: stats, activities: const [])),
      );
      await tester.pumpAndSettle();

      // Helper to verify navigation tapping a quick action card
      Future<void> tapAndVerifyNavigation(
        String cardLabel,
        Type expectedPageType,
      ) async {
        final finder = find.text(cardLabel);
        // Ensure widget is visible (may need to scroll)
        await tester.ensureVisible(finder);
        await tester.pumpAndSettle();
        await tester.tap(finder);
        await tester.pumpAndSettle();
        expect(find.byType(expectedPageType), findsOneWidget,
            reason: 'Expected $cardLabel to navigate to $expectedPageType');
        // Pop back
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
      }

      // AI Assistant → ChatPage
      await tapAndVerifyNavigation('AI Assistant', ChatPage);

      // Salud → VitalsPage
      // For VitalsPage we check by Const constructor key known in app
      await tapAndVerifyNavigation('Salud', VitalsPage);

      // Estadísticas → ReportsPage
      await tapAndVerifyNavigation('Estadísticas', ReportsPage);

      // Medicamentos → MedicationsPage
      await tapAndVerifyNavigation('Medicamentos', MedicationsPage);

      // Timeline → TimelinePage
      await tapAndVerifyNavigation('Timeline', TimelinePage);

      // Investigación → MedicalResearchPage
      await tapAndVerifyNavigation('Investigación', MedicalResearchPage);
    });

    testWidgets('3. UI transitions correctly when state changes from loading to loaded',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Create a stream controller to simulate state changes
      final stateStream = Stream<DashboardState>.multi(
        (controller) {
          controller.add(const DashboardLoading());
          // Simulate transition
          Future(() {
            controller.add(
              DashboardLoaded(
                stats: const DashboardStats(
                  totalMedications: 5,
                  reportsCount: 12,
                  lastVitalCheck: DateTime(2026, 7, 7),
                ),
                activities: [
                  ActivityItem(
                    id: 'a1',
                    title: 'Nueva actividad cargada',
                    timestamp: DateTime(2026, 7, 7),
                    type: ActivityType.vitalCheck,
                  ),
                ],
              ),
            );
            controller.close();
          });
        },
      );

      when(() => mockDashboardCubit.state).thenReturn(const DashboardLoading());
      when(() => mockDashboardCubit.stream).thenAnswer((_) => stateStream);

      await tester.pumpWidget(
        _buildApp(const DashboardLoading()),
      );
      await tester.pump();

      // Initially should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget,
          reason: 'Loading state should show CircularProgressIndicator');

      // Let the stream emit new state and rebuild
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // After loading completes, stats should appear
      expect(find.byKey(const Key('dashboard_stats_card')), findsOneWidget,
          reason: 'After loading, stats card should appear');
      expect(find.text('RESUMEN DE SALUD'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);

      // Scroll down to see activity
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -800));
      await tester.pumpAndSettle();

      expect(find.text('Nueva actividad cargada'), findsOneWidget);
    });
  });
}
