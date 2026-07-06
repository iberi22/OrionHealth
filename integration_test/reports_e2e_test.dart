// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/reports/presentation/pages/reports_page.dart';
import 'package:orionhealth_health/features/reports/presentation/pages/report_detail_page.dart';
import 'package:orionhealth_health/features/reports/domain/repositories/report_repository.dart';
import 'package:orionhealth_health/features/reports/domain/services/report_generation_service.dart';
import 'package:orionhealth_health/features/reports/infrastructure/services/mock_report_generation_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:health_wallet/health_wallet.dart';
import 'package:mocktail/mocktail.dart';
import 'utils/video_recorder.dart';

class MockWalletService extends Mock implements WalletService {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockWalletService mockWalletService;

  setUpAll(() async {
    di.getIt.allowReassignment = true;
    await di.configureDependencies();
    di.getIt.allowReassignment = true;
    di.getIt.registerLazySingleton<ReportGenerationService>(
      () => MockReportGenerationService(),
    );
    await initializeDateFormatting('es', null);

    // Override with Mock implementation for deterministic E2E
    // The 'mock' instance is registered as MockReportGenerationService specifically
    final mockGenerationService = di.getIt<MockReportGenerationService>(instanceName: 'mock');
    di.getIt.registerSingleton<ReportGenerationService>(mockGenerationService);
  });

  setUp(() {
    mockWalletService = MockWalletService();
    di.getIt.registerSingleton<WalletService>(mockWalletService);

    when(() => mockWalletService.exportToFhir()).thenAnswer((_) async => '{"resourceType": "Bundle"}');
  });

  tearDown(() {
    di.getIt.unregister<WalletService>();
  });

  group('Reports Flow - E2E Tests', () {
    testWidgets('E2E: Full reports flow with real database and mocked boundaries', (WidgetTester tester) async {
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

      // 3. GENERATE REPORT
      final generateButton = find.text('Generar Ahora');
      expect(generateButton, findsOneWidget);
      await tester.tap(generateButton);

      // The generation might take some time (especially if using mock delay or real LLM)
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'reports', '02_generating');

      // Wait for generation to complete (Mock delay is 2s)
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 4. Verify report is listed
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

      // 8. TEST FHIR EXPORT
      final exportChip = find.text('Exportar FHIR');
      expect(exportChip, findsOneWidget);
      await tester.tap(exportChip);
      await tester.pumpAndSettle();

      expect(find.text('Exportación FHIR R4'), findsOneWidget);
      expect(find.text('Copiar'), findsOneWidget);
      expect(find.text('Cerrar'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'reports', '07_fhir_export_dialog');

      await tester.tap(find.text('Cerrar'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
