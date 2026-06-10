import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/allergies/presentation/pages/allergies_page.dart';
import 'package:orionhealth_health/features/allergies/application/allergies_cubit.dart';
import 'package:orionhealth_health/features/allergies/application/allergies_state.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';
import 'package:get_it/get_it.dart';

class MockAllergiesCubit extends Mock implements AllergiesCubit {}

void main() {
  late MockAllergiesCubit mockAllergiesCubit;

  setUpAll(() {
    mockAllergiesCubit = MockAllergiesCubit();
    GetIt.I.registerLazySingleton<AllergiesCubit>(() => mockAllergiesCubit);
  });

  tearDownAll(() {
    GetIt.I.unregister<AllergiesCubit>();
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: AllergiesPage(),
    );
  }

  testWidgets('should show loading indicator when state is AllergiesLoading', (tester) async {
    when(() => mockAllergiesCubit.state).thenReturn(AllergiesLoading());
    when(() => mockAllergiesCubit.loadAllergies()).thenAnswer((_) async => {});
    when(() => mockAllergiesCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAllergiesCubit.close()).thenAnswer((_) async => {});

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('should show list of allergies when state is AllergiesLoaded', (tester) async {
    final allergies = [
      Allergy(id: 1, allergen: 'Peanuts', severity: AllergySeverity.severe),
      Allergy(id: 2, allergen: 'Pollen', severity: AllergySeverity.mild),
    ];

    when(() => mockAllergiesCubit.state).thenReturn(AllergiesLoaded(allergies));
    when(() => mockAllergiesCubit.loadAllergies()).thenAnswer((_) async => {});
    when(() => mockAllergiesCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAllergiesCubit.close()).thenAnswer((_) async => {});

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Peanuts'), findsOneWidget);
    expect(find.text('Pollen'), findsOneWidget);
    expect(find.text('CRÍTICAS'), findsOneWidget);
    expect(find.text('OTRAS ALERGIAS'), findsOneWidget);
  });

  testWidgets('should show error message when state is AllergiesError', (tester) async {
    when(() => mockAllergiesCubit.state).thenReturn(const AllergiesError('Error loading allergies'));
    when(() => mockAllergiesCubit.loadAllergies()).thenAnswer((_) async => {});
    when(() => mockAllergiesCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAllergiesCubit.close()).thenAnswer((_) async => {});

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Error loading allergies'), findsOneWidget);
  });
}
