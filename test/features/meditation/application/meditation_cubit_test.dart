import 'dart:async';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/services/audio/audio_player_service.dart';
import 'package:orionhealth_health/features/meditation/application/meditation_cubit.dart';
import 'package:orionhealth_health/features/meditation/application/meditation_state.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_category.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_progress.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_script.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_session.dart';
import 'package:orionhealth_health/features/meditation/domain/usecases/complete_session_usecase.dart';
import 'package:orionhealth_health/features/meditation/domain/usecases/get_progress_usecase.dart';
import 'package:orionhealth_health/features/meditation/domain/usecases/recommend_script_usecase.dart';
import 'package:orionhealth_health/features/meditation/domain/usecases/start_session_usecase.dart';

class MockRecommendScriptUseCase extends Mock implements RecommendScriptUseCase {}

class MockStartSessionUseCase extends Mock implements StartSessionUseCase {}

class MockCompleteSessionUseCase extends Mock implements CompleteSessionUseCase {}

class MockGetProgressUseCase extends Mock implements GetProgressUseCase {}

class MockAudioService extends Mock implements AudioService {}

class FakeMeditationScript extends Fake implements MeditationScript {}

class FakeMeditationSession extends Fake implements MeditationSession {}

void main() {
  late MeditationCubit cubit;
  late MockRecommendScriptUseCase mockRecommendScriptUseCase;
  late MockStartSessionUseCase mockStartSessionUseCase;
  late MockCompleteSessionUseCase mockCompleteSessionUseCase;
  late MockGetProgressUseCase mockGetProgressUseCase;
  late MockAudioService mockAudioService;

  setUpAll(() {
    registerFallbackValue(FakeMeditationScript());
    registerFallbackValue(FakeMeditationSession());
  });

  setUp(() {
    mockRecommendScriptUseCase = MockRecommendScriptUseCase();
    mockStartSessionUseCase = MockStartSessionUseCase();
    mockCompleteSessionUseCase = MockCompleteSessionUseCase();
    mockGetProgressUseCase = MockGetProgressUseCase();
    mockAudioService = MockAudioService();
    when(() => mockAudioService.stopAll()).thenAnswer((_) async => {});

    cubit = MeditationCubit(
      mockRecommendScriptUseCase,
      mockStartSessionUseCase,
      mockCompleteSessionUseCase,
      mockGetProgressUseCase,
      mockAudioService,
    );
  });

  tearDown(() {
    cubit.close();
  });

  const tScript = MeditationScript(
    id: '1',
    title: 'Calm',
    category: MeditationCategory.calm,
    durationMinutes: 5,
    steps: ['Step 1', 'Step 2'],
  );

  const tProgress = MeditationProgress(totalSessions: 1);

  final tSession = MeditationSession(
    id: 's1',
    scriptId: '1',
    category: MeditationCategory.calm,
    startedAt: DateTime(2025, 1, 1),
  );

  group('initialize', () {
    test('should emit [loading, idle] when successful', () async {
      when(() => mockRecommendScriptUseCase()).thenAnswer((_) async => tScript);
      when(() => mockGetProgressUseCase()).thenAnswer((_) async => tProgress);
      when(() => mockAudioService.initialize()).thenAnswer((_) async => {});

      final expected = [
        const MeditationState(status: MeditationStatus.loading),
        MeditationState(
          status: MeditationStatus.idle,
          script: tScript,
          steps: tScript.steps,
          progress: tProgress,
        ),
      ];

      expectLater(cubit.stream, emitsInOrder(expected));

      await cubit.initialize();
    });

    test('should emit [loading, error] when fails', () async {
      when(() => mockRecommendScriptUseCase()).thenThrow(Exception('error'));

      final expected = [
        const MeditationState(status: MeditationStatus.loading),
        const MeditationState(
          status: MeditationStatus.error,
          error: 'Exception: error',
        ),
      ];

      expectLater(cubit.stream, emitsInOrder(expected));

      await cubit.initialize();
    });
  });

  group('startMeditation and timer', () {
    test('should emit [playing] and increment elapsedSeconds over time', () {
      fakeAsync((async) {
        when(() => mockStartSessionUseCase(any())).thenAnswer((_) async => tSession);
        when(() => mockAudioService.speakText(any())).thenAnswer((_) async => {});

        // Set initial state
        when(() => mockRecommendScriptUseCase()).thenAnswer((_) async => tScript);
        when(() => mockGetProgressUseCase()).thenAnswer((_) async => tProgress);
        when(() => mockAudioService.initialize()).thenAnswer((_) async => {});
        cubit.initialize();
        async.flushMicrotasks();

        cubit.startMeditation();
        async.flushMicrotasks();

        expect(cubit.state.status, MeditationStatus.playing);
        expect(cubit.state.elapsedSeconds, 0);

        async.elapse(const Duration(seconds: 1));
        expect(cubit.state.elapsedSeconds, 1);

        async.elapse(const Duration(seconds: 43));
        expect(cubit.state.elapsedSeconds, 44);
        expect(cubit.state.currentStep, 0);

        // At 45 seconds it should auto-advance
        async.elapse(const Duration(seconds: 1));
        expect(cubit.state.elapsedSeconds, 45);
        expect(cubit.state.currentStep, 1);
        verify(() => mockAudioService.speakText(tScript.steps[1])).called(1);
      });
    });

    test('timer should stop when paused', () {
      fakeAsync((async) {
        when(() => mockStartSessionUseCase(any())).thenAnswer((_) async => tSession);
        when(() => mockAudioService.speakText(any())).thenAnswer((_) async => {});
        when(() => mockAudioService.stopTTS()).thenAnswer((_) async => {});

        cubit.emit(MeditationState(
          status: MeditationStatus.idle,
          script: tScript,
          steps: tScript.steps,
        ));

        cubit.startMeditation();
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 5));
        expect(cubit.state.elapsedSeconds, 5);

        cubit.togglePause();
        async.flushMicrotasks();
        expect(cubit.state.status, MeditationStatus.paused);

        async.elapse(const Duration(seconds: 5));
        expect(cubit.state.elapsedSeconds, 5); // Should not have incremented

        cubit.togglePause(); // resume
        async.flushMicrotasks();
        expect(cubit.state.status, MeditationStatus.playing);

        async.elapse(const Duration(seconds: 1));
        expect(cubit.state.elapsedSeconds, 6);
      });
    });
  });

  group('navigation', () {
    test('nextStep should increment currentStep and speak', () async {
      when(() => mockAudioService.speakText(any())).thenAnswer((_) async => {});

      // Initialize and start to get into playing state
      when(() => mockRecommendScriptUseCase()).thenAnswer((_) async => tScript);
      when(() => mockGetProgressUseCase()).thenAnswer((_) async => tProgress);
      when(() => mockAudioService.initialize()).thenAnswer((_) async => {});
      await cubit.initialize();

      when(() => mockStartSessionUseCase(any())).thenAnswer((_) async => tSession);
      await cubit.startMeditation();

      expectLater(
        cubit.stream,
        emits(
          MeditationState(
            status: MeditationStatus.playing,
            script: tScript,
            steps: tScript.steps,
            session: tSession,
            progress: tProgress,
            currentStep: 1,
            elapsedSeconds: 0,
          ),
        ),
      );

      await cubit.nextStep();
      verify(() => mockAudioService.speakText(tScript.steps[1])).called(1);
    });

    test('previousStep should decrement currentStep and speak', () async {
      when(() => mockAudioService.speakText(any())).thenAnswer((_) async => {});

      // Setup state with step 1
      when(() => mockRecommendScriptUseCase()).thenAnswer((_) async => tScript);
      when(() => mockGetProgressUseCase()).thenAnswer((_) async => tProgress);
      when(() => mockAudioService.initialize()).thenAnswer((_) async => {});
      await cubit.initialize();

      when(() => mockStartSessionUseCase(any())).thenAnswer((_) async => tSession);
      await cubit.startMeditation();
      await cubit.nextStep(); // to step 1

      expectLater(
        cubit.stream,
        emits(
          MeditationState(
            status: MeditationStatus.playing,
            script: tScript,
            steps: tScript.steps,
            session: tSession,
            progress: tProgress,
            currentStep: 0,
            elapsedSeconds: 0,
          ),
        ),
      );

      await cubit.previousStep();
      verify(() => mockAudioService.speakText(tScript.steps[0])).called(2); // once on start, once on previous
    });
  });

  group('togglePause', () {
    test('should pause when playing', () async {
      when(() => mockAudioService.stopTTS()).thenAnswer((_) async => {});
      when(() => mockAudioService.speakText(any())).thenAnswer((_) async => {});

      // Setup state
      when(() => mockRecommendScriptUseCase()).thenAnswer((_) async => tScript);
      when(() => mockGetProgressUseCase()).thenAnswer((_) async => tProgress);
      when(() => mockAudioService.initialize()).thenAnswer((_) async => {});
      await cubit.initialize();
      when(() => mockStartSessionUseCase(any())).thenAnswer((_) async => tSession);
      await cubit.startMeditation();

      expectLater(
        cubit.stream,
        emits(
          MeditationState(
            status: MeditationStatus.paused,
            script: tScript,
            steps: tScript.steps,
            session: tSession,
            progress: tProgress,
            currentStep: 0,
            elapsedSeconds: 0,
          ),
        ),
      );

      await cubit.togglePause();
      verify(() => mockAudioService.stopTTS()).called(1);
    });

    test('should resume when paused', () async {
      when(() => mockAudioService.stopTTS()).thenAnswer((_) async => {});
      when(() => mockAudioService.speakText(any())).thenAnswer((_) async => {});

      // Setup state
      when(() => mockRecommendScriptUseCase()).thenAnswer((_) async => tScript);
      when(() => mockGetProgressUseCase()).thenAnswer((_) async => tProgress);
      when(() => mockAudioService.initialize()).thenAnswer((_) async => {});
      await cubit.initialize();
      when(() => mockStartSessionUseCase(any())).thenAnswer((_) async => tSession);
      await cubit.startMeditation();
      await cubit.togglePause();

      expectLater(
        cubit.stream,
        emits(
          MeditationState(
            status: MeditationStatus.playing,
            script: tScript,
            steps: tScript.steps,
            session: tSession,
            progress: tProgress,
            currentStep: 0,
            elapsedSeconds: 0,
          ),
        ),
      );

      await cubit.togglePause();
      verify(() => mockAudioService.speakText(tScript.steps[0])).called(2); // once on start, once on resume
    });
  });

  group('finishMeditation', () {
    test('should complete session and emit completed', () async {
      when(() => mockAudioService.stopAll()).thenAnswer((_) async => {});
      when(() => mockAudioService.speakText(any())).thenAnswer((_) async => {});
      when(() => mockCompleteSessionUseCase(
            session: any(named: 'session'),
            elapsedSeconds: any(named: 'elapsedSeconds'),
            completedSteps: any(named: 'completedSteps'),
          )).thenAnswer((_) async => {});
      when(() => mockGetProgressUseCase()).thenAnswer((_) async => tProgress);

      // Setup state
      when(() => mockRecommendScriptUseCase()).thenAnswer((_) async => tScript);
      when(() => mockAudioService.initialize()).thenAnswer((_) async => {});
      await cubit.initialize();
      when(() => mockStartSessionUseCase(any())).thenAnswer((_) async => tSession);
      await cubit.startMeditation();

      expectLater(
        cubit.stream,
        emits(
          MeditationState(
            status: MeditationStatus.completed,
            script: tScript,
            steps: tScript.steps,
            session: tSession,
            progress: tProgress,
            currentStep: 0,
            elapsedSeconds: 0,
          ),
        ),
      );

      await cubit.finishMeditation();

      verify(() => mockCompleteSessionUseCase(
            session: tSession,
            elapsedSeconds: 0,
            completedSteps: 1,
          )).called(1);
      verify(() => mockAudioService.speakText('La meditación ha terminado.')).called(1);
    });
  });
}
