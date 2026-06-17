// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:injectable/injectable.dart';
import '../entities/home_health_summary.dart';
import '../repositories/home_repository.dart';

@injectable
class GetHealthSummaryUseCase {
  final HomeRepository repository;

  GetHealthSummaryUseCase(this.repository);

  Future<HomeHealthSummary> call() async {
    return repository.getHealthSummary();
  }
}
