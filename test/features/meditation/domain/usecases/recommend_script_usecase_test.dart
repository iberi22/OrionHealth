import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_category.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_script.dart';
import 'package:orionhealth_health/features/meditation/domain/repositories/meditation_repository.dart';
import 'package:orionhealth_health/features/meditation/domain/usecases/recommend_script_usecase.dart';

class MockMeditationRepository extends Mock implements MeditationRepository {}

void main() {
  late RecommendScriptUseCase useCase;
  late MockMeditationRepository mockRepository;

  setUp(() {
    mockRepository = MockMeditationRepository();
    useCase = RecommendScriptUseCase(mockRepository);
  });

  const tScript = MeditationScript(
    id: '1',
    title: 'Title',
    category: MeditationCategory.calm,
    durationMinutes: 5,
    steps: ['Step 1'],
  );

  test('should initialize repository and recommend script', () async {
    // arrange
    when(() => mockRepository.initialize()).thenAnswer((_) async => {});
    when(() => mockRepository.recommendScript(memoryHints: any(named: 'memoryHints')))
        .thenAnswer((_) async => tScript);

    // act
    final result = await useCase(memoryHints: ['hint']);

    // assert
    expect(result, tScript);
    verify(() => mockRepository.initialize()).called(1);
    verify(() => mockRepository.recommendScript(memoryHints: ['hint'])).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
