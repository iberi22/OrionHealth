// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import '../entities/meditation_category.dart';
import '../entities/meditation_preferences.dart';
import '../entities/meditation_progress.dart';
import '../entities/meditation_script.dart';
import '../entities/meditation_session.dart';

abstract class MeditationRepository {
  Future<void> initialize();
  List<MeditationScript> get scripts;
  MeditationPreferences get preferences;
  List<MeditationSession> get history;
  MeditationScript? getScript(String id);
  List<MeditationScript> scriptsByCategory(MeditationCategory category);
  Future<MeditationScript> recommendScript({List<String>? memoryHints});
  Future<MeditationSession> startSession(MeditationScript script);
  Future<void> completeSession({
    required MeditationSession session,
    required int elapsedSeconds,
    required int completedSteps,
  });
  Future<MeditationProgress> getProgress();
  Future<void> updatePreferences(MeditationPreferences prefs);
}
