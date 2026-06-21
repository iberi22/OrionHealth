import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orionhealth_health/features/home/application/home_cubit.dart';
import 'package:orionhealth_health/features/home/application/home_state.dart';
import 'package:orionhealth_health/features/dashboard/application/dashboard_cubit.dart';
import 'package:orionhealth_health/features/dashboard/application/dashboard_state.dart';
import 'package:orionhealth_health/features/home/presentation/pages/home_page.dart';

class MockHomeCubit extends Mock implements HomeCubit {}

class MockDashboardCubit extends Mock implements DashboardCubit {}

void main() {
  late MockHomeCubit mockHomeCubit;
  late MockDashboardCubit mockDashboardCubit;

  setUp(() {
    mockHomeCubit = MockHomeCubit();
    when(() => mockHomeCubit.state).thenReturn(const HomeState(status: HomeStatus.loaded));
    when(() => mockHomeCubit.loadDashboard()).thenAnswer((_) async {});
    when(() => mockHomeCubit.refresh()).thenAnswer((_) async {});
    when(() => mockHomeCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockHomeCubit.close()).thenAnswer((_) async {});

    mockDashboardCubit = MockDashboardCubit();
    when(() => mockDashboardCubit.state).thenReturn(const DashboardInitial());
    when(() => mockDashboardCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockDashboardCubit.close()).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>.value(value: mockHomeCubit),
        BlocProvider<DashboardCubit>.value(value: mockDashboardCubit),
      ],
      child: const MaterialApp(
        home: Scaffold(body: HomePageView()),
      ),
    );
  }

  testWidgets('HomePageView displays sections', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('ORION HEALTH'), findsOneWidget);
    expect(find.text('RESUMEN DE SALUD'), findsOneWidget);
    expect(find.text('MÓDULOS'), findsOneWidget);
  });

  testWidgets('HomePageView shows loading indicator when modules are empty', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    when(() => mockHomeCubit.state).thenReturn(const HomeState(status: HomeStatus.loading, modules: []));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('HomePageView handles refresh', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    final scrollFinder = find.byType(CustomScrollView);
    // Use a larger scroll to trigger the refresh
    await tester.drag(scrollFinder, const Offset(0, 500));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    verify(() => mockHomeCubit.refresh()).called(greaterThan(0));
  });
}
