// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:injectable/injectable.dart';
import '../entities/meditation_script.dart';
import '../repositories/meditation_repository.dart';

@lazySingleton
class GetScriptsUseCase {
  final MeditationRepository _repository;

  GetScriptsUseCase(this._repository);

  Future<List<MeditationScript>> call() async {
    await _repository.initialize();
    return _repository.scripts;
  }
}
