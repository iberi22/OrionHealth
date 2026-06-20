import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/meditation/application/meditation_state.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_category.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_progress.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_script.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_session.dart';

void main() {
  group('MeditationState', () {
    test('supports value equality', () {
      expect(
        const MeditationState(),
        equals(const MeditationState()),
      );
    });

    test('copyWith works correctly', () {
      const state = MeditationState();
      final script = MeditationScript(
        id: '1',
        title: 'Title',
        category: MeditationCategory.calm,
        durationMinutes: 5,
        steps: ['Step'],
      );
      final session = MeditationSession(
        id: 's1',
        scriptId: '1',
        category: MeditationCategory.calm,
        startedAt: DateTime(2025, 1, 1),
      );
      const progress = MeditationProgress(totalSessions: 1);

      final newState = state.copyWith(
        status: MeditationStatus.playing,
        script: script,
        session: session,
        progress: progress,
        steps: ['Step'],
        currentStep: 1,
        elapsedSeconds: 30,
        error: 'error',
      );

      expect(newState.status, MeditationStatus.playing);
      expect(newState.script, script);
      expect(newState.session, session);
      expect(newState.progress, progress);
      expect(newState.steps, ['Step']);
      expect(newState.currentStep, 1);
      expect(newState.elapsedSeconds, 30);
      expect(newState.error, 'error');
    });

    test('props contains all fields', () {
      final state = MeditationState(
        status: MeditationStatus.idle,
        error: 'err',
      );

      expect(state.props, containsAll([
        MeditationStatus.idle,
        'err',
      ]));
    });
  });
}
