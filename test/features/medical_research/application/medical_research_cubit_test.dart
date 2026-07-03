import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:medical_standards/medical_standards.dart';
import 'package:orionhealth_health/features/medical_research/application/medical_research_cubit.dart';
import 'package:orionhealth_health/features/medical_research/domain/entities/research_query.dart';
import 'package:orionhealth_health/features/medical_research/domain/models/research_result.dart';
import 'package:orionhealth_health/features/medical_research/domain/services/medical_standards_service.dart';
import 'package:orionhealth_health/features/medical_research/domain/usecases/get_research_history.dart';
import 'package:orionhealth_health/features/medical_research/domain/usecases/search_medical_research.dart';

class MockSearchMedicalResearch extends Mock implements SearchMedicalResearch {}
class MockGetResearchHistory extends Mock implements GetResearchHistory {}
class MockMedicalStandardsService extends Mock implements MedicalStandardsService {}

void main() {
  late MedicalResearchCubit cubit;
  late MockSearchMedicalResearch mockSearchUseCase;
  late MockGetResearchHistory mockGetHistoryUseCase;
  late MockMedicalStandardsService mockStandardsService;

  setUpAll(() {
    registerFallbackValue(const ResearchQuery(text: ''));
  });

  setUp(() {
    mockSearchUseCase = MockSearchMedicalResearch();
    mockGetHistoryUseCase = MockGetResearchHistory();
    mockStandardsService = MockMedicalStandardsService();

    // Default mock for loadHistory (called in performResearch)
    when(() => mockGetHistoryUseCase.execute()).thenAnswer((_) async => []);

    cubit = MedicalResearchCubit(
      mockSearchUseCase,
      mockGetHistoryUseCase,
      mockStandardsService,
    );
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
      when(() => mockSearchUseCase.execute(any()))
          .thenAnswer((_) async => results);

      final states = <MedicalResearchState>[];
      cubit.stream.listen(states.add);

      await cubit.performResearch('diabetes');

      await Future.delayed(Duration.zero);

      expect(states, containsAllInOrder([
        const MedicalResearchState(
          status: MedicalResearchStatus.loading,
          loadingMessage: 'Buscando evidencia médica...',
        ),
        MedicalResearchState(
          status: MedicalResearchStatus.success,
          results: results,
        ),
      ]));
    });

    test('emits [Loading, Error] when performResearch fails', () async {
      when(() => mockSearchUseCase.execute(any()))
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

      when(() => mockSearchUseCase.execute(any()))
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
