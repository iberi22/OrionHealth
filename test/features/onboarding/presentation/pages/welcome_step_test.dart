import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/onboarding/application/onboarding_cubit.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/welcome_step.dart';

class MockOnboardingCubit extends Mock implements OnboardingCubit {}

void main() {
  late MockOnboardingCubit mockCubit;

  setUp(() {
    mockCubit = MockOnboardingCubit();
    when(() => mockCubit.state).thenReturn(OnboardingInitial());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.nextStep()).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<OnboardingCubit>.value(
        value: mockCubit,
        child: const Scaffold(body: WelcomeStep()),
      ),
    );
  }

  testWidgets('WelcomeStep displays welcome text and icon', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Bienvenido a OrionHealth'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('clicking Comenzar calls nextStep on cubit', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Comenzar'));
    await tester.pump();

    verify(() => mockCubit.nextStep()).called(1);
  });
}
