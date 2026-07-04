import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/reports/domain/entities/report.dart';
import 'package:orionhealth_health/features/reports/presentation/pages/report_detail_page.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:orionhealth_health/core/theme/app_theme.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  testWidgets('Report Detail Page Golden Test', (WidgetTester tester) async {
    setupGoldenTest(tester);

    final report = Report(
      title: 'Alerta de Presión Arterial',
      content: 'El análisis de tus signos vitales de la última semana indica una tendencia al alza en la presión sistólica. Se recomienda consultar con un profesional.',
      status: ReportStatus.urgent,
      generatedAt: DateTime(2023, 6, 5),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: ReportDetailPage(report: report),
      ),
    );

    await tester.pump();

    await expectLater(
      find.byType(ReportDetailPage),
      matchesGoldenFile('goldens/report_detail_page.png'),
    );

    resetGoldenTest(tester);
  });
}
