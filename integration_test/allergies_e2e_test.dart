import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/allergies/presentation/pages/allergies_page.dart';
import 'package:orionhealth_health/features/allergies/domain/repositories/allergy_repository.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';
import 'package:mocktail/mocktail.dart';
import 'utils/video_recorder.dart';

class MockAllergyRepository extends Mock implements AllergyRepository {}

class FakeAllergy extends Fake implements Allergy {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAllergyRepository mockRepository;

  setUpAll(() async {
    await di.configureDependencies();
    registerFallbackValue(Allergy(id: 0, allergen: '', severity: AllergySeverity.mild));
    registerFallbackValue(FakeAllergy());
  });

  setUp(() {
    mockRepository = MockAllergyRepository();
    di.getIt.allowReassignment = true;
    di.getIt.registerSingleton<AllergyRepository>(mockRepository);

    when(() => mockRepository.getAllergies()).thenAnswer((_) async => []);
  });

  group('Allergies Flow - True E2E Tests', () {
    testWidgets('E2E: CRUD Allergies', (WidgetTester tester) async {
      final allergies = [
        Allergy(id: 1, allergen: 'Penicilina', severity: AllergySeverity.severe),
        Allergy(id: 2, allergen: 'Polen', severity: AllergySeverity.mild),
      ];

      when(() => mockRepository.getAllergies()).thenAnswer((_) async => allergies);

      await tester.pumpWidget(const MaterialApp(home: AllergiesPage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'allergies', '01_list');

      expect(find.text('Penicilina'), findsOneWidget);
      expect(find.text('Polen'), findsOneWidget);

      // Add allergy
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, 'Alérgeno'), 'Nueces');

      when(() => mockRepository.saveAllergy(any())).thenAnswer((_) async {
        allergies.add(Allergy(id: 3, allergen: 'Nueces', severity: AllergySeverity.mild));
        when(() => mockRepository.getAllergies()).thenAnswer((_) async => allergies);
      });

      await tester.tap(find.text('GUARDAR'));
      await tester.pumpAndSettle();

      verify(() => mockRepository.saveAllergy(any())).called(1);

      // The real Cubit calls loadAllergies() after saveAllergy(), which calls repo.getAllergies()
      await tester.pumpAndSettle();
      expect(find.text('Nueces'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'allergies', '02_added');
    });
  });
}
