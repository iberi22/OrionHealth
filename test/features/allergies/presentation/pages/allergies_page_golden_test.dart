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
    GetIt.instance.reset();
    mockAllergiesCubit = MockAllergiesCubit();
    GetIt.I.registerSingleton<AllergiesCubit>(mockAllergiesCubit);
  });

  tearDownAll(() {
    if (GetIt.I.isRegistered<AllergiesCubit>()) {
      GetIt.I.unregister<AllergiesCubit>();
    }
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: AllergiesPage(),
    );
  }

  testWidgets('AllergiesPage golden test', (tester) async {
    final allergies = [
      Allergy(id: 1, allergen: 'Peanuts', severity: AllergySeverity.severe, notes: 'Anaphylaxis risk'),
      Allergy(id: 2, allergen: 'Pollen', severity: AllergySeverity.mild),
    ];

    when(() => mockAllergiesCubit.state).thenReturn(AllergiesLoaded(allergies));
    when(() => mockAllergiesCubit.loadAllergies()).thenAnswer((_) async => {});
    when(() => mockAllergiesCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAllergiesCubit.close()).thenAnswer((_) async => {});

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(AllergiesPage),
      matchesGoldenFile("../../../../golden/reference/allergies_page.png"),
    );
  });
}
