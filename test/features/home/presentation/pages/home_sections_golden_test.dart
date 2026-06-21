import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/home/presentation/pages/home_page.dart';
import 'package:orionhealth_health/features/home/presentation/widgets/health_status_grid.dart';
import 'package:orionhealth_health/features/dashboard/presentation/pages/home_dashboard_page.dart';
import 'package:orionhealth_health/features/home/application/home_cubit.dart';
import 'package:orionhealth_health/features/home/application/home_state.dart';
import 'package:orionhealth_health/features/dashboard/application/dashboard_cubit.dart';
import 'package:orionhealth_health/features/dashboard/application/dashboard_state.dart';
import 'package:orionhealth_health/core/theme/app_theme.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class MockHomeCubit extends Mock implements HomeCubit {}

class MockDashboardCubit extends Mock implements DashboardCubit {}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  late MockHomeCubit mockHomeCubit;
  late MockDashboardCubit mockDashboardCubit;

  setUp(() {
    mockHomeCubit = MockHomeCubit();
    when(() => mockHomeCubit.state).thenReturn(const HomeState());
    when(() => mockHomeCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockHomeCubit.close()).thenAnswer((_) async {});

    mockDashboardCubit = MockDashboardCubit();
    when(() => mockDashboardCubit.state).thenReturn(const DashboardInitial());
    when(() => mockDashboardCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockDashboardCubit.loadDashboardData()).thenAnswer((_) async {});
    when(() => mockDashboardCubit.close()).thenAnswer((_) async {});
  });

  group('Home Sections Golden Tests', () {
    testWidgets('HealthStatusGrid Golden Test', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 400);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<HomeCubit>.value(value: mockHomeCubit),
        ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const Scaffold(
              body: SingleChildScrollView(
                child: HealthStatusGrid(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(HealthStatusGrid),
        matchesGoldenFile("../../../../golden/reference/health_status_grid.png"),
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
        MultiBlocProvider(
          providers: [
            BlocProvider<DashboardCubit>.value(value: mockDashboardCubit),
          ],
          child: const MaterialApp(
            themeMode: ThemeMode.dark,
            home: Scaffold(
              body: HomeDashboardPage(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(HomeDashboardPage),
        matchesGoldenFile("../../../../golden/reference/home_dashboard_page_sections.png"),
      );

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });
  });
}
