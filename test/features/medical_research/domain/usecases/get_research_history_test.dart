import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/medical_research/domain/entities/medical_research_result.dart';
import 'package:orionhealth_health/features/medical_research/domain/repositories/medical_research_repository.dart';
import 'package:orionhealth_health/features/medical_research/domain/usecases/get_research_history.dart';

class MockMedicalResearchRepository extends Mock implements MedicalResearchRepository {}

void main() {
  late GetResearchHistory useCase;
  late MockMedicalResearchRepository mockRepository;

  setUp(() {
    mockRepository = MockMedicalResearchRepository();
    useCase = GetResearchHistory(mockRepository);
  });

  final tHistory = [
    MedicalResearchResult(
      query: 'diabetes',
      timestamp: DateTime.now(),
      items: [],
    ),
  ];

  test('should get history from repository', () async {
    // arrange
    when(() => mockRepository.getHistory()).thenAnswer((_) async => tHistory);

    // act
    final result = await useCase.execute();

    // assert
    expect(result, tHistory);
    verify(() => mockRepository.getHistory()).called(1);
  });
}
