import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/allergies/presentation/pages/allergies_page.dart';
import 'package:orionhealth_health/features/allergies/application/allergies_cubit.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';
import 'package:mocktail/mocktail.dart';
import 'utils/video_recorder.dart';

class MockAllergiesCubit extends Mock implements AllergiesCubit {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAllergiesCubit mockCubit;

  setUpAll(() {
    registerFallbackValue(Allergy(id: 0, allergen: '', severity: AllergySeverity.mild));
  });

  setUp(() {
    mockCubit = MockAllergiesCubit();
    getIt.registerSingleton<AllergiesCubit>(mockCubit);

    when(() => mockCubit.loadAllergies()).thenAnswer((_) async {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() {
    getIt.unregister<AllergiesCubit>();
  });

  group('Allergies Flow - E2E Tests', () {
    testWidgets('E2E: CRUD Allergies', (WidgetTester tester) async {
      final allergies = [
        Allergy(id: 1, allergen: 'Penicilina', severity: AllergySeverity.severe),
        Allergy(id: 2, allergen: 'Polen', severity: AllergySeverity.mild),
      ];

      when(() => mockCubit.state).thenReturn(AllergiesLoaded(allergies));

      await tester.pumpWidget(const MaterialApp(home: AllergiesPage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'allergies', '01_list');

      expect(find.text('Penicilina'), findsOneWidget);
      expect(find.text('Polen'), findsOneWidget);

      // Add allergy
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, 'Alérgeno'), 'Nueces');

      when(() => mockCubit.saveAllergy(any())).thenAnswer((_) async {
        allergies.add(Allergy(id: 3, allergen: 'Nueces', severity: AllergySeverity.mild));
        when(() => mockCubit.state).thenReturn(AllergiesLoaded(allergies));
      });

      await tester.tap(find.text('GUARDAR'));
      await tester.pumpAndSettle();

      verify(() => mockCubit.saveAllergy(any())).called(1);

      // Re-render occurs because of Cubit state change in real app,
      // here we might need to pump if state doesn't update stream automatically in mock
      await tester.pumpAndSettle();
      expect(find.text('Nueces'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'allergies', '02_added');
    });
  });
}
