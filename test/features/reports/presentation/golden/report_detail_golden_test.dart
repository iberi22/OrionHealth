import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/reports/domain/entities/report.dart';
import 'package:orionhealth_health/features/reports/presentation/pages/report_detail_page.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:orionhealth_health/core/theme/app_theme.dart';

void main() {
  testWidgets('Report Detail Page - Regular Content Golden', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    final report = Report(
      title: 'Informe de Salud Trimestral',
      content: '''
# Resumen de Salud
Tu salud general se mantiene estable.

## Puntos Clave
* La presión arterial está dentro de los rangos normales.
* El nivel de actividad física ha aumentado un 10%.
* Se recomienda mantener el consumo de agua actual.

### Recomendaciones
Continúa con tu rutina actual de ejercicios.
''',
      status: ReportStatus.finalized,
      generatedAt: DateTime(2023, 6, 1),
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

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(ReportDetailPage),
      matchesGoldenFile("../../../../../golden/reference/report_detail_page_regular.png"),
    );

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  testWidgets('Report Detail Page - Urgent Content Golden', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    final report = Report(
      title: 'Alerta: Anomalía Detectada',
      content: '''
# Alerta de Salud
Se han detectado irregularidades en tus signos vitales recientes.

## Detalles de la Alerta
**Presión Sistólica:** 150 mmHg (Elevada)
**Frecuencia Cardíaca en Reposo:** 95 bpm (Elevada)

## Acción Requerida
Por favor, **contacta a tu médico de cabecera** lo antes posible para una revisión detallada. No ignores estos síntomas si experimentas dolor de cabeza o visión borrosa.
''',
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

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(ReportDetailPage),
      matchesGoldenFile("../../../../../golden/reference/report_detail_page_urgent.png"),
    );

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
