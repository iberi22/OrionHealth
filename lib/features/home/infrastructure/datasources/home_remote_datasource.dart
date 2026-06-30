// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:injectable/injectable.dart';
import '../models/home_module_model.dart';

@injectable
class HomeRemoteDataSource {
  HomeRemoteDataSource();

  Future<List<HomeModuleModel>> getHomeModules() async {
    // This would normally call an API endpoint.
    // For now, we'll return the default modules as Models.
    // In a real implementation:
    // final response = await _dio.get('/home/modules');
    // return (response.data as List).map((m) => HomeModuleModel.fromJson(m)).toList();

    return [];
  }
}
