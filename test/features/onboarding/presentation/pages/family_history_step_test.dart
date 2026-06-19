import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/onboarding/application/onboarding_cubit.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/family_history_step.dart';

class MockOnboardingCubit extends Mock implements OnboardingCubit {}

void main() {
  late MockOnboardingCubit mockCubit;

  setUp(() {
    mockCubit = MockOnboardingCubit();
    when(() => mockCubit.state).thenReturn(OnboardingInitial());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.nextStep()).thenAnswer((_) async {});
    when(() => mockCubit.previousStep()).thenAnswer((_) async {});
    when(() => mockCubit.updateFamilyHistory(any())).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<OnboardingCubit>.value(
        value: mockCubit,
        child: const Scaffold(body: FamilyHistoryStep()),
      ),
    );
  }

  testWidgets('FamilyHistoryStep displays chips and title', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Historial Familiar'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Diabetes'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Hipertensión'), findsOneWidget);
  });

  testWidgets('selecting and deselecting a common condition', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    final chip = find.widgetWithText(FilterChip, 'Diabetes');
    await tester.tap(chip);
    await tester.pump();
    verify(() => mockCubit.updateFamilyHistory(['Diabetes'])).called(1);

    await tester.tap(chip);
    await tester.pump();
    verify(() => mockCubit.updateFamilyHistory([])).called(1);
  });

  testWidgets('adding a custom condition', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextField), 'My custom condition');
    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pump();

    expect(find.widgetWithText(Chip, 'My custom condition'), findsOneWidget);
    verify(() => mockCubit.updateFamilyHistory(['My custom condition'])).called(1);
  });

  testWidgets('navigation buttons work', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Atrás'));
    verify(() => mockCubit.previousStep()).called(1);

    await tester.tap(find.text('Siguiente'));
    verify(() => mockCubit.nextStep()).called(1);
  });
}
