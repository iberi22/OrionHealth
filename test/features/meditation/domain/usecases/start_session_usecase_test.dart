import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_category.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_script.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_session.dart';
import 'package:orionhealth_health/features/meditation/domain/repositories/meditation_repository.dart';
import 'package:orionhealth_health/features/meditation/domain/usecases/start_session_usecase.dart';

class MockMeditationRepository extends Mock implements MeditationRepository {}

class FakeMeditationScript extends Fake implements MeditationScript {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeMeditationScript());
  });

  late StartSessionUseCase useCase;
  late MockMeditationRepository mockRepository;

  setUp(() {
    mockRepository = MockMeditationRepository();
    useCase = StartSessionUseCase(mockRepository);
  });

  const tScript = MeditationScript(
    id: '1',
    title: 'Title',
    category: MeditationCategory.calm,
    durationMinutes: 5,
    steps: ['Step 1'],
  );

  final tSession = MeditationSession(
    id: '1',
    scriptId: '1',
    category: MeditationCategory.calm,
    startedAt: DateTime(2025, 1, 1),
  );

  test('should call startSession on the repository', () async {
    // arrange
    when(() => mockRepository.startSession(any()))
        .thenAnswer((_) async => tSession);

    // act
    final result = await useCase(tScript);

    // assert
    expect(result, tSession);
    verify(() => mockRepository.startSession(tScript)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
