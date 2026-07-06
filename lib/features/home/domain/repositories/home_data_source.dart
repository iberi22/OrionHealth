// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import '../entities/home_module.dart';

abstract class HomeDataSource {
  Future<List<HomeModule>> getHomeModules();
  Future<String> getHealthSummary();
}
