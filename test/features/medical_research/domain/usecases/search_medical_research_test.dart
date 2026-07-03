import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/medical_research/domain/entities/medical_research_result.dart';
import 'package:orionhealth_health/features/medical_research/domain/entities/research_query.dart';
import 'package:orionhealth_health/features/medical_research/domain/models/research_result.dart';
import 'package:orionhealth_health/features/medical_research/domain/repositories/medical_research_repository.dart';
import 'package:orionhealth_health/features/medical_research/domain/usecases/search_medical_research.dart';

class MockMedicalResearchRepository extends Mock implements MedicalResearchRepository {}

void main() {
  late SearchMedicalResearch useCase;
  late MockMedicalResearchRepository mockRepository;

  setUp(() {
    mockRepository = MockMedicalResearchRepository();
    useCase = SearchMedicalResearch(mockRepository);

    registerFallbackValue(MedicalResearchResult(
      query: '',
      timestamp: DateTime.now(),
      items: [],
    ));
    registerFallbackValue(const ResearchQuery(text: ''));
  });

  const tQuery = ResearchQuery(text: 'diabetes');
  const tResults = [
    ResearchResult(
      title: 'Diabetes Guide',
      content: 'Learn about diabetes.',
      source: 'HealthLine',
      url: 'https://healthline.com/diabetes',
    ),
  ];

  test('should search and save to history when results are found', () async {
    // arrange
    when(() => mockRepository.search(any())).thenAnswer((_) async => tResults);
    when(() => mockRepository.saveToHistory(any())).thenAnswer((_) async => {});

    // act
    final result = await useCase.execute(tQuery);

    // assert
    expect(result, tResults);
    verify(() => mockRepository.search(tQuery)).called(1);
    verify(() => mockRepository.saveToHistory(any())).called(1);
  });

  test('should search and NOT save to history when NO results are found', () async {
    // arrange
    when(() => mockRepository.search(any())).thenAnswer((_) async => []);

    // act
    final result = await useCase.execute(tQuery);

    // assert
    expect(result, isEmpty);
    verify(() => mockRepository.search(tQuery)).called(1);
    verifyNever(() => mockRepository.saveToHistory(any()));
  });
}
