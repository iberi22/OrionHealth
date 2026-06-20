import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/reports/domain/entities/report.dart';
import 'package:orionhealth_health/features/reports/infrastructure/services/mock_report_generation_service.dart';
import 'package:orionhealth_health/features/reports/presentation/pages/report_detail_page.dart';

void main() {
  group('MockReportGenerationService', () {
    late MockReportGenerationService service;

    setUp(() {
      service = MockReportGenerationService();
    });

    test('generateReport returns a valid report with content and status', () async {
      const prompt = 'Analyze my symptoms';
      final contextData = ['Heart rate: 80 bpm', 'BP: 120/80'];

      final report = await service.generateReport(
        prompt: prompt,
        contextData: contextData,
      );

      expect(report.title, contains('Informe de Salud'));
      expect(report.content, contains('Informe de Salud Generado'));
      expect(report.content, contains('Heart rate: 80 bpm'));
      expect(report.content, contains('BP: 120/80'));
      expect(report.generatedAt, isNotNull);
      expect(report.status, isA<ReportStatus>());
    });

    test('generateReport handles empty context data', () async {
      final report = await service.generateReport(
        prompt: 'Test',
        contextData: [],
      );

      expect(report.content, isNotEmpty);
      expect(report.title, isNotEmpty);
    });
  });

  group('Report PDF Generation Support', () {
    testWidgets('ReportDetailPage contains RepaintBoundary for PDF capture', (WidgetTester tester) async {
      final report = Report(
        title: 'PDF Test Report',
        content: '# Content',
        status: ReportStatus.finalized,
        generatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ReportDetailPage(report: report),
        ),
      );

      // Verify that there is a RepaintBoundary which is used by the system to capture the widget as an image/PDF
      final repaintBoundaryFinder = find.byType(RepaintBoundary);
      expect(repaintBoundaryFinder, findsAtLeastNWidgets(1));

      // Specifically, we want to make sure the one wrapping the content exists
      // In ReportDetailPage, it is defined as:
      // body: RepaintBoundary(child: Padding(padding: ..., child: Markdown(data: ...)))

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.body, isA<RepaintBoundary>());
    });
  });
}
