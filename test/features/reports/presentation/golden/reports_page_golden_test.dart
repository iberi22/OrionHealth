import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:orionhealth_health/features/reports/application/bloc/report_bloc.dart';
import 'package:orionhealth_health/features/reports/domain/entities/report.dart';
import 'package:orionhealth_health/features/reports/presentation/pages/reports_page.dart';
import 'package:health_wallet/health_wallet.dart';
import '../../../../core/golden_test_utils.dart';

class MockReportBloc extends Mock implements ReportBloc {}
class MockWalletService extends Mock implements WalletService {}

void main() {
  late MockReportBloc mockBloc;
  late MockWalletService mockWalletService;

  setUpAll(() {
    initializeDateFormatting('es', null);
  });

  setUp(() async {
    mockBloc = MockReportBloc();
    mockWalletService = MockWalletService();
    await GetIt.I.reset();
    GetIt.I.registerFactory<ReportBloc>(() => mockBloc);
    GetIt.I.registerLazySingleton<WalletService>(() => mockWalletService);

    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockBloc.close()).thenAnswer((_) async {});
    when(() => mockBloc.state).thenReturn(const ReportInitial());
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('Reports Page Golden Tests', () {
    testWidgets('Reports Page - Empty State', (tester) async {
      setupGoldenTest(tester);
      when(() => mockBloc.state).thenReturn(ReportLoaded([]));

      await tester.pumpWidget(wrapWithMaterial(const ReportsPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ReportsPage),
        matchesGoldenFile("goldens/reports_page_empty.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Reports Page - Loaded State', (tester) async {
      setupGoldenTest(tester);

      final now = DateTime(2026, 7, 4);
      final reports = [
        Report(
          title: 'Informe de Salud Urgente',
          content: 'Contenido urgente...',
          status: ReportStatus.urgent,
          generatedAt: now,
        ),
        Report(
          title: 'Resumen Mensual',
          content: 'Todo bien.',
          status: ReportStatus.finalized,
          generatedAt: now.subtract(const Duration(days: 2)),
        ),
        Report(
          title: 'Informe Pendiente',
          content: 'Procesando...',
          status: ReportStatus.pending,
          generatedAt: now.subtract(const Duration(days: 10)),
        ),
      ];

      when(() => mockBloc.state).thenReturn(ReportLoaded(reports));

      await tester.pumpWidget(wrapWithMaterial(const ReportsPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ReportsPage),
        matchesGoldenFile("goldens/reports_page_loaded.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
