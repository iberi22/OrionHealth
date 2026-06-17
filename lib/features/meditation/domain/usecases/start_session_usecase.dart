// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:injectable/injectable.dart';
import '../entities/meditation_script.dart';
import '../entities/meditation_session.dart';
import '../repositories/meditation_repository.dart';

@lazySingleton
class StartSessionUseCase {
  final MeditationRepository _repository;

  StartSessionUseCase(this._repository);

  Future<MeditationSession> call(MeditationScript script) async {
    return _repository.startSession(script);
  }
}
