import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:orionhealth_health/features/reports/domain/entities/report.dart';
import 'package:orionhealth_health/features/reports/presentation/pages/report_detail_page.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  setUpAll(() {
    initializeDateFormatting('es', null);
  });

  group('Report Detail Page Golden Tests', () {
    testWidgets('Report Detail Page - Markdown Content', (tester) async {
      setupGoldenTest(tester);

      final report = Report(
        title: 'Detalle de Alerta',
        content: '# Resumen de Salud\n\n'
            '## Signos Vitales\n'
            '* **Presión Arterial**: 140/90 mmHg (Elevada)\n'
            '* **Frecuencia Cardíaca**: 85 lpm\n\n'
            '### Recomendaciones\n'
            'Se recomienda monitorear la presión arterial diariamente y reducir el consumo de sal.',
        status: ReportStatus.urgent,
        generatedAt: DateTime(2026, 7, 4),
      );

      await tester.pumpWidget(wrapWithMaterial(ReportDetailPage(report: report)));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ReportDetailPage),
        matchesGoldenFile("goldens/report_detail_page.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
