import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/dashboard/presentation/pages/home_dashboard_page.dart';
import 'package:orionhealth_health/features/dashboard/application/dashboard_cubit.dart';
import 'package:orionhealth_health/features/dashboard/application/dashboard_state.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/activity_item.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';
import 'utils/video_recorder.dart';

class MockDashboardCubit extends Mock implements DashboardCubit {}
class MockLlmService extends Mock implements LlmService {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockDashboardCubit mockCubit;
  late MockLlmService mockLlmService;
  late StreamController<DashboardState> stateController;

  setUp(() {
    mockCubit = MockDashboardCubit();
    mockLlmService = MockLlmService();
    stateController = StreamController<DashboardState>.broadcast();

    when(() => mockCubit.loadDashboardData()).thenAnswer((_) async {});
    when(() => mockCubit.close()).thenAnswer((_) async {});
    when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);

    GetIt.I.reset();
    GetIt.I.registerSingleton<LlmService>(mockLlmService);
  });

  tearDown(() {
    stateController.close();
    GetIt.I.reset();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<DashboardCubit>.value(
        value: mockCubit,
        child: const HomeDashboardPage(),
      ),
    );
  }

  group('Dashboard - E2E Tests', () {
    testWidgets('Dashboard Loading State', (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const DashboardLoading());

      await tester.pumpWidget(createWidgetUnderTest());
      await VideoRecorder.recordStep(tester, 'dashboard', '01_loading');

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Dashboard Error and Recovery', (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const DashboardError('Error de carga'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'dashboard', '02_error');

      expect(find.textContaining('Error: Error de carga'), findsOneWidget);

      // Recovery: Mock success and trigger refresh
      const stats = DashboardStats(totalMedications: 3, reportsCount: 1);
      final loadedState = const DashboardLoaded(stats: stats, activities: []);

      when(() => mockCubit.loadDashboardData()).thenAnswer((_) async {
        when(() => mockCubit.state).thenReturn(loadedState);
        stateController.add(loadedState);
      });

      // Swipe to refresh
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
      await tester.pumpAndSettle();

      verify(() => mockCubit.loadDashboardData()).called(greaterThanOrEqualTo(1));
      expect(find.text('ACCIONES RÁPIDAS'), findsOneWidget);
    });

    testWidgets('Dashboard Loaded State with Data', (WidgetTester tester) async {
      final fixedNow = DateTime.now();
      const stats = DashboardStats(
        totalMedications: 5,
        reportsCount: 2,
        lastVitalCheck: null,
      );
      final activities = [
        ActivityItem(
          id: '1',
          title: 'Presión arterial registrada',
          timestamp: fixedNow.subtract(const Duration(minutes: 5)),
          type: ActivityType.vitalCheck,
        ),
      ];
      final loadedState = DashboardLoaded(stats: stats, activities: activities);

      when(() => mockCubit.state).thenReturn(loadedState);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'dashboard', '03_loaded');

      expect(find.text('Presión arterial registrada'), findsOneWidget);
      expect(find.text('Hace 5 minutos'), findsOneWidget);
      expect(find.text('AI Assistant'), findsOneWidget);
      expect(find.text('Salud'), findsOneWidget);
    });
  });
}
