import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_category.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_session.dart';
import 'package:orionhealth_health/features/meditation/domain/repositories/meditation_repository.dart';
import 'package:orionhealth_health/features/meditation/domain/usecases/complete_session_usecase.dart';

class MockMeditationRepository extends Mock implements MeditationRepository {}

class FakeMeditationSession extends Fake implements MeditationSession {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeMeditationSession());
  });

  late CompleteSessionUseCase useCase;
  late MockMeditationRepository mockRepository;

  setUp(() {
    mockRepository = MockMeditationRepository();
    useCase = CompleteSessionUseCase(mockRepository);
  });

  final tSession = MeditationSession(
    id: '1',
    scriptId: 'script-1',
    category: MeditationCategory.calm,
    startedAt: DateTime(2025, 1, 1),
  );

  test('should call completeSession on the repository', () async {
    // arrange
    when(() => mockRepository.completeSession(
          session: any(named: 'session'),
          elapsedSeconds: any(named: 'elapsedSeconds'),
          completedSteps: any(named: 'completedSteps'),
        )).thenAnswer((_) async => {});

    // act
    await useCase(
      session: tSession,
      elapsedSeconds: 300,
      completedSteps: 5,
    );

    // assert
    verify(() => mockRepository.completeSession(
          session: tSession,
          elapsedSeconds: 300,
          completedSteps: 5,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
