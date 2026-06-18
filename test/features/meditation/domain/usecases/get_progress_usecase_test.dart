import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_progress.dart';
import 'package:orionhealth_health/features/meditation/domain/repositories/meditation_repository.dart';
import 'package:orionhealth_health/features/meditation/domain/usecases/get_progress_usecase.dart';

class MockMeditationRepository extends Mock implements MeditationRepository {}

void main() {
  late GetProgressUseCase useCase;
  late MockMeditationRepository mockRepository;

  setUp(() {
    mockRepository = MockMeditationRepository();
    useCase = GetProgressUseCase(mockRepository);
  });

  const tProgress = MeditationProgress(
    totalSessions: 5,
    completedSessions: 3,
    totalCompletedSeconds: 900,
  );

  test('should initialize repository and get progress', () async {
    // arrange
    when(() => mockRepository.initialize()).thenAnswer((_) async => {});
    when(() => mockRepository.getProgress()).thenAnswer((_) async => tProgress);

    // act
    final result = await useCase();

    // assert
    expect(result, tProgress);
    verify(() => mockRepository.initialize()).called(1);
    verify(() => mockRepository.getProgress()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
