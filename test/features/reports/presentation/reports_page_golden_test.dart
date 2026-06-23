import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/reports/application/bloc/report_bloc.dart';
import 'package:orionhealth_health/features/reports/domain/entities/report.dart';
import 'package:orionhealth_health/features/reports/presentation/pages/reports_page.dart';
import 'package:orionhealth_health/features/reports/presentation/pages/report_detail_page.dart';
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

  testWidgets('Reports Page - List Golden', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    final reports = [
      Report(
        title: 'Informe Mensual de Salud',
        content: 'Todo parece estar en orden.',
        status: ReportStatus.finalized,
        generatedAt: DateTime(2023, 6, 1),
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

    await tester.pump();

    await expectLater(
      find.byType(ReportsPage),
      matchesGoldenFile("../../../golden/reference/reports_page_list.png"),
    );

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  testWidgets('Report Detail Page - Golden', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    final report = Report(
      title: 'Alerta de Presión Arterial',
      content: 'El análisis de tus signos vitales de la última semana indica una tendencia al alza en la presión sistólica. Se recomienda consultar con un profesional.',
      status: ReportStatus.urgent,
      generatedAt: DateTime(2023, 6, 5),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: ReportDetailPage(report: report),
      ),
    );

    await tester.pump();

    await expectLater(
      find.byType(ReportDetailPage),
      matchesGoldenFile("../../../golden/reference/report_detail_page.png"),
    );

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
