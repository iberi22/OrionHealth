import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/reports/application/bloc/report_bloc.dart';
import 'package:orionhealth_health/features/reports/domain/entities/report.dart';
import 'package:orionhealth_health/features/reports/domain/repositories/report_repository.dart';
import 'package:orionhealth_health/features/reports/domain/services/report_generation_service.dart';

class MockReportRepository extends Mock implements ReportRepository {}
class MockReportGenerationService extends Mock implements ReportGenerationService {}
class FakeReport extends Fake implements Report {}

void main() {
  late ReportBloc reportBloc;
  late MockReportRepository mockRepository;
  late MockReportGenerationService mockGenerationService;

  setUpAll(() {
    registerFallbackValue(FakeReport());
  });

  setUp(() {
    mockRepository = MockReportRepository();
    mockGenerationService = MockReportGenerationService();
    reportBloc = ReportBloc(mockRepository, mockGenerationService);
  });

  tearDown(() {
    reportBloc.close();
  });

  group('ReportBloc', () {
    final tReport = Report(
      generatedAt: DateTime(2023, 1, 1),
      title: 'Test Report',
      content: 'Test Content',
    )..id = 1;
    final tReports = <Report>[tReport];

    test('initial state should be ReportInitial', () {
      expect(reportBloc.state, isA<ReportInitial>());
    });

    group('LoadReports', () {
      test('emits [ReportLoading, ReportLoaded] when loading is successful', () async {
        when(() => mockRepository.getReports()).thenAnswer((_) async => tReports);

        reportBloc.add(LoadReports());

        expectLater(
          reportBloc.stream,
          emitsInOrder([
            isA<ReportLoading>(),
            isA<ReportLoaded>().having((s) => s.reports, 'reports', tReports),
          ]),
        );
      });

      test('emits [ReportLoading, ReportError] when loading fails', () async {
        when(() => mockRepository.getReports()).thenThrow(Exception('Database error'));

        reportBloc.add(LoadReports());

        expectLater(
          reportBloc.stream,
          emitsInOrder([
            isA<ReportLoading>(),
            isA<ReportError>().having((s) => s.message, 'message', contains('Database error')),
          ]),
        );
      });
    });

    group('GenerateReportEvent', () {
      const tPrompt = 'Generate report';
      const tContextData = ['data1', 'data2'];

      test('emits [ReportLoading, ReportLoading, ReportLoaded] when generation is successful', () async {
        when(() => mockGenerationService.generateReport(
              prompt: any(named: 'prompt'),
              contextData: any(named: 'contextData'),
            )).thenAnswer((_) async => tReport);
        when(() => mockRepository.saveReport(any())).thenAnswer((_) async {});
        when(() => mockRepository.getReports()).thenAnswer((_) async => tReports);

        reportBloc.add(GenerateReportEvent(prompt: tPrompt, contextData: tContextData));

        expectLater(
          reportBloc.stream,
          emitsInOrder([
            isA<ReportLoading>(),
            isA<ReportLoading>(),
            isA<ReportLoaded>().having((s) => s.reports, 'reports', tReports),
          ]),
        );
      });

      test('emits [ReportLoading, ReportError] when generation fails', () async {
        when(() => mockGenerationService.generateReport(
              prompt: any(named: 'prompt'),
              contextData: any(named: 'contextData'),
            )).thenThrow(Exception('AI error'));

        reportBloc.add(GenerateReportEvent(prompt: tPrompt, contextData: tContextData));

        expectLater(
          reportBloc.stream,
          emitsInOrder([
            isA<ReportLoading>(),
            isA<ReportError>().having((s) => s.message, 'message', contains('AI error')),
          ]),
        );
      });
    });

    group('DeleteReport', () {
      test('reloads reports when deletion is successful', () async {
        when(() => mockRepository.deleteReport(any())).thenAnswer((_) async {});
        when(() => mockRepository.getReports()).thenAnswer((_) async => <Report>[]);

        reportBloc.add(DeleteReport(1));

        expectLater(
          reportBloc.stream,
          emitsInOrder([
            isA<ReportLoading>(),
            isA<ReportLoaded>().having((s) => s.reports, 'reports', isEmpty),
          ]),
        );
      });

      test('emits ReportError when deletion fails', () async {
        when(() => mockRepository.deleteReport(any())).thenThrow(Exception('Delete failed'));

        reportBloc.add(DeleteReport(1));

        expectLater(
          reportBloc.stream,
          emitsInOrder([
            isA<ReportError>().having((s) => s.message, 'message', contains('Delete failed')),
          ]),
        );
      });
    });

    group('ReportState equality', () {
      test('ReportInitial equality', () {
        expect(const ReportInitial(), const ReportInitial());
      });
      test('ReportLoading equality', () {
        expect(const ReportLoading(), const ReportLoading());
      });
    });
  });
}
