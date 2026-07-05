import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/meditation/presentation/meditation_page.dart';
import 'package:orionhealth_health/features/meditation/domain/repositories/meditation_repository.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_script.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_session.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_progress.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_category.dart';
import 'package:orionhealth_health/core/services/audio/audio_player_service.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'utils/video_recorder.dart';

class MockMeditationRepository extends Mock implements MeditationRepository {}
class MockAudioService extends Mock implements AudioService {}

class FakeMeditationScript extends Fake implements MeditationScript {}
class FakeMeditationSession extends Fake implements MeditationSession {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockMeditationRepository mockRepository;
  late MockAudioService mockAudioService;

  setUpAll(() async {
    registerFallbackValue(FakeMeditationScript());
    registerFallbackValue(FakeMeditationSession());
    await di.configureDependencies();
  });

  setUp(() {
    mockRepository = MockMeditationRepository();
    mockAudioService = MockAudioService();
    di.getIt.allowReassignment = true;
    di.getIt.registerSingleton<MeditationRepository>(mockRepository);
    di.getIt.registerSingleton<AudioService>(mockAudioService);

    // Default mock behaviors
    when(() => mockAudioService.initialize()).thenAnswer((_) async {});
    when(() => mockAudioService.stopAll()).thenAnswer((_) async {});
    when(() => mockAudioService.speakText(any())).thenAnswer((_) async {});
    when(() => mockAudioService.stopTTS()).thenAnswer((_) async {});

    when(() => mockRepository.initialize()).thenAnswer((_) async {});
    when(() => mockRepository.getProgress()).thenAnswer((_) async => const MeditationProgress());
  });

  tearDown(() {
    di.getIt.unregister<MeditationRepository>();
    di.getIt.unregister<AudioService>();
  });

  group('Meditation Flow - True E2E Tests', () {
    final testScript = MeditationScript(
      id: 'test-01',
      title: 'Prueba E2E',
      category: MeditationCategory.calm,
      durationMinutes: 1,
      steps: [
        'Paso Uno: Respira',
        'Paso Dos: Relájate',
        'Paso Tres: Sonríe',
      ],
    );

    testWidgets('E2E: Meditation Welcome and Success Flow', (WidgetTester tester) async {
      when(() => mockRepository.recommendScript(memoryHints: any(named: 'memoryHints')))
          .thenAnswer((_) async => testScript);

      when(() => mockRepository.startSession(any())).thenAnswer((_) async => MeditationSession(
        id: 'session-123',
        scriptId: testScript.id,
        category: testScript.category,
        startedAt: DateTime.now(),
      ));

      when(() => mockRepository.completeSession(
        session: any(named: 'session'),
        elapsedSeconds: any(named: 'elapsedSeconds'),
        completedSteps: any(named: 'completedSteps'),
      )).thenAnswer((_) async {});

      await tester.pumpWidget(const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MeditationPage(),
      ));

      // 1. Welcome View
      await tester.pumpAndSettle();
      expect(find.text('Meditación Guiada'), findsOneWidget);
      expect(find.text('Prueba E2E'), findsOneWidget);
      expect(find.text('Comenzar'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'meditation', '01_welcome');

      // 2. Start Session
      await tester.tap(find.text('Comenzar'));
      await tester.pumpAndSettle();

      verify(() => mockRepository.startSession(testScript)).called(1);
      expect(find.text('Inhala / Exhala'), findsOneWidget);
      expect(find.text('Paso Uno: Respira'), findsOneWidget);
      expect(find.text('Paso 1 de 3'), findsOneWidget);
      verify(() => mockAudioService.speakText('Paso Uno: Respira')).called(1);
      await VideoRecorder.recordStep(tester, 'meditation', '02_active_step1');

      // 3. Pause / Resume
      final pauseBtn = find.byIcon(Icons.pause);
      await tester.tap(pauseBtn);
      await tester.pumpAndSettle();
      expect(find.text('Pausado'), findsOneWidget);
      verify(() => mockAudioService.stopTTS()).called(1);
      await VideoRecorder.recordStep(tester, 'meditation', '03_paused');

      final playBtn = find.byIcon(Icons.play_arrow);
      await tester.tap(playBtn);
      await tester.pumpAndSettle();
      expect(find.text('Inhala / Exhala'), findsOneWidget);
      verify(() => mockAudioService.speakText('Paso Uno: Respira')).called(2);

      // 4. Next Step
      final nextBtn = find.byIcon(Icons.skip_next);
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();
      expect(find.text('Paso Dos: Relájate'), findsOneWidget);
      expect(find.text('Paso 2 de 3'), findsOneWidget);
      verify(() => mockAudioService.speakText('Paso Dos: Relájate')).called(1);
      await VideoRecorder.recordStep(tester, 'meditation', '04_active_step2');

      // 5. Previous Step
      final prevBtn = find.byIcon(Icons.skip_previous);
      await tester.tap(prevBtn);
      await tester.pumpAndSettle();
      expect(find.text('Paso Uno: Respira'), findsOneWidget);
      expect(find.text('Paso 1 de 3'), findsOneWidget);

      // 6. Complete Flow
      await tester.tap(nextBtn); // Back to step 2
      await tester.pumpAndSettle();
      await tester.tap(nextBtn); // To step 3
      await tester.pumpAndSettle();
      expect(find.text('Paso Tres: Sonríe'), findsOneWidget);
      expect(find.text('Paso 3 de 3'), findsOneWidget);

      await tester.tap(nextBtn); // Finish
      await tester.pumpAndSettle();

      expect(find.text('Sesión Completada'), findsOneWidget);
      verify(() => mockRepository.completeSession(
        session: any(named: 'session'),
        elapsedSeconds: any(named: 'elapsedSeconds'),
        completedSteps: 3,
      )).called(1);
      verify(() => mockAudioService.speakText('La meditación ha terminado.')).called(1);
      await VideoRecorder.recordStep(tester, 'meditation', '05_completed');

      // 7. Return home
      await tester.tap(find.text('Volver al inicio'));
      await tester.pumpAndSettle();
    });

    testWidgets('E2E: Meditation Error State', (WidgetTester tester) async {
      const errorMessage = 'Error al cargar guion';
      when(() => mockRepository.recommendScript(memoryHints: any(named: 'memoryHints')))
          .thenThrow(Exception(errorMessage));

      await tester.pumpWidget(const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MeditationPage(),
      ));

      await tester.pumpAndSettle();
      expect(find.textContaining(errorMessage), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'meditation', '06_error');
    });
  });
}
