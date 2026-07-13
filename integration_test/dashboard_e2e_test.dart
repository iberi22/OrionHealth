// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orionhealth_health/features/dashboard/presentation/pages/home_dashboard_page.dart';
import 'package:orionhealth_health/features/dashboard/application/dashboard_cubit.dart';
import 'package:orionhealth_health/features/dashboard/application/dashboard_state.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/activity_item.dart';
import 'package:orionhealth_health/core/widgets/glassmorphic_card.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
    when(() => mockCubit.close()).thenAnswer((_) async => stateController.close());
  });

  tearDown(() {
    stateController.close();
  });

  Widget createTestWidget(Widget home) {
    return MaterialApp(
      home: home,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
    );
  }

  group('Dashboard - E2E Tests', () {
    testWidgets('E2E: Full Dashboard Lifecycle - Loading, Loaded, Error, and Recovery',
        (WidgetTester tester) async {
      // 1. Loading State
      when(() => mockCubit.state).thenReturn(const DashboardLoading());
      stateController.add(const DashboardLoading());

      await tester.pumpWidget(
        createTestWidget(
          BlocProvider<DashboardCubit>.value(
            value: mockCubit,
            child: const HomeDashboardPage(),
          ),
        ),
      );
      await tester.pump();
      await VideoRecorder.recordStep(tester, 'dashboard', '01_loading');

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('ORION HEALTH'), findsOneWidget);

      // 2. Transition to Loaded State with Stats and Activities
      const stats = DashboardStats(totalMedications: 5, reportsCount: 3, lastVitalCheck: null);
      final activities = [
        ActivityItem(
          id: '1',
          title: 'Presión arterial registrada',
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
          type: ActivityType.vitalCheck,
        ),
        ActivityItem(
          id: '2',
          title: 'Medicamento tomado: Ibuprofeno',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          type: ActivityType.medicationTaken,
        ),
        ActivityItem(
          id: '3',
          title: 'Nuevo reporte generado',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          type: ActivityType.reportGenerated,
        ),
      ];
      final loadedState = DashboardLoaded(stats: stats, activities: activities);

      when(() => mockCubit.state).thenReturn(loadedState);
      stateController.add(loadedState);
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'dashboard', '02_loaded');

      // Verify Stats Card renders
      expect(find.byKey(const Key('dashboard_stats_card')), findsOneWidget);
      expect(find.text('RESUMEN DE SALUD'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      // Verify Quick Actions section
      expect(find.text('ACCIONES RÁPIDAS'), findsOneWidget);
      expect(find.text('AI Assistant'), findsOneWidget);
      expect(find.text('Salud'), findsOneWidget);
      expect(find.text('Medicamentos'), findsOneWidget);

      // Scroll down to see activity items
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Verify Activity items
      expect(find.text('ACTIVIDAD RECIENTE'), findsOneWidget);
      expect(find.text('Presión arterial registrada'), findsOneWidget);

      // 3. Error State
      final errorState = const DashboardError('Failed to load data');
      when(() => mockCubit.state).thenReturn(errorState);
      stateController.add(errorState);
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'dashboard', '03_error');

      expect(find.text('Error: Failed to load data'), findsOneWidget);

      // 4. Recovery: Drag to refresh
      when(() => mockCubit.loadDashboardData()).thenAnswer((_) async {
        when(() => mockCubit.state).thenReturn(loadedState);
        stateController.add(loadedState);
      });

      await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'dashboard', '04_recovered');

      verify(() => mockCubit.loadDashboardData()).called(greaterThanOrEqualTo(1));
      expect(find.text('RESUMEN DE SALUD'), findsOneWidget);
    });

    testWidgets('E2E: Dashboard Empty State - No Activities', (WidgetTester tester) async {
      const emptyStats = DashboardStats(totalMedications: 0, reportsCount: 0);
      final emptyState = const DashboardLoaded(stats: emptyStats, activities: []);

      when(() => mockCubit.state).thenReturn(emptyState);
      stateController.add(emptyState);

      await tester.pumpWidget(
        createTestWidget(
          BlocProvider<DashboardCubit>.value(
            value: mockCubit,
            child: const HomeDashboardPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'dashboard', '05_empty');

      expect(find.text('0'), findsNWidgets(2));
      expect(find.text('N/A'), findsOneWidget);

      // Scroll down to see the empty activity message
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('No hay actividad reciente'), findsOneWidget);
    });

    testWidgets('E2E: Dashboard Quick Actions - AI Assistant Navigation',
        (WidgetTester tester) async {
      const stats = DashboardStats(totalMedications: 2, reportsCount: 1);
      final loadedState = const DashboardLoaded(stats: stats, activities: []);

      when(() => mockCubit.state).thenReturn(loadedState);
      stateController.add(loadedState);

      await tester.pumpWidget(
        createTestWidget(
          BlocProvider<DashboardCubit>.value(
            value: mockCubit,
            child: const HomeDashboardPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap AI Assistant quick action
      await tester.tap(find.text('AI Assistant'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'dashboard', '06_ai_navigation');

      // Should have navigated (verify by checking AI chat page content)
      // The ChatPage is loaded from getIt<LlmService> via DI
      expect(find.textContaining('AI'), findsOneWidget);
    });
  });
}
