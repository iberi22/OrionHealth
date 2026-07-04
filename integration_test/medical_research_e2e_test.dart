import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/medical_research/presentation/pages/medical_research_page.dart';
import 'package:orionhealth_health/features/medical_research/domain/repositories/medical_research_repository.dart';
import 'package:orionhealth_health/features/medical_research/domain/services/medical_standards_service.dart';
import 'package:orionhealth_health/features/medical_research/domain/models/research_result.dart';
import 'package:orionhealth_health/features/medical_research/domain/entities/research_query.dart';
import 'package:orionhealth_health/features/medical_research/domain/entities/medical_research_result.dart';
import 'package:medical_standards/medical_standards.dart';
import 'package:mocktail/mocktail.dart';
import 'utils/video_recorder.dart';

class MockMedicalResearchRepository extends Mock implements MedicalResearchRepository {}
class MockMedicalStandardsService extends Mock implements MedicalStandardsService {}

class FakeResearchQuery extends Fake implements ResearchQuery {}
class FakeMedicalResearchResult extends Fake implements MedicalResearchResult {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockMedicalResearchRepository mockRepo;
  late MockMedicalStandardsService mockStandards;

  setUpAll(() async {
    await di.configureDependencies();
    di.getIt.allowReassignment = true;

    registerFallbackValue(FakeResearchQuery());
    registerFallbackValue(FakeMedicalResearchResult());
  });

  setUp(() {
    mockRepo = MockMedicalResearchRepository();
    mockStandards = MockMedicalStandardsService();

    di.getIt.registerSingleton<MedicalResearchRepository>(mockRepo);
    di.getIt.registerSingleton<MedicalStandardsService>(mockStandards);
  });

  tearDown(() {
    di.getIt.unregister<MedicalResearchRepository>();
    di.getIt.unregister<MedicalStandardsService>();
  });

  group('Medical Research Flow - E2E Tests', () {
    testWidgets('E2E: Search Research Evidence', (WidgetTester tester) async {
      final results = [
        const ResearchResult(
          title: 'Diabetes Study 2025',
          content: 'New findings about diabetes management using AI.',
          source: 'PubMed',
          url: 'https://pubmed.example.com/12345',
          confidence: 0.95,
        ),
      ];

      when(() => mockRepo.search(any())).thenAnswer((_) async => results);
      when(() => mockRepo.saveToHistory(any())).thenAnswer((_) async {});
      when(() => mockRepo.getHistory()).thenAnswer((_) async => []);

      await tester.pumpWidget(const MaterialApp(home: MedicalResearchPage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'research', '01_initial_evidence');

      expect(find.text('BUSCAR EN BASES DE DATOS MÉDICAS'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Diabetes AI');
      await tester.tap(find.byIcon(Icons.send));

      // Wait for loading to start and finish
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Diabetes Study 2025'), findsOneWidget);
      expect(find.text('PUBMED'), findsOneWidget);
      expect(find.text('95% conf.'), findsOneWidget);

      await VideoRecorder.recordStep(tester, 'research', '02_research_results');
    });

    testWidgets('E2E: Drug Interactions Check', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MedicalResearchPage()));
      await tester.pumpAndSettle();

      // Navigate to Interactions tab
      await tester.tap(find.text('INTERACCIONES'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'research', '03_interactions_tab');

      expect(find.text('VERIFICADOR DE INTERACCIONES'), findsOneWidget);

      final interactions = ['Aspirin and Warfarin may increase bleeding risk.'];

      when(() => mockStandards.checkDrugInteractions(any()))
          .thenAnswer((_) async => interactions);

      // Enter first drug
      await tester.enterText(find.byType(TextField), 'Aspirin');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Enter second drug
      await tester.enterText(find.byType(TextField), 'Warfarin');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Aspirin and Warfarin may increase bleeding risk.'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'research', '04_interactions_found');
    });

    testWidgets('E2E: ICD-10 Lookup', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MedicalResearchPage()));
      await tester.pumpAndSettle();

      // Navigate to ICD-10 tab
      await tester.tap(find.text('ICD-10'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'research', '05_icd10_tab');

      expect(find.text('BÚSQUEDA DE CÓDIGOS ICD-10'), findsOneWidget);

      final icdCode = Icd10Code(
        code: 'E11.9',
        displayName: 'Type 2 diabetes mellitus without complications',
        category: 'Endocrine, nutritional and metabolic diseases',
        synonyms: ['NIDDM', 'Type 2 diabetes'],
      );

      when(() => mockStandards.lookupIcd10(any())).thenAnswer((_) async => icdCode);

      await tester.enterText(find.byType(TextField), 'Diabetes');
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.text('E11.9'), findsOneWidget);
      expect(find.text('Type 2 diabetes mellitus without complications'), findsOneWidget);
      expect(find.textContaining('NIDDM, Type 2 diabetes'), findsOneWidget);

      await VideoRecorder.recordStep(tester, 'research', '06_icd10_result');
    });
  });
}
