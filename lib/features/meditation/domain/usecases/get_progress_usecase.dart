// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:injectable/injectable.dart';
import '../entities/meditation_progress.dart';
import '../repositories/meditation_repository.dart';

@lazySingleton
class GetProgressUseCase {
  final MeditationRepository _repository;

  GetProgressUseCase(this._repository);

  Future<MeditationProgress> call() async {
    await _repository.initialize();
    return _repository.getProgress();
  }
}
