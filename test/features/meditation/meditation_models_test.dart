import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/meditation/meditation_models.dart';

void main() {
  group('MeditationCategory', () {
    test('has all expected values', () {
      expect(MeditationCategory.values, hasLength(4));
      expect(
        MeditationCategory.values,
        containsAll([
          MeditationCategory.calm,
          MeditationCategory.focus,
          MeditationCategory.sleep,
          MeditationCategory.breathing,
        ]),
      );
    });

    test('name accessor works', () {
      expect(MeditationCategory.calm.name, 'calm');
      expect(MeditationCategory.focus.name, 'focus');
      expect(MeditationCategory.sleep.name, 'sleep');
      expect(MeditationCategory.breathing.name, 'breathing');
    });
  });

  group('MeditationScript', () {
    const testScript = MeditationScript(
      id: 'breath-01',
      title: 'Respiración Profunda',
      category: MeditationCategory.breathing,
      durationMinutes: 5,
      steps: [
        'Siéntate cómodamente',
        'Inhala profundamente',
        'Exhala lentamente',
      ],
      tags: ['respiración', 'principiante'],
    );

    test('creates with required fields', () {
      expect(testScript.id, 'breath-01');
      expect(testScript.title, 'Respiración Profunda');
      expect(testScript.category, MeditationCategory.breathing);
      expect(testScript.durationMinutes, 5);
      expect(testScript.steps, hasLength(3));
    });

    test('default tags is empty', () {
      const noTags = MeditationScript(
        id: 'test',
        title: 'Test',
        category: MeditationCategory.calm,
        durationMinutes: 3,
        steps: ['Step 1'],
      );
      expect(noTags.tags, isEmpty);
    });

    test('toJson produces correct map', () {
      final json = testScript.toJson();

      expect(json['id'], 'breath-01');
      expect(json['title'], 'Respiración Profunda');
      expect(json['category'], 'breathing');
      expect(json['durationMinutes'], 5);
      expect(json['steps'], isA<List>());
      expect(json['steps'], hasLength(3));
      expect(json['tags'], hasLength(2));
    });

    test('fromJson reconstructs correctly', () {
      final json = testScript.toJson();
      final restored = MeditationScript.fromJson(json);

      expect(restored.id, testScript.id);
      expect(restored.title, testScript.title);
      expect(restored.category, testScript.category);
      expect(restored.durationMinutes, testScript.durationMinutes);
      expect(restored.steps, testScript.steps);
      expect(restored.tags, testScript.tags);
    });

    test('fromJson handles missing tags', () {
      final json = {
        'id': 'simple',
        'title': 'Simple',
        'category': 'calm',
        'durationMinutes': 3,
        'steps': ['Step'],
      };
      final restored = MeditationScript.fromJson(json);
      expect(restored.tags, isEmpty);
    });
  });

  group('MeditationPreferences', () {
    test('creates with defaults', () {
      const prefs = MeditationPreferences();

      expect(prefs.preferredCategory, MeditationCategory.calm);
      expect(prefs.preferredDurationMinutes, 5);
      expect(prefs.ttsEnabled, isTrue);
      expect(prefs.lastScriptId, isNull);
    });

    test('copyWith overrides specified fields', () {
      const prefs = MeditationPreferences();
      final modified = prefs.copyWith(
        preferredCategory: MeditationCategory.sleep,
        preferredDurationMinutes: 10,
        ttsEnabled: false,
        lastScriptId: 'sleep-01',
      );

      expect(modified.preferredCategory, MeditationCategory.sleep);
      expect(modified.preferredDurationMinutes, 10);
      expect(modified.ttsEnabled, isFalse);
      expect(modified.lastScriptId, 'sleep-01');
      // Original unchanged
      expect(prefs.preferredCategory, MeditationCategory.calm);
    });

    test('toJson and fromJson roundtrip', () {
      const prefs = MeditationPreferences(
        preferredCategory: MeditationCategory.focus,
        preferredDurationMinutes: 15,
        ttsEnabled: true,
        lastScriptId: 'focus-03',
      );

      final json = prefs.toJson();
      final restored = MeditationPreferences.fromJson(json);

      expect(restored.preferredCategory, prefs.preferredCategory);
      expect(restored.preferredDurationMinutes, prefs.preferredDurationMinutes);
      expect(restored.ttsEnabled, prefs.ttsEnabled);
      expect(restored.lastScriptId, prefs.lastScriptId);
    });

    test('fromJson uses defaults for missing fields', () {
      final json = <String, dynamic>{};
      final restored = MeditationPreferences.fromJson(json);

      expect(restored.preferredCategory, MeditationCategory.calm);
      expect(restored.preferredDurationMinutes, 5);
      expect(restored.ttsEnabled, isTrue);
      expect(restored.lastScriptId, isNull);
    });
  });

  group('MeditationSessionRecord', () {
    final now = DateTime(2026, 6, 15, 19, 0, 0);

    test('creates with required fields', () {
      final record = MeditationSessionRecord(
        id: 'session-1',
        scriptId: 'breath-01',
        category: MeditationCategory.breathing,
        startedAt: now,
      );

      expect(record.id, 'session-1');
      expect(record.scriptId, 'breath-01');
      expect(record.category, MeditationCategory.breathing);
      expect(record.startedAt, now);
      expect(record.completedAt, isNull);
      expect(record.elapsedSeconds, 0);
      expect(record.completedSteps, 0);
      expect(record.completed, isFalse);
    });

    test('toJson and fromJson roundtrip', () {
      final record = MeditationSessionRecord(
        id: 'session-2',
        scriptId: 'calm-01',
        category: MeditationCategory.calm,
        startedAt: now,
        completedAt: now.add(const Duration(minutes: 5)),
        elapsedSeconds: 300,
        completedSteps: 3,
        completed: true,
      );

      final json = record.toJson();
      final restored = MeditationSessionRecord.fromJson(json);

      expect(restored.id, record.id);
      expect(restored.scriptId, record.scriptId);
      expect(restored.category, record.category);
      expect(restored.startedAt, record.startedAt);
      expect(restored.completedAt, record.completedAt);
      expect(restored.elapsedSeconds, record.elapsedSeconds);
      expect(restored.completedSteps, record.completedSteps);
      expect(restored.completed, record.completed);
    });

    test('fromJson handles null completedAt', () {
      final json = {
        'id': 'session-3',
        'scriptId': 'sleep-02',
        'category': 'sleep',
        'startedAt': now.toIso8601String(),
      };

      final restored = MeditationSessionRecord.fromJson(json);
      expect(restored.completedAt, isNull);
      expect(restored.elapsedSeconds, 0);
      expect(restored.completedSteps, 0);
      expect(restored.completed, isFalse);
    });
  });

  group('MeditationProgress', () {
    test('creates with defaults', () {
      const progress = MeditationProgress();

      expect(progress.totalSessions, 0);
      expect(progress.completedSessions, 0);
      expect(progress.totalCompletedSeconds, 0);
      expect(progress.lastSession, isNull);
    });

    test('creates with custom values', () {
      final session = MeditationSessionRecord(
        id: 's1',
        scriptId: 'calm-01',
        category: MeditationCategory.calm,
        startedAt: DateTime(2026, 6, 15),
        completedAt: DateTime(2026, 6, 15, 0, 5),
        elapsedSeconds: 300,
        completedSteps: 3,
        completed: true,
      );

      final withSession = MeditationProgress(
        totalSessions: 10,
        completedSessions: 7,
        totalCompletedSeconds: 2100,
        lastSession: session,
      );

      expect(withSession.totalSessions, 10);
      expect(withSession.completedSessions, 7);
      expect(withSession.totalCompletedSeconds, 2100);
      expect(withSession.lastSession, session);
    });
  });
}
