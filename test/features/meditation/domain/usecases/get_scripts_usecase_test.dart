import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_category.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_script.dart';
import 'package:orionhealth_health/features/meditation/domain/repositories/meditation_repository.dart';
import 'package:orionhealth_health/features/meditation/domain/usecases/get_scripts_usecase.dart';

class MockMeditationRepository extends Mock implements MeditationRepository {}

void main() {
  late GetScriptsUseCase useCase;
  late MockMeditationRepository mockRepository;

  setUp(() {
    mockRepository = MockMeditationRepository();
    useCase = GetScriptsUseCase(mockRepository);
  });

  const tScripts = [
    MeditationScript(
      id: '1',
      title: 'Title',
      category: MeditationCategory.calm,
      durationMinutes: 5,
      steps: ['Step 1'],
    ),
  ];

  test('should initialize repository and get scripts', () async {
    // arrange
    when(() => mockRepository.initialize()).thenAnswer((_) async => {});
    when(() => mockRepository.scripts).thenReturn(tScripts);

    // act
    final result = await useCase();

    // assert
    expect(result, tScripts);
    verify(() => mockRepository.initialize()).called(1);
    verify(() => mockRepository.scripts).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
