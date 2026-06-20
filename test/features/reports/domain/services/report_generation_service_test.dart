import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/reports/domain/entities/report.dart';
import 'package:orionhealth_health/features/reports/domain/services/report_generation_service.dart';

class MockReportGenerationService extends Mock implements ReportGenerationService {}

void main() {
  group('ReportGenerationService Interface', () {
    late MockReportGenerationService mockService;

    setUp(() {
      mockService = MockReportGenerationService();
    });

    test('can be mocked and called', () async {
      final tReport = Report(
        title: 'Test',
        content: 'Content',
        generatedAt: DateTime.now(),
      );

      when(() => mockService.generateReport(
            prompt: any(named: 'prompt'),
            contextData: any(named: 'contextData'),
          )).thenAnswer((_) async => tReport);

      final result = await mockService.generateReport(
        prompt: 'test prompt',
        contextData: ['data'],
      );

      expect(result, tReport);
      verify(() => mockService.generateReport(
            prompt: 'test prompt',
            contextData: ['data'],
          )).called(1);
    });
  });
}
