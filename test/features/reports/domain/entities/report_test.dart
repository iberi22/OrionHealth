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
  });
}
