// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:injectable/injectable.dart';
import '../entities/meditation_session.dart';
import '../repositories/meditation_repository.dart';

@lazySingleton
class CompleteSessionUseCase {
  final MeditationRepository _repository;

  CompleteSessionUseCase(this._repository);

  Future<void> call({
    required MeditationSession session,
    required int elapsedSeconds,
    required int completedSteps,
  }) async {
    await _repository.completeSession(
      session: session,
      elapsedSeconds: elapsedSeconds,
      completedSteps: completedSteps,
    );
  }
}
