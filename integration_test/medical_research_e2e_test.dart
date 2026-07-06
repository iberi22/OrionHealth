import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/home/presentation/pages/home_page.dart';
import 'package:orionhealth_health/features/medical_research/presentation/pages/medical_research_page.dart';
import 'package:orionhealth_health/features/medical_research/domain/entities/medical_research_result.dart';
import 'package:orionhealth_health/features/medical_research/domain/entities/research_query.dart';
import 'package:orionhealth_health/features/medical_research/domain/models/research_result.dart';
import 'package:orionhealth_health/features/medical_research/domain/repositories/medical_research_repository.dart';
import 'package:orionhealth_health/features/medical_research/domain/services/medical_standards_service.dart';
import 'package:medical_standards/medical_standards.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

  Widget createResearchTestWidget(Widget home) {
    return MaterialApp(
      home: home,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
    );
  }

  group('Medical Research Flow - True E2E Tests', () {
    testWidgets('E2E: Navigation to Research and Basic Verification', (WidgetTester tester) async {
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

      // Start from Home Page
      await tester.pumpWidget(createResearchTestWidget(const HomePage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'medical_research', '01_home_page');

      // Navigate to Investigación
      final researchCard = find.text('Investigación');
      expect(researchCard, findsOneWidget);
      await tester.tap(researchCard);
      await tester.pumpAndSettle();

      // Verify Medical Research Page is shown
      expect(find.byType(MedicalResearchPage), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'medical_research', '02_research_loaded');

      expect(find.text('BUSCAR EN BASES DE DATOS MÉDICAS'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Diabetes AI');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump(); // Start loading

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      expect(find.text('Diabetes Study 2025'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'medical_research', '03_research_results');

      // Drug Interactions Check
      when(() => mockStandardsService.checkDrugInteractions(any()))
          .thenAnswer((_) async => ['Aspirin and Warfarin may increase bleeding risk.']);

      await tester.tap(find.text('INTERACCIONES'));
      await tester.pumpAndSettle();
      expect(find.text('VERIFICADOR DE INTERACCIONES'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Aspirin');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Warfarin');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Aspirin and Warfarin may increase bleeding risk.'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'medical_research', '04_interactions_found');

      // ICD-10 Lookup
      final icdCode = Icd10Code(
        code: 'E11.9',
        displayName: 'Type 2 diabetes mellitus without complications',
        category: 'Endocrine, nutritional and metabolic diseases',
        synonyms: ['NIDDM', 'Type 2 diabetes'],
      );

      when(() => mockStandardsService.lookupIcd10(any())).thenAnswer((_) async => icdCode);

      await tester.tap(find.text('ICD-10'));
      await tester.pumpAndSettle();
      expect(find.text('BÚSQUEDA DE CÓDIGOS ICD-10'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Diabetes');
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.text('E11.9'), findsOneWidget);
      expect(find.text('Type 2 diabetes mellitus without complications'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'medical_research', '05_icd10_result');
    });

    testWidgets('E2E: Medical Research Error State', (WidgetTester tester) async {
      when(() => mockRepository.search(any())).thenThrow(Exception('API Error'));
      when(() => mockRepository.getHistory()).thenAnswer((_) async => []);

      await tester.pumpWidget(createResearchTestWidget(const MedicalResearchPage()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'test error');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      expect(find.textContaining('Error en la investigación: Exception: API Error'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'medical_research', '06_error_state');
    });
  });
}
