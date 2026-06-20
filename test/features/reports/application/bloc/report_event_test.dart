import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/reports/application/bloc/report_bloc.dart';

void main() {
  group('ReportEvent', () {
    group('LoadReports', () {
      test('can be instantiated', () {
        expect(LoadReports(), isA<LoadReports>());
      });
    });

    group('GenerateReportEvent', () {
      test('stores properties', () {
        const prompt = 'test prompt';
        const contextData = ['data'];
        final event = GenerateReportEvent(prompt: prompt, contextData: contextData);
        expect(event.prompt, prompt);
        expect(event.contextData, contextData);
      });
    });

    group('DeleteReport', () {
      test('stores id', () {
        final event = DeleteReport(123);
        expect(event.id, 123);
      });
    });
  });
}
