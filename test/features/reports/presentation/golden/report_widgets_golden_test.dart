import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/reports/domain/entities/report.dart';
import 'package:orionhealth_health/features/reports/presentation/widgets/report_card.dart';
import 'package:orionhealth_health/core/theme/app_theme.dart';

void main() {
  testWidgets('Report Card Widgets Golden', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1.0;

    final reports = [
      Report(
        title: 'Informe Finalizado',
        status: ReportStatus.finalized,
        generatedAt: DateTime(2023, 6, 1, 10, 30),
      ),
      Report(
        title: 'Informe Urgente',
        status: ReportStatus.urgent,
        generatedAt: DateTime(2023, 6, 1, 11, 45),
      ),
      Report(
        title: 'Informe Pendiente',
        status: ReportStatus.pending,
        generatedAt: DateTime(2023, 6, 1, 14, 20),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              return ReportCard(
                report: reports[index],
                onTap: () {},
              );
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(ListView),
      matchesGoldenFile("../../../../../golden/reference/report_cards_statuses.png"),
    );

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
