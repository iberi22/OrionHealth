// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:injectable/injectable.dart';
import '../../domain/entities/home_module.dart';
import '../../domain/repositories/home_data_source.dart';
import '../models/home_module_model.dart';

@injectable
class HomeRemoteDataSource implements HomeDataSource {
  HomeRemoteDataSource();

  @override
  Future<List<HomeModule>> getHomeModules() async {
    // This would normally call an API endpoint.
    // For now, we'll return an empty list or mock data.
    return [];
  }

  @override
  Future<String> getHealthSummary() async {
    // This would normally call an API endpoint.
    return 'Resumen remoto: Signos estables.';
  }
}
