import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/reports/domain/entities/report.dart';
import 'package:orionhealth_health/features/reports/domain/repositories/report_repository.dart';

class MockReportRepository extends Mock implements ReportRepository {}
class FakeReport extends Fake implements Report {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeReport());
  });

  group('ReportRepository Interface', () {
    late MockReportRepository mockRepository;

    setUp(() {
      mockRepository = MockReportRepository();
    });

    test('can be mocked and called for all methods', () async {
      final tReport = Report(title: 'Test');
      final tReports = [tReport];

      when(() => mockRepository.saveReport(any())).thenAnswer((_) async {});
      when(() => mockRepository.getReports()).thenAnswer((_) async => tReports);
      when(() => mockRepository.deleteReport(any())).thenAnswer((_) async {});
      when(() => mockRepository.getReportById(any())).thenAnswer((_) async => tReport);

      await mockRepository.saveReport(tReport);
      final reports = await mockRepository.getReports();
      await mockRepository.deleteReport(1);
      final report = await mockRepository.getReportById(1);

      expect(reports, tReports);
      expect(report, tReport);

      verify(() => mockRepository.saveReport(tReport)).called(1);
      verify(() => mockRepository.getReports()).called(1);
      verify(() => mockRepository.deleteReport(1)).called(1);
      verify(() => mockRepository.getReportById(1)).called(1);
    });
  });
}
