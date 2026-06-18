import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_category.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_preferences.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_script.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_session.dart';
import 'package:orionhealth_health/features/meditation/infrastructure/datasources/meditation_local_datasource.dart';
import 'package:orionhealth_health/features/meditation/infrastructure/repositories/meditation_repository_impl.dart';

class MockMeditationLocalDataSource extends Mock implements MeditationLocalDataSource {}

class FakeMeditationPreferences extends Fake implements MeditationPreferences {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeMeditationPreferences());
  });

  late MeditationRepositoryImpl repository;
  late MockMeditationLocalDataSource mockLocalDataSource;

  setUp(() {
    mockLocalDataSource = MockMeditationLocalDataSource();
    repository = MeditationRepositoryImpl(mockLocalDataSource);
  });

  const tPrefs = MeditationPreferences(
    preferredCategory: MeditationCategory.sleep,
    preferredDurationMinutes: 10,
  );

  final tHistory = [
    MeditationSession(
      id: '1',
      scriptId: 'calm-01',
      category: MeditationCategory.calm,
      startedAt: DateTime(2025, 1, 1),
      completed: true,
      elapsedSeconds: 300,
    ),
  ];

  group('initialize', () {
    test('should load preferences and history from data source', () async {
      when(() => mockLocalDataSource.getPreferences()).thenAnswer((_) async => tPrefs);
      when(() => mockLocalDataSource.getHistory()).thenAnswer((_) async => tHistory);

      await repository.initialize();

      expect(repository.preferences, tPrefs);
      expect(repository.history, tHistory);
      expect(repository.scripts.isNotEmpty, isTrue);
      verify(() => mockLocalDataSource.getPreferences()).called(1);
      verify(() => mockLocalDataSource.getHistory()).called(1);
    });

    test('should use default preferences if none found', () async {
      when(() => mockLocalDataSource.getPreferences()).thenAnswer((_) async => null);
      when(() => mockLocalDataSource.getHistory()).thenAnswer((_) async => []);

      await repository.initialize();

      expect(repository.preferences, const MeditationPreferences());
      expect(repository.history, isEmpty);
    });
  });

  group('recommendScript', () {
    setUp(() async {
      when(() => mockLocalDataSource.getPreferences()).thenAnswer((_) async => tPrefs);
      when(() => mockLocalDataSource.getHistory()).thenAnswer((_) async => []);
      await repository.initialize();
    });

    test('should return script of preferred category', () async {
      final script = await repository.recommendScript();
      expect(script.category, tPrefs.preferredCategory);
    });

    test('should return last script if lastScriptId is set', () async {
      when(() => mockLocalDataSource.savePreferences(any())).thenAnswer((_) async => {});
      final prefsWithLast = tPrefs.copyWith(lastScriptId: 'focus-01');
      await repository.updatePreferences(prefsWithLast);

      final script = await repository.recommendScript();
      expect(script.id, 'focus-01');
    });
  });

  group('session management', () {
    setUp(() async {
      when(() => mockLocalDataSource.getPreferences()).thenAnswer((_) async => tPrefs);
      when(() => mockLocalDataSource.getHistory()).thenAnswer((_) async => []);
      when(() => mockLocalDataSource.savePreferences(any())).thenAnswer((_) async => {});
      when(() => mockLocalDataSource.saveHistory(any())).thenAnswer((_) async => {});
      await repository.initialize();
    });

    test('startSession should create session and update lastScriptId', () async {
      final script = repository.scripts.first;
      final session = await repository.startSession(script);

      expect(session.scriptId, script.id);
      expect(repository.preferences.lastScriptId, script.id);
      verify(() => mockLocalDataSource.savePreferences(any())).called(1);
    });

    test('completeSession should add to history and save', () async {
      final script = repository.scripts.first;
      final session = await repository.startSession(script);

      await repository.completeSession(
        session: session,
        elapsedSeconds: 300,
        completedSteps: 5,
      );

      expect(repository.history.length, 1);
      expect(repository.history.first.completed, isTrue);
      expect(repository.history.first.elapsedSeconds, 300);
      verify(() => mockLocalDataSource.saveHistory(any())).called(1);
    });
  });

  group('getProgress', () {
    test('should calculate progress correctly', () async {
      when(() => mockLocalDataSource.getPreferences()).thenAnswer((_) async => tPrefs);
      when(() => mockLocalDataSource.getHistory()).thenAnswer((_) async => tHistory);
      await repository.initialize();

      final progress = await repository.getProgress();

      expect(progress.totalSessions, 1);
      expect(progress.completedSessions, 1);
      expect(progress.totalCompletedSeconds, 300);
      expect(progress.lastSession, tHistory.first);
    });
  });
}
