import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/onboarding/application/onboarding_cubit.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/conditions_step.dart';

class MockOnboardingCubit extends Mock implements OnboardingCubit {}

void main() {
  late MockOnboardingCubit mockOnboardingCubit;

  setUp(() {
    mockOnboardingCubit = MockOnboardingCubit();
    when(() => mockOnboardingCubit.state).thenReturn(OnboardingInitial());
    when(() => mockOnboardingCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockOnboardingCubit.updateConditions(any())).thenAnswer((_) async {});
    when(() => mockOnboardingCubit.nextStep()).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<OnboardingCubit>.value(
        value: mockOnboardingCubit,
        child: const Scaffold(body: ConditionsStep()),
      ),
    );
  }

  testWidgets('ConditionsStep displays common conditions and allows selection', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Diabetes'), findsOneWidget);
    expect(find.text('Hipertensión'), findsOneWidget);

    await tester.tap(find.text('Diabetes'));
    await tester.pump();

    verify(() => mockOnboardingCubit.updateConditions(['Diabetes'])).called(1);
  });

  testWidgets('ConditionsStep allows adding custom conditions', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    final textField = find.widgetWithText(TextField, 'Agregar otra condición...');
    await tester.enterText(textField, 'Asma');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    verify(() => mockOnboardingCubit.updateConditions(['Asma'])).called(1);
    expect(find.byType(Chip), findsOneWidget);
    expect(find.descendant(of: find.byType(Chip), matching: find.text('Asma')), findsOneWidget);
  });

  testWidgets('ConditionsStep allows removing conditions', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Add one first
    await tester.tap(find.text('Diabetes'));
    await tester.pump();

    // Find the chip delete icon and tap it
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    verify(() => mockOnboardingCubit.updateConditions([])).called(1);
  });
}
