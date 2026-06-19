import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_category.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_progress.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_session.dart';

void main() {
  group('MeditationProgress', () {
    test('creates with defaults', () {
      const progress = MeditationProgress();

      expect(progress.totalSessions, 0);
      expect(progress.completedSessions, 0);
      expect(progress.totalCompletedSeconds, 0);
      expect(progress.lastSession, isNull);
    });

    test('supports value equality', () {
      final session = MeditationSession(
        id: 's1',
        scriptId: '1',
        category: MeditationCategory.calm,
        startedAt: DateTime(2025, 1, 1),
      );

      expect(
        MeditationProgress(
          totalSessions: 1,
          completedSessions: 1,
          totalCompletedSeconds: 300,
          lastSession: session,
        ),
        equals(MeditationProgress(
          totalSessions: 1,
          completedSessions: 1,
          totalCompletedSeconds: 300,
          lastSession: session,
        )),
      );
    });

    test('creates with custom values', () {
      final session = MeditationSession(
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
