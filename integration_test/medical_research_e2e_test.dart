import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/medical_research/presentation/pages/medical_research_page.dart';
import 'package:orionhealth_health/features/medical_research/domain/entities/medical_research_result.dart';
import 'package:orionhealth_health/features/medical_research/domain/entities/research_query.dart';
import 'package:orionhealth_health/features/medical_research/domain/models/research_result.dart';
import 'package:orionhealth_health/features/medical_research/domain/repositories/medical_research_repository.dart';
import 'package:orionhealth_health/features/medical_research/domain/services/medical_standards_service.dart';
import 'package:medical_standards/medical_standards.dart';
import 'package:mocktail/mocktail.dart';
import 'utils/video_recorder.dart';

class MockMedicalResearchRepository extends Mock implements MedicalResearchRepository {}
class MockMedicalStandardsService extends Mock implements MedicalStandardsService {}

class FakeResearchQuery extends Fake implements ResearchQuery {}
class FakeMedicalResearchResult extends Fake implements MedicalResearchResult {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockMedicalResearchRepository mockRepository;
  late MockMedicalStandardsService mockStandardsService;

  setUpAll(() async {
    await di.configureDependencies();
    registerFallbackValue(FakeResearchQuery());
    registerFallbackValue(FakeMedicalResearchResult());
  });

  setUp(() {
    mockRepository = MockMedicalResearchRepository();
    mockStandardsService = MockMedicalStandardsService();

    di.getIt.allowReassignment = true;
    di.getIt.registerSingleton<MedicalResearchRepository>(mockRepository);
    di.getIt.registerSingleton<MedicalStandardsService>(mockStandardsService);
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

      when(() => mockRepository.search(any())).thenAnswer((_) async => results);
      when(() => mockRepository.saveToHistory(any())).thenAnswer((_) async {});
      when(() => mockRepository.getHistory()).thenAnswer((_) async => []);

      await tester.pumpWidget(const MaterialApp(home: MedicalResearchPage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'medical_research', '01_initial_evidence');

      expect(find.text('BUSCAR EN BASES DE DATOS MÉDICAS'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Diabetes AI');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump(); // Start loading

      // Verify loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Diabetes Study 2025'), findsOneWidget);
      expect(find.text('PUBMED'), findsOneWidget);
      expect(find.text('95% conf.'), findsOneWidget);

      await VideoRecorder.recordStep(tester, 'medical_research', '02_research_results');
    });

    testWidgets('E2E: Drug Interactions Check', (WidgetTester tester) async {
      when(() => mockStandardsService.checkDrugInteractions(any()))
          .thenAnswer((_) async => ['Aspirin and Warfarin may increase bleeding risk.']);

      await tester.pumpWidget(const MaterialApp(home: MedicalResearchPage()));
      await tester.pumpAndSettle();

      // Navigate to Interactions tab
      await tester.tap(find.text('INTERACCIONES'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'medical_research', '03_interactions_tab');

      expect(find.text('VERIFICADOR DE INTERACCIONES'), findsOneWidget);

      // Enter first drug
      await tester.enterText(find.byType(TextField), 'Aspirin');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Enter second drug
      await tester.enterText(find.byType(TextField), 'Warfarin');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Aspirin and Warfarin may increase bleeding risk.'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'medical_research', '04_interactions_found');
    });

    testWidgets('E2E: ICD-10 Lookup', (WidgetTester tester) async {
      final icdCode = Icd10Code(
        code: 'E11.9',
        displayName: 'Type 2 diabetes mellitus without complications',
        category: 'Endocrine, nutritional and metabolic diseases',
        synonyms: ['NIDDM', 'Type 2 diabetes'],
      );

      when(() => mockStandardsService.lookupIcd10(any())).thenAnswer((_) async => icdCode);

      await tester.pumpWidget(const MaterialApp(home: MedicalResearchPage()));
      await tester.pumpAndSettle();

      // Navigate to ICD-10 tab
      await tester.tap(find.text('ICD-10'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'medical_research', '05_icd10_tab');

      expect(find.text('BÚSQUEDA DE CÓDIGOS ICD-10'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Diabetes');
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.text('E11.9'), findsOneWidget);
      expect(find.text('Type 2 diabetes mellitus without complications'), findsOneWidget);
      expect(find.textContaining('NIDDM, Type 2 diabetes'), findsOneWidget);

      await VideoRecorder.recordStep(tester, 'medical_research', '06_icd10_result');
    });

    testWidgets('E2E: Search Research Error', (WidgetTester tester) async {
      when(() => mockRepository.search(any())).thenThrow(Exception('API Error'));
      when(() => mockRepository.getHistory()).thenAnswer((_) async => []);

      await tester.pumpWidget(const MaterialApp(home: MedicalResearchPage()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'test error');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      expect(find.textContaining('Error en la investigación: Exception: API Error'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'medical_research', '07_search_error');
    });
  });
}
