import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:orionhealth_health/features/reports/domain/entities/report.dart';
import 'package:orionhealth_health/features/reports/presentation/widgets/report_card.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  setUpAll(() {
    initializeDateFormatting('es', null);
  });

  group('ReportCard Golden Tests', () {
    testWidgets('ReportCard - Urgent Status', (tester) async {
      setupGoldenTest(tester);
      final report = Report(
        title: 'Informe Urgente',
        status: ReportStatus.urgent,
        generatedAt: DateTime(2026, 7, 4, 10, 0),
      );

      await tester.pumpWidget(
        wrapWithMaterial(
          Scaffold(
            body: Center(
              child: ReportCard(report: report, onTap: () {}),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ReportCard),
        matchesGoldenFile("goldens/report_card_urgent.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('ReportCard - Finalized Status', (tester) async {
      setupGoldenTest(tester);
      final report = Report(
        title: 'Informe Finalizado',
        status: ReportStatus.finalized,
        generatedAt: DateTime(2026, 7, 4, 10, 0),
      );

      await tester.pumpWidget(
        wrapWithMaterial(
          Scaffold(
            body: Center(
              child: ReportCard(report: report, onTap: () {}),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ReportCard),
        matchesGoldenFile("goldens/report_card_finalized.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('ReportCard - Pending Status', (tester) async {
      setupGoldenTest(tester);
      final report = Report(
        title: 'Informe Pendiente',
        status: ReportStatus.pending,
        generatedAt: DateTime(2026, 7, 4, 10, 0),
      );

      await tester.pumpWidget(
        wrapWithMaterial(
          Scaffold(
            body: Center(
              child: ReportCard(report: report, onTap: () {}),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ReportCard),
        matchesGoldenFile("goldens/report_card_pending.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
