import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/reports/application/bloc/report_bloc.dart';
import 'package:orionhealth_health/features/reports/domain/entities/report.dart';
import 'package:orionhealth_health/features/reports/presentation/pages/reports_page.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:orionhealth_health/core/theme/app_theme.dart';
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
  });

  setUp(() {
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockBloc.close()).thenAnswer((_) async {});
  });

  testWidgets('Reports Page - List Loaded Golden', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    final now = DateTime.now();
    final reports = [
      Report(
        title: 'Informe de Salud Semanal',
        content: 'Resumen de actividad física y nutrición.',
        status: ReportStatus.finalized,
        generatedAt: now,
      ),
      Report(
        title: 'Alerta de Presión Arterial',
        content: 'Se detectaron valores inusuales.',
        status: ReportStatus.urgent,
        generatedAt: now.subtract(const Duration(days: 1)),
      ),
      Report(
        title: 'Chequeo Mensual',
        content: 'Pendiente de revisión por el médico.',
        status: ReportStatus.pending,
        generatedAt: now.subtract(const Duration(days: 10)),
      ),
    ];

    when(() => mockBloc.state).thenReturn(ReportLoaded(reports));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: const ReportsPage(),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(ReportsPage),
      matchesGoldenFile("../../../../../golden/reference/reports_page_list_loaded.png"),
    );

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  testWidgets('Reports Page - Empty State Golden', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    when(() => mockBloc.state).thenReturn(ReportLoaded(const []));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: const ReportsPage(),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(ReportsPage),
      matchesGoldenFile("../../../../../golden/reference/reports_page_empty.png"),
    );

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
