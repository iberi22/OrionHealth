import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orionhealth_health/features/home/application/home_cubit.dart';
import 'package:orionhealth_health/features/home/application/home_state.dart';
import 'package:orionhealth_health/features/home/presentation/pages/home_page.dart';

class MockHomeCubit extends Mock implements HomeCubit {}

void main() {
  late MockHomeCubit mockHomeCubit;

  setUp(() {
    mockHomeCubit = MockHomeCubit();
    when(() => mockHomeCubit.state).thenReturn(const HomeState(status: HomeStatus.loaded));
    when(() => mockHomeCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockHomeCubit.close()).thenAnswer((_) async {});
  });

  testWidgets('HomePageView shows progress indicator when loading', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    when(() => mockHomeCubit.state).thenReturn(const HomeState(status: HomeStatus.loading, modules: []));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<HomeCubit>.value(
          value: mockHomeCubit,
          child: const Scaffold(body: HomePageView()),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
