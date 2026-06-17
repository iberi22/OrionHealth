// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import '../entities/home_health_summary.dart';
import '../entities/home_module.dart';

abstract class HomeRepository {
  Future<HomeHealthSummary> getHealthSummary();
  Future<List<HomeModule>> getHomeModules();
}
