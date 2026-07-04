import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/reports/presentation/pages/reports_page.dart';
import 'package:orionhealth_health/features/reports/presentation/pages/report_detail_page.dart';
import 'package:orionhealth_health/features/reports/domain/repositories/report_repository.dart';
import 'package:orionhealth_health/features/reports/domain/entities/report.dart';
import 'package:orionhealth_health/features/reports/domain/services/report_generation_service.dart';
import 'package:orionhealth_health/features/reports/infrastructure/services/mock_report_generation_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'utils/video_recorder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await di.configureDependencies();
    di.getIt.allowReassignment = true;
    di.getIt.registerLazySingleton<ReportGenerationService>(
      () => MockReportGenerationService(),
    );
    await initializeDateFormatting('es', null);
  });

  group('Reports Flow - E2E Tests', () {
    testWidgets('E2E: Full reports flow with real database', (WidgetTester tester) async {
      final repo = di.getIt<ReportRepository>();

      // 1. Clean start for the test
      final existingReports = await repo.getReports();
      for (final report in existingReports) {
        await repo.deleteReport(report.id);
      }

      await tester.pumpWidget(
        MaterialApp(
          home: const ReportsPage(),
          theme: ThemeData.dark(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
        ),
      );
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'reports', '01_initial_empty_list');

      // 2. Verify empty state
      expect(find.text('No hay informes disponibles'), findsOneWidget);
      expect(find.text('Tus informes generados aparecerán aquí.'), findsOneWidget);
      expect(find.byIcon(Icons.assignment_outlined), findsOneWidget);

      // 3. GENERATE REPORT
      final generateButton = find.text('Generar Ahora');
      expect(generateButton, findsOneWidget);
      await tester.tap(generateButton);

      // The generation might take some time (especially if using mock delay or real LLM)
      // We pump but don't settle immediately because of the loading indicator
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'reports', '02_generating');

      // Wait for generation to complete (Mock delay is 2s, real might be more)
      // pumpAndSettle might timeout if there are infinite animations, but here it should be fine
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 4. Verify report is listed
      // The report title starts with 'Informe de Salud'
      expect(find.textContaining('Informe de Salud'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'reports', '03_after_generation');

      // 5. VIEW DETAIL
      await tester.tap(find.textContaining('Informe de Salud'));
      await tester.pumpAndSettle();

      expect(find.byType(ReportDetailPage), findsOneWidget);
      expect(find.textContaining('Informe de Salud'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'reports', '04_report_detail');

      // 6. GO BACK
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(ReportsPage), findsOneWidget);

      // 7. TEST FILTERS
      // Since generation assigns a random status, we might need to know which one it is
      // to test filters accurately, or just test that the chips are there.
      expect(find.text('Todos'), findsOneWidget);
      expect(find.text('Urgentes'), findsOneWidget);
      expect(find.text('Finalizados'), findsOneWidget);
      expect(find.text('Pendientes'), findsOneWidget);

      await tester.tap(find.text('Urgentes'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'reports', '05_filter_urgent');

      await tester.tap(find.text('Todos'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'reports', '06_filter_all');

      // 8. TEST SPECIFIC FILTERS WITH SEEDED DATA
      // Seed an urgent report
      final urgentReport = Report(
        title: 'Informe Urgente Test',
        content: 'Contenido urgente',
        status: ReportStatus.urgent,
        generatedAt: DateTime.now(),
      );
      await repo.saveReport(urgentReport);

      // Seed a finalized report
      final finalizedReport = Report(
        title: 'Informe Finalizado Test',
        content: 'Contenido finalizado',
        status: ReportStatus.finalized,
        generatedAt: DateTime.now(),
      );
      await repo.saveReport(finalizedReport);

      // Refresh the list (via Bloc)
      await tester.tap(find.text('Todos')); // Just to trigger a rebuild/state change if needed,
      // but ReportsPage uses BlocBuilder, we might need to trigger LoadReports again.
      // Tapping "Todos" doesn't trigger LoadReports in current implementation.
      // RefreshIndicator can do it.
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
      await tester.pumpAndSettle();

      // Verify both are present
      expect(find.text('Informe Urgente Test'), findsOneWidget);
      expect(find.text('Informe Finalizado Test'), findsOneWidget);

      // Filter by Urgent
      await tester.tap(find.text('Urgentes'));
      await tester.pumpAndSettle();
      expect(find.text('Informe Urgente Test'), findsOneWidget);
      expect(find.text('Informe Finalizado Test'), findsNothing);
      await VideoRecorder.recordStep(tester, 'reports', '07_filter_urgent_verified');

      // Filter by Finalized
      await tester.tap(find.text('Finalizados'));
      await tester.pumpAndSettle();
      expect(find.text('Informe Urgente Test'), findsNothing);
      expect(find.text('Informe Finalizado Test'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'reports', '08_filter_finalized_verified');

      // Filter by Pendiente (should be empty if we didn't seed one)
      await tester.tap(find.text('Pendientes'));
      await tester.pumpAndSettle();
      expect(find.text('Informe Urgente Test'), findsNothing);
      expect(find.text('Informe Finalizado Test'), findsNothing);
      expect(find.text('No hay resultados'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'reports', '09_filter_pending_empty');

      // Back to All
      await tester.tap(find.text('Todos'));
      await tester.pumpAndSettle();
      expect(find.text('Informe Urgente Test'), findsOneWidget);
      expect(find.text('Informe Finalizado Test'), findsOneWidget);

      // 9. TEST EXPORT FHIR
      final exportChip = find.text('Exportar FHIR');
      expect(exportChip, findsOneWidget);
      await tester.tap(exportChip);
      await tester.pumpAndSettle();

      expect(find.text('Exportación FHIR R4'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'reports', '10_fhir_export_dialog');

      // Close dialog
      await tester.tap(find.text('Cerrar'));
      await tester.pumpAndSettle();
      expect(find.text('Exportación FHIR R4'), findsNothing);
    });
  });
}
