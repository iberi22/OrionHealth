import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orionhealth_health/features/dashboard/presentation/pages/home_dashboard_page.dart';
import 'package:orionhealth_health/features/dashboard/application/dashboard_cubit.dart';
import 'package:orionhealth_health/features/dashboard/application/dashboard_state.dart';
import 'package:orionhealth_health/core/theme/app_theme.dart';
import '../../../../core/golden_test_utils.dart';

class MockDashboardCubit extends Mock implements DashboardCubit {}

void main() {
  late MockDashboardCubit mockDashboardCubit;

  setUp(() {
    mockDashboardCubit = MockDashboardCubit();
    when(() => mockDashboardCubit.state).thenReturn(const DashboardInitial());
    when(() => mockDashboardCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockDashboardCubit.loadDashboardData()).thenAnswer((_) async {});
    when(() => mockDashboardCubit.close()).thenAnswer((_) async {});
  });

  testWidgets('Home Dashboard Page Golden Test', (WidgetTester tester) async {
    setupGoldenTest(tester);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<DashboardCubit>.value(value: mockDashboardCubit),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const HomeDashboardPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(HomeDashboardPage),
      matchesGoldenFile('goldens/home_dashboard_page.png'),
    );

    resetGoldenTest(tester);
  });
}
