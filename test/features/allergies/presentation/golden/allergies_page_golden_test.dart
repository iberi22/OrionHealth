import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/allergies/presentation/pages/allergies_page.dart';
import 'package:orionhealth_health/features/allergies/application/allergies_cubit.dart';
import 'package:orionhealth_health/features/allergies/application/allergies_state.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';
import '../../../../core/golden_test_utils.dart';

class MockAllergiesCubit extends Mock implements AllergiesCubit {}

void main() {
  late MockAllergiesCubit mockCubit;

  setUp(() async {
    mockCubit = MockAllergiesCubit();
    await GetIt.I.reset();
    GetIt.I.registerFactory<AllergiesCubit>(() => mockCubit);

    // Default mock behavior
    when(() => mockCubit.loadAllergies()).thenAnswer((_) async => {});
    when(() => mockCubit.close()).thenAnswer((_) async => {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('Allergies Page Golden Tests', () {
    testWidgets('Allergies Page - Loading State', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(const AllergiesLoading());

      await tester.pumpWidget(wrapWithMaterial(const AllergiesPage()));

      await expectLater(
        find.byType(AllergiesPage),
        matchesGoldenFile("goldens/allergies_page_loading.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Allergies Page - Empty State', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(const AllergiesLoaded([]));

      await tester.pumpWidget(wrapWithMaterial(const AllergiesPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(AllergiesPage),
        matchesGoldenFile("goldens/allergies_page_empty.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Allergies Page - Loaded State', (tester) async {
      setupGoldenTest(tester);

      final allergies = [
        Allergy(
          id: 1,
          allergen: 'Maní',
          severity: AllergySeverity.severe,
          notes: 'Reacción anafiláctica',
        ),
        Allergy(
          id: 2,
          allergen: 'Polen',
          severity: AllergySeverity.mild,
          notes: 'Rinitis estacional',
        ),
        Allergy(
          id: 3,
          allergen: 'Látex',
          severity: AllergySeverity.moderate,
        ),
      ];

      when(() => mockCubit.state).thenReturn(AllergiesLoaded(allergies));

      await tester.pumpWidget(wrapWithMaterial(const AllergiesPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(AllergiesPage),
        matchesGoldenFile("goldens/allergies_page_loaded.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Allergies Page - Error State', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(const AllergiesError('Error al cargar alergias'));

      await tester.pumpWidget(wrapWithMaterial(const AllergiesPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(AllergiesPage),
        matchesGoldenFile("goldens/allergies_page_error.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
