// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:equatable/equatable.dart';
import 'meditation_session.dart';

class MeditationProgress extends Equatable {
  final int totalSessions;
  final int completedSessions;
  final int totalCompletedSeconds;
  final MeditationSession? lastSession;

  const MeditationProgress({
    this.totalSessions = 0,
    this.completedSessions = 0,
    this.totalCompletedSeconds = 0,
    this.lastSession,
  });

  @override
  List<Object?> get props =>
      [totalSessions, completedSessions, totalCompletedSeconds, lastSession];
}
