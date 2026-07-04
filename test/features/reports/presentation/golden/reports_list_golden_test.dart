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
import '../../../../core/golden_test_utils.dart';

class MockReportBloc extends Mock implements ReportBloc {}
class MockWalletService extends Mock implements WalletService {}

void main() {
  late MockReportBloc mockBloc;
  late MockWalletService mockWalletService;

  setUpAll(() {
    mockBloc = MockReportBloc();
    mockWalletService = MockWalletService();
    final getIt = GetIt.instance;
    getIt.registerFactory<ReportBloc>(() => mockBloc);
    getIt.registerLazySingleton<WalletService>(() => mockWalletService);
  });

  testWidgets('Reports Page - List Golden Test', (WidgetTester tester) async {
    setupGoldenTest(tester);

    final reports = [
      Report(
        title: 'Informe Mensual de Salud',
        content: 'Todo parece estar en orden.',
        status: ReportStatus.finalized,
        generatedAt: DateTime(2023, 6, 1),
      ),
    ];

    when(() => mockBloc.state).thenReturn(ReportLoaded(reports));
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockBloc.close()).thenAnswer((_) async {});

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
      matchesGoldenFile('goldens/reports_page_list.png'),
    );

    resetGoldenTest(tester);
  });
}
