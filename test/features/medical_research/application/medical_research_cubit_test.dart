import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:medical_standards/medical_standards.dart';
import 'package:orionhealth_health/features/medical_research/application/medical_research_cubit.dart';
import 'package:orionhealth_health/features/medical_research/domain/models/research_result.dart';
import 'package:orionhealth_health/features/medical_research/domain/services/medical_standards_service.dart';
import 'package:orionhealth_health/features/medical_research/infrastructure/medical_research_service.dart';

class MockMedicalResearchService extends Mock implements MedicalResearchService {}
class MockMedicalStandardsService extends Mock implements MedicalStandardsService {}

void main() {
  late MedicalResearchCubit cubit;
  late MockMedicalResearchService mockResearchService;
  late MockMedicalStandardsService mockStandardsService;

  setUp(() {
    mockResearchService = MockMedicalResearchService();
    mockStandardsService = MockMedicalStandardsService();
    cubit = MedicalResearchCubit(mockResearchService, mockStandardsService);
  });

  tearDown(() {
    cubit.close();
  });

  group('MedicalResearchCubit', () {
    test('initial state is correct', () {
      expect(cubit.state, const MedicalResearchState());
    });

    test('emits [Loading, Success] when performResearch is successful', () async {
      final results = [
        const ResearchResult(
          title: 'Test Study',
          content: 'Test Content',
          source: 'PubMed',
          url: 'https://test.com',
        ),
      ];
      when(() => mockResearchService.performResearch(any()))
          .thenAnswer((_) async => results);

      final states = <MedicalResearchState>[];
      cubit.stream.listen(states.add);

      await cubit.performResearch('diabetes');

      await Future.delayed(Duration.zero);

      expect(states, [
        const MedicalResearchState(
          status: MedicalResearchStatus.loading,
          loadingMessage: 'Buscando evidencia médica...',
        ),
        MedicalResearchState(
          status: MedicalResearchStatus.success,
          results: results,
        ),
      ]);
    });

    test('emits [Loading, Error] when performResearch fails', () async {
      when(() => mockResearchService.performResearch(any()))
          .thenThrow(Exception('Network error'));

      final states = <MedicalResearchState>[];
      cubit.stream.listen(states.add);

      await cubit.performResearch('diabetes');

      await Future.delayed(Duration.zero);

      expect(states, [
        const MedicalResearchState(
          status: MedicalResearchStatus.loading,
          loadingMessage: 'Buscando evidencia médica...',
        ),
        const MedicalResearchState(
          status: MedicalResearchStatus.error,
          errorMessage: 'Error en la investigación: Exception: Network error',
        ),
      ]);
    });

    test('emits [Loading, Success] and preserves other data', () async {
      final results = [
        const ResearchResult(title: 'Study', content: 'Content', source: 'S', url: 'U'),
      ];
      final interactions = ['Interaction'];

      when(() => mockResearchService.performResearch(any()))
          .thenAnswer((_) async => results);
      when(() => mockStandardsService.checkDrugInteractions(any()))
          .thenAnswer((_) async => interactions);

      await cubit.performResearch('query');
      expect(cubit.state.results, results);

      await cubit.checkInteractions(['code']);
      expect(cubit.state.results, results);
      expect(cubit.state.interactions, interactions);
    });

    test('lookupIcd10 updates state correctly', () async {
      const mockCode = Icd10Code(code: 'E11', displayName: 'Type 2 Diabetes', category: 'Endocrine');
      when(() => mockStandardsService.lookupIcd10(any()))
          .thenAnswer((_) async => mockCode);

      await cubit.lookupIcd10('diabetes');

      expect(cubit.state.status, MedicalResearchStatus.success);
      expect(cubit.state.icd10Result, mockCode);
    });

    test('reset clears state', () async {
      const mockCode = Icd10Code(code: 'E11', displayName: 'Type 2 Diabetes', category: 'Endocrine');
      when(() => mockStandardsService.lookupIcd10(any()))
          .thenAnswer((_) async => mockCode);

      await cubit.lookupIcd10('diabetes');
      expect(cubit.state.icd10Result, isNotNull);

      cubit.reset();
      expect(cubit.state, const MedicalResearchState());
    });
  });
}
