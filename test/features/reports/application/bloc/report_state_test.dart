import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/reports/application/bloc/report_bloc.dart';
import 'package:orionhealth_health/features/reports/domain/entities/report.dart';

void main() {
  group('ReportState', () {
    test('ReportInitial equality', () {
      expect(const ReportInitial(), const ReportInitial());
    });

    test('ReportLoading equality', () {
      expect(const ReportLoading(), const ReportLoading());
    });

    test('ReportLoaded stores reports', () {
      final reports = [
        Report(
          title: 'Test',
          content: 'Content',
          generatedAt: DateTime(2023),
        )
      ];
      final state = ReportLoaded(reports);
      expect(state.reports, reports);
    });

    test('ReportError stores message', () {
      const message = 'error';
      final state = ReportError(message);
      expect(state.message, message);
    });
  });
}
