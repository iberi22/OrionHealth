import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_category.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_session.dart';

void main() {
  group('MeditationSession', () {
    final now = DateTime(2026, 6, 15, 19, 0, 0);

    test('creates with required fields', () {
      final record = MeditationSession(
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

    test('supports value equality', () {
      final session1 = MeditationSession(
        id: '1',
        scriptId: 's1',
        category: MeditationCategory.calm,
        startedAt: now,
      );
      final session2 = MeditationSession(
        id: '1',
        scriptId: 's1',
        category: MeditationCategory.calm,
        startedAt: now,
      );

      expect(session1, equals(session2));
    });

    test('toJson and fromJson roundtrip', () {
      final record = MeditationSession(
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
      final restored = MeditationSession.fromJson(json);

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

      final restored = MeditationSession.fromJson(json);
      expect(restored.completedAt, isNull);
      expect(restored.elapsedSeconds, 0);
      expect(restored.completedSteps, 0);
      expect(restored.completed, isFalse);
    });
  });
}
