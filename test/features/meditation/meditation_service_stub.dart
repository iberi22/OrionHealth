/// Stub service classes for testing meditation_screen.dart
/// These are minimal implementations that satisfy the type system
/// so the screen can be constructed in widget tests.

import 'package:orionhealth_health/features/meditation/meditation_models.dart';

/// Stub for MeditationService used by meditation_screen.dart
class MeditationService {
  List<MeditationScript> scripts = [];

  Future<void> initialize() async {}

  Future<MeditationScript> recommendScript({List<String>? memoryHints}) async {
    return scripts.isNotEmpty ? scripts.first : _defaultScript();
  }

  Future<MeditationProgress> getProgress() async {
    return const MeditationProgress();
  }

  Future<MeditationSessionRecord> startSession(MeditationScript script) async {
    return MeditationSessionRecord(
      id: 'test-session',
      scriptId: script.id,
      category: script.category,
      startedAt: DateTime.now(),
    );
  }

  Future<void> completeSession({
    required MeditationSessionRecord session,
    required int elapsedSeconds,
    required int completedSteps,
  }) async {}

  MeditationScript _defaultScript() {
    return const MeditationScript(
      id: 'default',
      title: 'Test Meditation',
      category: MeditationCategory.calm,
      durationMinutes: 5,
      steps: ['Step 1', 'Step 2'],
    );
  }
}
