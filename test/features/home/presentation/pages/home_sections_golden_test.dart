import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/home/presentation/pages/home_page.dart';
import 'package:orionhealth_health/features/home/presentation/widgets/health_status_grid.dart';
import 'package:orionhealth_health/features/dashboard/presentation/pages/home_dashboard_page.dart';
import 'package:orionhealth_health/features/home/application/home_cubit.dart';
import 'package:orionhealth_health/features/home/application/home_state.dart';
import 'package:orionhealth_health/core/theme/app_theme.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class MockHomeCubit extends Mock implements HomeCubit {}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  late MockHomeCubit mockHomeCubit;

  setUp(() {
    mockHomeCubit = MockHomeCubit();
    when(() => mockHomeCubit.state).thenReturn(const HomeState());
    when(() => mockHomeCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockHomeCubit.close()).thenAnswer((_) async {});
  });

  group('Home Sections Golden Tests', () {
    testWidgets('HealthStatusGrid Golden Test', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 400);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: BlocProvider<HomeCubit>.value(
              value: mockHomeCubit,
              child: const SingleChildScrollView(
                child: HealthStatusGrid(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(HealthStatusGrid),
        matchesGoldenFile('goldens/health_status_grid.png'),
      );

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('QuickActionsGrid Golden Test', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          themeMode: ThemeMode.dark,
          home: Scaffold(
            body: HomeDashboardPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(HomeDashboardPage),
        matchesGoldenFile('goldens/home_dashboard_page_sections.png'),
      );

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });
  });
}
