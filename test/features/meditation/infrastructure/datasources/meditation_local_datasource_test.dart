import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_category.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_preferences.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_session.dart';
import 'package:orionhealth_health/features/meditation/infrastructure/datasources/meditation_local_datasource.dart';

void main() {
  late MeditationLocalDataSource dataSource;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    dataSource = MeditationLocalDataSource();
  });

  const tPrefs = MeditationPreferences(
    preferredCategory: MeditationCategory.sleep,
    preferredDurationMinutes: 15,
    ttsEnabled: false,
    lastScriptId: 'sleep-01',
  );

  final tSession = MeditationSession(
    id: 'session-1',
    scriptId: 'calm-01',
    category: MeditationCategory.calm,
    startedAt: DateTime(2025, 1, 1),
    completed: true,
    elapsedSeconds: 300,
    completedSteps: 5,
  );

  group('preferences', () {
    test('should return null when no preferences are saved', () async {
      final result = await dataSource.getPreferences();
      expect(result, isNull);
    });

    test('should save and retrieve preferences', () async {
      await dataSource.savePreferences(tPrefs);
      final result = await dataSource.getPreferences();
      expect(result, tPrefs);
    });

    test('should overwrite preferences', () async {
      await dataSource.savePreferences(tPrefs);
      final newPrefs = tPrefs.copyWith(preferredDurationMinutes: 20);
      await dataSource.savePreferences(newPrefs);
      final result = await dataSource.getPreferences();
      expect(result?.preferredDurationMinutes, 20);
    });
  });

  group('history', () {
    test('should return empty list when no history is saved', () async {
      final result = await dataSource.getHistory();
      expect(result, isEmpty);
    });

    test('should save and retrieve history', () async {
      final history = [tSession];
      await dataSource.saveHistory(history);
      final result = await dataSource.getHistory();

      expect(result, hasLength(1));
      expect(result.first.id, tSession.id);
      expect(result.first.scriptId, tSession.scriptId);
      expect(result.first.completed, tSession.completed);
    });
  });
}
