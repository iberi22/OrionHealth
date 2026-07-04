import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/dashboard/application/dashboard_cubit.dart';
import 'package:orionhealth_health/features/dashboard/application/dashboard_state.dart';
import 'package:orionhealth_health/features/dashboard/presentation/pages/home_dashboard_page.dart';
import 'package:orionhealth_health/core/di/injection.dart';

class MockDashboardCubit extends Mock implements DashboardCubit {}

void main() {
  late MockDashboardCubit mockCubit;

  setUpAll(() {
    mockCubit = MockDashboardCubit();
    getIt.registerSingleton<DashboardCubit>(mockCubit);
  });

  testWidgets('renders CircularProgressIndicator when state is DashboardLoading', (tester) async {
    when(() => mockCubit.state).thenReturn(const DashboardLoading());
    when(() => mockCubit.loadDashboardData()).thenAnswer((_) async {});
    when(() => mockCubit.stream).thenAnswer((_) => Stream.value(const DashboardLoading()));

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeDashboardPage(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
