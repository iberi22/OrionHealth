// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/home_module.dart';
import '../../domain/repositories/home_data_source.dart';
import '../models/home_module_model.dart';

@injectable
class HomeRemoteDataSource implements HomeDataSource {
  final Dio _dio;
  static const String _baseUrl = 'https://api.orionhealth.ai/home';

  HomeRemoteDataSource(this._dio);

  @override
  Future<List<HomeModule>> getHomeModules() async {
    try {
      final response = await _dio.get('$_baseUrl/modules');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => HomeModuleModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<String> getHealthSummary() async {
    try {
      final response = await _dio.get('$_baseUrl/summary');
      if (response.statusCode == 200) {
        return response.data['summary'] ?? 'Resumen remoto: Signos estables.';
      }
      return 'Error al obtener resumen remoto.';
    } catch (e) {
      return 'Error de conexión al obtener resumen remoto.';
    }
  }
}
