import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/medical_research/presentation/pages/medical_research_page.dart';
import 'package:orionhealth_health/features/medical_research/application/medical_research_cubit.dart';
import 'package:orionhealth_health/features/medical_research/domain/models/research_result.dart';
import 'package:mocktail/mocktail.dart';
import 'utils/video_recorder.dart';

class MockMedicalResearchCubit extends Mock implements MedicalResearchCubit {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockMedicalResearchCubit mockCubit;

  setUp(() {
    mockCubit = MockMedicalResearchCubit();
    getIt.registerSingleton<MedicalResearchCubit>(mockCubit);

    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() {
    getIt.unregister<MedicalResearchCubit>();
  });

  group('Medical Research Flow - E2E Tests', () {
    testWidgets('E2E: Search Research', (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const MedicalResearchState(status: MedicalResearchStatus.idle));

      await tester.pumpWidget(const MaterialApp(home: MedicalResearchPage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'research', '01_initial');

      await tester.enterText(find.byType(TextField).first, 'Diabetes');

      final results = [
        const ResearchResult(
          title: 'Diabetes Study',
          content: 'New findings',
          source: 'PubMed',
          url: '',
          confidence: 0.9,
        ),
      ];

      when(() => mockCubit.performResearch(any())).thenAnswer((_) async {
        when(() => mockCubit.state).thenReturn(MedicalResearchState(
          status: MedicalResearchStatus.success,
          results: results,
        ));
      });

      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      expect(find.text('Diabetes Study'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'research', '02_results');
    });
  });
}
