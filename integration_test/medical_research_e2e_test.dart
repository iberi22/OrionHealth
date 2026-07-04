import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/medical_research/presentation/pages/medical_research_page.dart';
import 'package:orionhealth_health/features/medical_research/application/medical_research_cubit.dart';
import 'package:orionhealth_health/features/medical_research/domain/models/research_result.dart';
import 'package:medical_standards/medical_standards.dart';
import 'package:mocktail/mocktail.dart';
import 'utils/video_recorder.dart';

class MockMedicalResearchCubit extends Mock implements MedicalResearchCubit {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockMedicalResearchCubit mockCubit;
  late StreamController<MedicalResearchState> stateController;

  setUp(() {
    mockCubit = MockMedicalResearchCubit();
    stateController = StreamController<MedicalResearchState>.broadcast();

    // Register the mock in GetIt
    if (getIt.isRegistered<MedicalResearchCubit>()) {
      getIt.unregister<MedicalResearchCubit>();
    }
    getIt.registerSingleton<MedicalResearchCubit>(mockCubit);

    when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);
    when(() => mockCubit.close()).thenAnswer((_) async {});
  });

  tearDown(() {
    stateController.close();
    getIt.unregister<MedicalResearchCubit>();
  });

  group('Medical Research Flow - E2E Tests', () {
    testWidgets('E2E: Search Research Evidence', (WidgetTester tester) async {
      const initialState = MedicalResearchState(status: MedicalResearchStatus.idle);
      when(() => mockCubit.state).thenReturn(initialState);

      await tester.pumpWidget(const MaterialApp(home: MedicalResearchPage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'research', '01_initial_evidence');

      expect(find.text('BUSCAR EN BASES DE DATOS MÉDICAS'), findsOneWidget);

      final results = [
        const ResearchResult(
          title: 'Diabetes Study 2025',
          content: 'New findings about diabetes management using AI.',
          source: 'PubMed',
          url: 'https://pubmed.example.com/12345',
          confidence: 0.95,
        ),
      ];

      when(() => mockCubit.performResearch(any())).thenAnswer((_) async {
        final loadingState = initialState.copyWith(
          status: MedicalResearchStatus.loading,
          loadingMessage: 'Buscando evidencia médica...',
        );
        when(() => mockCubit.state).thenReturn(loadingState);
        stateController.add(loadingState);

        // Simulate delay
        await Future.delayed(const Duration(milliseconds: 100));

        final successState = initialState.copyWith(
          status: MedicalResearchStatus.success,
          results: results,
        );
        when(() => mockCubit.state).thenReturn(successState);
        stateController.add(successState);
      });

      await tester.enterText(find.byType(TextField).first, 'Diabetes AI');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump(); // Start loading

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      expect(find.text('Diabetes Study 2025'), findsOneWidget);
      expect(find.text('PUBMED'), findsOneWidget);
      expect(find.text('95% conf.'), findsOneWidget);

      await VideoRecorder.recordStep(tester, 'research', '02_research_results');
    });

    testWidgets('E2E: Drug Interactions Check', (WidgetTester tester) async {
      const initialState = MedicalResearchState(status: MedicalResearchStatus.idle);
      when(() => mockCubit.state).thenReturn(initialState);

      await tester.pumpWidget(const MaterialApp(home: MedicalResearchPage()));
      await tester.pumpAndSettle();

      // Navigate to Interactions tab
      await tester.tap(find.text('INTERACCIONES'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'research', '03_interactions_tab');

      expect(find.text('VERIFICADOR DE INTERACCIONES'), findsOneWidget);

      final interactions = ['Aspirin and Warfarin may increase bleeding risk.'];

      when(() => mockCubit.checkInteractions(any())).thenAnswer((_) async {
        final loadingState = initialState.copyWith(
          status: MedicalResearchStatus.loading,
          loadingMessage: 'Verificando interacciones...',
        );
        when(() => mockCubit.state).thenReturn(loadingState);
        stateController.add(loadingState);

        await Future.delayed(const Duration(milliseconds: 100));

        final successState = initialState.copyWith(
          status: MedicalResearchStatus.success,
          interactions: interactions,
        );
        when(() => mockCubit.state).thenReturn(successState);
        stateController.add(successState);
      });

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
      const initialState = MedicalResearchState(status: MedicalResearchStatus.idle);
      when(() => mockCubit.state).thenReturn(initialState);

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

      when(() => mockCubit.lookupIcd10(any())).thenAnswer((_) async {
        final loadingState = initialState.copyWith(
          status: MedicalResearchStatus.loading,
          loadingMessage: 'Buscando código ICD-10...',
        );
        when(() => mockCubit.state).thenReturn(loadingState);
        stateController.add(loadingState);

        await Future.delayed(const Duration(milliseconds: 100));

        final successState = initialState.copyWith(
          status: MedicalResearchStatus.success,
          icd10Result: icdCode,
        );
        when(() => mockCubit.state).thenReturn(successState);
        stateController.add(successState);
      });

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
