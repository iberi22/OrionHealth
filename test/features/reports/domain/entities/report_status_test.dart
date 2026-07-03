import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/reports/domain/entities/report.dart';

void main() {
  group('ReportStatus Extension', () {
    test('pending should have correct label', () {
      final report = Report(status: ReportStatus.pending);
      expect(report.statusLabel, 'Pendiente');
    });

    test('finalized should have correct label', () {
      final report = Report(status: ReportStatus.finalized);
      expect(report.statusLabel, 'Finalizado');
    });

    test('urgent should have correct label', () {
      final report = Report(status: ReportStatus.urgent);
      expect(report.statusLabel, 'Urgente');
    });
  });
}
