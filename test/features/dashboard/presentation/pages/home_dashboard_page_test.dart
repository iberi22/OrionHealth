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
import 'package:orionhealth_health/features/local_agent/presentation/chat_page.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';

class MockLlmService extends Mock implements LlmService {}
class MockDashboardCubit extends Mock implements DashboardCubit {}

void main() {
  final getIt = GetIt.instance;
  late MockDashboardCubit mockDashboardCubit;

  setUpAll(() {
    getIt.registerLazySingleton<LlmService>(() => MockLlmService());
    registerFallbackValue(DashboardInitial());
  });

  tearDownAll(() {
    getIt.reset();
  });

  setUp(() {
    mockDashboardCubit = MockDashboardCubit();
    when(() => mockDashboardCubit.loadDashboardData()).thenAnswer((_) async {});
    when(() => mockDashboardCubit.close()).thenAnswer((_) async {});
    when(() => mockDashboardCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest(DashboardState state) {
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

  testWidgets('shows loading indicator when DashboardLoading', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const DashboardLoading()));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows error message when DashboardError', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const DashboardError('Failure')));
    await tester.pump();

    expect(find.text('Error: Failure'), findsOneWidget);
  });

  testWidgets('shows data when DashboardLoaded and tests different activity types and times', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final now = DateTime.now();
    final stats = DashboardStats(totalMedications: 2, reportsCount: 1, lastVitalCheck: now);
    final activities = [
      ActivityItem(
        id: '1',
        title: 'Vital check activity',
        timestamp: now,
        type: ActivityType.vitalCheck,
      ),
      ActivityItem(
        id: '2',
        title: 'Medication activity',
        timestamp: now.subtract(const Duration(hours: 2)),
        type: ActivityType.medicationTaken,
      ),
    ];

    await tester.pumpWidget(createWidgetUnderTest(DashboardLoaded(stats: stats, activities: activities)));
    await tester.pumpAndSettle();

    expect(find.text('ORION HEALTH'), findsOneWidget);

    expect(find.text('Vital check activity'), findsOneWidget);
    expect(find.text('Medication activity'), findsOneWidget);

    expect(find.textContaining('2 horas'), findsOneWidget);
  });

  testWidgets('shows empty message when DashboardLoaded with no activities', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final stats = DashboardStats(totalMedications: 0, reportsCount: 0);

    await tester.pumpWidget(createWidgetUnderTest(DashboardLoaded(stats: stats, activities: const [])));
    await tester.pumpAndSettle();

    expect(find.text('No hay actividad reciente'), findsOneWidget);
  });

  testWidgets('Quick action card triggers navigation', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final stats = DashboardStats(totalMedications: 0, reportsCount: 0);
    await tester.pumpWidget(createWidgetUnderTest(DashboardLoaded(stats: stats, activities: const [])));
    await tester.pumpAndSettle();

    // Tap on AI Assistant card
    await tester.tap(find.text('AI Assistant'));
    await tester.pumpAndSettle();

    expect(find.byType(ChatPage), findsOneWidget);
  });

  testWidgets('refresh indicator triggers loadDashboardData', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final stats = DashboardStats(totalMedications: 0, reportsCount: 0);
    await tester.pumpWidget(createWidgetUnderTest(DashboardLoaded(stats: stats, activities: const [])));
    await tester.pumpAndSettle();

    // Pull to refresh
    await tester.fling(find.byType(RefreshIndicator), const Offset(0.0, 300.0), 1000.0);
    await tester.pumpAndSettle();

    verify(() => mockDashboardCubit.loadDashboardData()).called(greaterThan(0));
  });
}
