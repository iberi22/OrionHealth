import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/onboarding/application/onboarding_cubit.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/medications_step.dart';

class MockOnboardingCubit extends Mock implements OnboardingCubit {}

void main() {
  late MockOnboardingCubit mockCubit;

  setUp(() {
    mockCubit = MockOnboardingCubit();
    when(() => mockCubit.state).thenReturn(OnboardingInitial());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.nextStep()).thenAnswer((_) async {});
    when(() => mockCubit.previousStep()).thenAnswer((_) async {});
    when(() => mockCubit.updateMedications(any())).thenAnswer((_) async {});
    when(() => mockCubit.updateAllergies(any())).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<OnboardingCubit>.value(
        value: mockCubit,
        child: const Scaffold(body: MedicationsStep()),
      ),
    );
  }

  testWidgets('MedicationsStep displays correct titles', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Medicamentos y Alergias'), findsOneWidget);
    expect(find.text('Medicamentos actuales'), findsOneWidget);
    expect(find.text('Alergias'), findsOneWidget);
  });

  testWidgets('adding and removing medications', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    final medInput = find.byType(TextField).first;
    await tester.enterText(medInput, 'Metformin');
    await tester.tap(find.byIcon(Icons.add_circle).first);
    await tester.pump();

    expect(find.text('Metformin'), findsOneWidget);
    verify(() => mockCubit.updateMedications(['Metformin'])).called(1);

    // Remove it
    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pump();
    expect(find.text('Metformin'), findsNothing);
    verify(() => mockCubit.updateMedications([])).called(1);
  });

  testWidgets('adding and removing allergies', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    final allergyInput = find.byType(TextField).last;
    await tester.enterText(allergyInput, 'Peanuts');
    await tester.tap(find.byIcon(Icons.add_circle).last);
    await tester.pump();

    expect(find.text('Peanuts'), findsOneWidget);
    verify(() => mockCubit.updateAllergies(['Peanuts'])).called(1);

    // Remove it
    await tester.tap(find.byIcon(Icons.close).last);
    await tester.pump();
    expect(find.text('Peanuts'), findsNothing);
    verify(() => mockCubit.updateAllergies([])).called(1);
  });

  testWidgets('navigation buttons call cubit', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Atrás'));
    verify(() => mockCubit.previousStep()).called(1);

    await tester.tap(find.text('Siguiente'));
    verify(() => mockCubit.nextStep()).called(1);
  });
}
