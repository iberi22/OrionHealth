import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/reports/domain/entities/report.dart';

void main() {
  group('Report Entity', () {
    test('statusLabel returns correct labels', () {
      expect(Report(status: ReportStatus.pending).statusLabel, 'Pendiente');
      expect(Report(status: ReportStatus.finalized).statusLabel, 'Finalizado');
      expect(Report(status: ReportStatus.urgent).statusLabel, 'Urgente');
    });

    test('default status is finalized', () {
      expect(Report().status, ReportStatus.finalized);
    });

    test('constructor correctly assigns values', () {
      final now = DateTime.now();
      final report = Report(
        generatedAt: now,
        title: 'Title',
        content: 'Content',
        status: ReportStatus.urgent,
      );

      expect(report.generatedAt, now);
      expect(report.title, 'Title');
      expect(report.content, 'Content');
      expect(report.status, ReportStatus.urgent);
    });

    test('id can be assigned', () {
      final report = Report();
      report.id = 123;
      expect(report.id, 123);
    });
  });
}
