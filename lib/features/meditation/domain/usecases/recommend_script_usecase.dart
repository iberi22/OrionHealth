// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:injectable/injectable.dart';
import '../entities/meditation_script.dart';
import '../repositories/meditation_repository.dart';

@lazySingleton
class RecommendScriptUseCase {
  final MeditationRepository _repository;

  RecommendScriptUseCase(this._repository);

  Future<MeditationScript> call({List<String>? memoryHints}) async {
    await _repository.initialize();
    return _repository.recommendScript(memoryHints: memoryHints);
  }
}
