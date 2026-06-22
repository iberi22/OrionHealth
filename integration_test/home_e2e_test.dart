import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/features/dashboard/presentation/pages/home_dashboard_page.dart';
import 'package:orionhealth_health/features/dashboard/application/dashboard_cubit.dart';
import 'package:orionhealth_health/features/dashboard/application/dashboard_state.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/activity_item.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'utils/video_recorder.dart';

class MockDashboardCubit extends Mock implements DashboardCubit {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockDashboardCubit mockCubit;
  late StreamController<DashboardState> stateController;

  setUp(() {
    mockCubit = MockDashboardCubit();
    stateController = StreamController<DashboardState>.broadcast();

    when(() => mockCubit.loadDashboardData()).thenAnswer((_) async {});
    when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);
  });

  tearDown(() {
    stateController.close();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<DashboardCubit>.value(
        value: mockCubit,
        child: const HomeDashboardPage(),
      ),
    );
  }

  group('Home Flow - E2E Tests', () {
    testWidgets('E2E: Dashboard Loading State', (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const DashboardLoading());

      await tester.pumpWidget(createWidgetUnderTest());
      await VideoRecorder.recordStep(tester, 'home', '01_loading');

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('E2E: Dashboard Error and Recovery', (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const DashboardError('Failed to load data'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'home', '02_error');

      expect(find.text('Error: Failed to load data'), findsOneWidget);

      // Recovery: Mock success and trigger refresh
      const stats = DashboardStats(totalMedications: 5, reportsCount: 2);
      final loadedState = const DashboardLoaded(stats: stats, activities: []);

      when(() => mockCubit.loadDashboardData()).thenAnswer((_) async {
        when(() => mockCubit.state).thenReturn(loadedState);
        stateController.add(loadedState);
      });

      await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
      await tester.pumpAndSettle();

      verify(() => mockCubit.loadDashboardData()).called(atLeast(1));
      expect(find.text('ACCIONES RÁPIDAS'), findsOneWidget);
    });

    testWidgets('E2E: Dashboard Widget Refresh', (WidgetTester tester) async {
      const stats = DashboardStats(totalMedications: 5, reportsCount: 2);
      final activities = [
        ActivityItem(
          id: '1',
          title: 'Presión arterial registrada',
          timestamp: DateTime.now(),
          type: ActivityType.vitalCheck,
        ),
      ];
      final loadedState = DashboardLoaded(stats: stats, activities: activities);

      when(() => mockCubit.state).thenReturn(loadedState);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'home', '03_loaded');

      expect(find.text('Presión arterial registrada'), findsOneWidget);

      // Trigger refresh
      when(() => mockCubit.loadDashboardData()).thenAnswer((_) async {
        stateController.add(loadedState);
      });

      await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'home', '04_refreshed');

      verify(() => mockCubit.loadDashboardData()).called(atLeast(1));
    });

    testWidgets('E2E: Dashboard Modules Interaction', (WidgetTester tester) async {
       const stats = DashboardStats(totalMedications: 5, reportsCount: 2);
       when(() => mockCubit.state).thenReturn(const DashboardLoaded(stats: stats, activities: []));

       await tester.pumpWidget(createWidgetUnderTest());
       await tester.pumpAndSettle();

       expect(find.text('AI Assistant'), findsOneWidget);
       expect(find.text('Salud'), findsOneWidget);

       await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
       await tester.pumpAndSettle();
       await VideoRecorder.recordStep(tester, 'home', '05_scrolled');
    });
  });
}
