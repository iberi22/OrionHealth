// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:equatable/equatable.dart';
import '../domain/entities/meditation_progress.dart';
import '../domain/entities/meditation_script.dart';
import '../domain/entities/meditation_session.dart';

enum MeditationStatus { initial, loading, idle, playing, paused, completed, error }

class MeditationState extends Equatable {
  final MeditationStatus status;
  final MeditationScript? script;
  final MeditationSession? session;
  final MeditationProgress progress;
  final List<String> steps;
  final int currentStep;
  final int elapsedSeconds;
  final String? error;

  const MeditationState({
    this.status = MeditationStatus.initial,
    this.script,
    this.session,
    this.progress = const MeditationProgress(),
    this.steps = const [],
    this.currentStep = 0,
    this.elapsedSeconds = 0,
    this.error,
  });

  MeditationState copyWith({
    MeditationStatus? status,
    MeditationScript? script,
    MeditationSession? session,
    MeditationProgress? progress,
    List<String>? steps,
    int? currentStep,
    int? elapsedSeconds,
    String? error,
  }) {
    return MeditationState(
      status: status ?? this.status,
      script: script ?? this.script,
      session: session ?? this.session,
      progress: progress ?? this.progress,
      steps: steps ?? this.steps,
      currentStep: currentStep ?? this.currentStep,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        script,
        session,
        progress,
        steps,
        currentStep,
        elapsedSeconds,
        error,
      ];
}
