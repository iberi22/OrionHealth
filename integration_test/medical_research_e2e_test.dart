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
import 'package:orionhealth_health/features/dashboard/presentation/pages/home_dashboard_page.dart';
import 'package:orionhealth_health/features/dashboard/application/dashboard_cubit.dart';
import 'package:orionhealth_health/features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';
import 'package:orionhealth_health/features/dashboard/domain/usecases/get_recent_activity_usecase.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:medical_standards/medical_standards.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'utils/video_recorder.dart';

class MockMedicalResearchRepository extends Mock implements MedicalResearchRepository {}
class MockMedicalStandardsService extends Mock implements MedicalStandardsService {}
class MockGetDashboardStatsUseCase extends Mock implements GetDashboardStatsUseCase {}
class MockGetRecentActivityUseCase extends Mock implements GetRecentActivityUseCase {}

class FakeResearchQuery extends Fake implements ResearchQuery {}
class FakeMedicalResearchResult extends Fake implements MedicalResearchResult {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockMedicalResearchRepository mockResearchRepository;
  late MockMedicalStandardsService mockStandardsService;
  late MockGetDashboardStatsUseCase mockGetStats;
  late MockGetRecentActivityUseCase mockGetRecentActivity;

  setUpAll(() async {
    await di.configureDependencies();
    registerFallbackValue(FakeResearchQuery());
    registerFallbackValue(FakeMedicalResearchResult());
  });

  setUp(() {
    mockResearchRepository = MockMedicalResearchRepository();
    mockStandardsService = MockMedicalStandardsService();
    mockGetStats = MockGetDashboardStatsUseCase();
    mockGetRecentActivity = MockGetRecentActivityUseCase();

    di.getIt.allowReassignment = true;
    di.getIt.registerSingleton<MedicalResearchRepository>(mockResearchRepository);
    di.getIt.registerSingleton<MedicalStandardsService>(mockStandardsService);
    di.getIt.registerSingleton<GetDashboardStatsUseCase>(mockGetStats);
    di.getIt.registerSingleton<GetRecentActivityUseCase>(mockGetRecentActivity);
  });

  tearDown(() {
    di.getIt.unregister<MedicalResearchRepository>();
    di.getIt.unregister<MedicalStandardsService>();
    di.getIt.unregister<GetDashboardStatsUseCase>();
    di.getIt.unregister<GetRecentActivityUseCase>();
  });

  Widget createTestWidget(Widget home) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardCubit>(
          create: (context) => di.getIt<DashboardCubit>(),
        ),
      ],
      child: MaterialApp(
        home: home,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
      ),
    );
  }

  group('Medical Research Flow - E2E Tests', () {
    testWidgets('E2E: Navigation and Complete Research Flow', (WidgetTester tester) async {
      // Mock Dashboard Data
      when(() => mockGetStats()).thenAnswer((_) async => const DashboardStats(
            totalMedications: 3,
            reportsCount: 10,
            lastVitalCheck: null,
          ));
      when(() => mockGetRecentActivity()).thenAnswer((_) async => []);

      // Mock Research Data
      final researchResults = [
        const ResearchResult(
          title: 'Diabetes Study 2025',
          content: 'New findings about diabetes management using AI.',
          source: 'PubMed',
          url: 'https://pubmed.example.com/12345',
          confidence: 0.95,
        ),
      ];
      when(() => mockResearchRepository.search(any())).thenAnswer((_) async => researchResults);
      when(() => mockResearchRepository.saveToHistory(any())).thenAnswer((_) async {});
      when(() => mockResearchRepository.getHistory()).thenAnswer((_) async => []);

      // Mock Interactions
      when(() => mockStandardsService.checkDrugInteractions(any()))
          .thenAnswer((_) async => ['Aspirin and Warfarin may increase bleeding risk.']);

      // Mock ICD-10
      final icdCode = Icd10Code(
        code: 'E11.9',
        displayName: 'Type 2 diabetes mellitus without complications',
        category: 'Endocrine, nutritional and metabolic diseases',
        synonyms: ['NIDDM', 'Type 2 diabetes'],
      );
      when(() => mockStandardsService.lookupIcd10(any())).thenAnswer((_) async => icdCode);

      // 1. Start at HomeDashboardPage
      await tester.pumpWidget(createTestWidget(const HomeDashboardPage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'medical_research', '01_dashboard');

      // 2. Navigate to MedicalResearchPage
      // In home_dashboard_page.dart, the title is 'Investigación'
      final researchCard = find.text('Investigación');
      await tester.scrollUntilVisible(researchCard, 100);
      await tester.tap(researchCard);
      await tester.pumpAndSettle();

      expect(find.byType(MedicalResearchPage), findsOneWidget);
      expect(find.text('INVESTIGACIÓN MÉDICA'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'medical_research', '02_research_home');

      // 3. Test Evidence Tab (EVIDENCIA)
      expect(find.text('BUSCAR EN BASES DE DATOS MÉDICAS'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'Diabetes AI');
      // Tap send button
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump(); // Start loading

      // Verify loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Diabetes Study 2025'), findsOneWidget);
      expect(find.text('PUBMED'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'medical_research', '03_evidence_results');

      // 4. Test Interactions Tab (INTERACCIONES)
      await tester.tap(find.text('INTERACCIONES'));
      await tester.pumpAndSettle();
      expect(find.text('VERIFICADOR DE INTERACCIONES'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'medical_research', '04_interactions_tab');

      // Enter first drug
      await tester.enterText(find.byType(TextField), 'Aspirin');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Enter second drug
      await tester.enterText(find.byType(TextField), 'Warfarin');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Aspirin and Warfarin may increase bleeding risk.'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'medical_research', '05_interactions_found');

      // 5. Test ICD-10 Tab
      await tester.tap(find.text('ICD-10'));
      await tester.pumpAndSettle();
      expect(find.text('BÚSQUEDA DE CÓDIGOS ICD-10'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'medical_research', '06_icd10_tab');

      await tester.enterText(find.byType(TextField), 'Diabetes');
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.text('E11.9'), findsOneWidget);
      expect(find.text('Type 2 diabetes mellitus without complications'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'medical_research', '07_icd10_result');
    });

    testWidgets('E2E: Search Research Error State', (WidgetTester tester) async {
      when(() => mockResearchRepository.search(any())).thenThrow(Exception('API Error'));
      when(() => mockResearchRepository.getHistory()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget(const MedicalResearchPage()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'test error');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      expect(find.textContaining('Error en la investigación: Exception: API Error'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'medical_research', '08_search_error');
    });
  });
}
