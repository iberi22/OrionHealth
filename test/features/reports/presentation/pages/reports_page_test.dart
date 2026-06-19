import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/reports/application/bloc/report_bloc.dart';
import 'package:orionhealth_health/features/reports/domain/entities/report.dart';
import 'package:orionhealth_health/features/reports/presentation/pages/reports_page.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:health_wallet/health_wallet.dart';

class MockReportBloc extends Mock implements ReportBloc {}
class MockWalletService extends Mock implements WalletService {}

void main() {
  late MockReportBloc mockBloc;
  late MockWalletService mockWalletService;
  final getIt = GetIt.instance;

  setUpAll(() {
    mockBloc = MockReportBloc();
    mockWalletService = MockWalletService();
    getIt.registerFactory<ReportBloc>(() => mockBloc);
    getIt.registerLazySingleton<WalletService>(() => mockWalletService);

    registerFallbackValue(LoadReports());
    registerFallbackValue(GenerateReportEvent(prompt: '', contextData: []));
  });

  setUp(() {
    when(() => mockBloc.state).thenReturn(const ReportInitial());
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockBloc.close()).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: const ReportsPage(),
    );
  }

  group('ReportsPage', () {
    testWidgets('shows loading indicator when state is ReportLoading', (tester) async {
      when(() => mockBloc.state).thenReturn(const ReportLoading());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when state is ReportError', (tester) async {
      when(() => mockBloc.state).thenReturn(ReportError('Failed to load'));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Error: Failed to load'), findsOneWidget);
    });

    testWidgets('shows empty state when no reports', (tester) async {
      when(() => mockBloc.state).thenReturn(ReportLoaded([]));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('No hay informes disponibles'), findsOneWidget);
    });

    testWidgets('shows reports grouped by date', (tester) async {
      // Set a larger viewport to ensure elements are visible and hit-testable
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final now = DateTime.now();
      final reports = [
        Report(
          title: 'Today Report',
          generatedAt: now,
          status: ReportStatus.finalized,
        ),
        Report(
          title: 'Yesterday Report',
          generatedAt: now.subtract(const Duration(days: 1)),
          status: ReportStatus.urgent,
        ),
      ];

      when(() => mockBloc.state).thenReturn(ReportLoaded(reports));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('HOY'), findsOneWidget);
      expect(find.text('AYER'), findsOneWidget);
      expect(find.text('Today Report'), findsOneWidget);
      expect(find.text('Yesterday Report'), findsOneWidget);
    });

    testWidgets('filters reports by status', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final reports = [
        Report(
          title: 'Urgent Report',
          status: ReportStatus.urgent,
          generatedAt: DateTime.now(),
        ),
        Report(
          title: 'Finalized Report',
          status: ReportStatus.finalized,
          generatedAt: DateTime.now(),
        ),
      ];

      when(() => mockBloc.state).thenReturn(ReportLoaded(reports));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Initially shows both
      expect(find.text('Urgent Report'), findsOneWidget);
      expect(find.text('Finalized Report'), findsOneWidget);

      // Filter by Urgent
      await tester.tap(find.text('Urgentes'));
      await tester.pumpAndSettle();

      expect(find.text('Urgent Report'), findsOneWidget);
      expect(find.text('Finalized Report'), findsNothing);

      // Filter by Finalized
      await tester.tap(find.text('Finalizados'));
      await tester.pumpAndSettle();

      expect(find.text('Urgent Report'), findsNothing);
      expect(find.text('Finalized Report'), findsOneWidget);
    });

    testWidgets('shows empty filtered state when no reports match filter', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final reports = [
        Report(
          title: 'Finalized Report',
          status: ReportStatus.finalized,
          generatedAt: DateTime.now(),
        ),
      ];

      when(() => mockBloc.state).thenReturn(ReportLoaded(reports));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Urgentes'));
      await tester.pumpAndSettle();

      expect(find.text('No hay resultados'), findsOneWidget);
      expect(find.text('Limpiar Filtros'), findsOneWidget);

      // Clear filters
      await tester.tap(find.text('Limpiar Filtros'));
      await tester.pumpAndSettle();

      expect(find.text('Finalized Report'), findsOneWidget);
    });

    testWidgets('calls GenerateReportEvent when "Generar Ahora" is pressed', (tester) async {
      when(() => mockBloc.state).thenReturn(ReportLoaded([]));

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Generar Ahora'));

      verify(() => mockBloc.add(any(that: isA<GenerateReportEvent>()))).called(1);
    });

    testWidgets('shows FHIR export dialog when "Exportar FHIR" is pressed', (tester) async {
      when(() => mockBloc.state).thenReturn(ReportLoaded([]));
      when(() => mockWalletService.exportToFhir()).thenAnswer((_) async => '{"resourceType": "Bundle"}');

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Exportar FHIR'));
      await tester.pumpAndSettle();

      expect(find.text('Exportación FHIR R4'), findsOneWidget);
      expect(find.textContaining('Bundle'), findsOneWidget);

      await tester.tap(find.text('Cerrar'));
      await tester.pumpAndSettle();

      expect(find.text('Exportación FHIR R4'), findsNothing);
    });

    testWidgets('triggers LoadReports on refresh', (tester) async {
      when(() => mockBloc.state).thenReturn(ReportLoaded([]));

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.fling(find.byType(CustomScrollView), const Offset(0.0, 300.0), 1000.0);
      await tester.pumpAndSettle();

      verify(() => mockBloc.add(any(that: isA<LoadReports>()))).called(greaterThanOrEqualTo(1));
    });
  });
}
