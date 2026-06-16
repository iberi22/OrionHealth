/// Stub widget classes for testing meditation_screen.dart
/// These are minimal implementations that satisfy the type system.

import 'package:flutter/material.dart';
import 'package:orionhealth_health/features/meditation/meditation_models.dart';

/// Stub for MeditationFinishedView
class MeditationFinishedView extends StatelessWidget {
  final int elapsedSeconds;
  final MeditationProgress progress;
  final VoidCallback onRestart;

  const MeditationFinishedView({
    super.key,
    required this.elapsedSeconds,
    required this.progress,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Meditation Finished'));
  }
}

/// Stub for MeditationWelcomeView
class MeditationWelcomeView extends StatelessWidget {
  final MeditationScript? script;
  final MeditationProgress progress;
  final String? error;
  final VoidCallback onStart;

  const MeditationWelcomeView({
    super.key,
    required this.script,
    required this.progress,
    this.error,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Welcome to Meditation'));
  }
}

/// Stub for MeditationActiveView
class MeditationActiveView extends StatelessWidget {
  final List<String> steps;
  final int currentStep;
  final int elapsedSeconds;
  final bool isPaused;
  final Animation<double> breathAnimation;
  final VoidCallback onPrevious;
  final VoidCallback onTogglePause;
  final VoidCallback onNext;

  const MeditationActiveView({
    super.key,
    required this.steps,
    required this.currentStep,
    required this.elapsedSeconds,
    required this.isPaused,
    required this.breathAnimation,
    required this.onPrevious,
    required this.onTogglePause,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Active Meditation'));
  }
}
