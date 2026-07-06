// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/home_module.dart';
import '../../domain/repositories/home_data_source.dart';
import '../models/home_module_model.dart';

@injectable
class HomeLocalDataSource implements HomeDataSource {
  final SharedPreferences _prefs;
  static const String _modulesKey = 'home_modules_cache';
  static const String _summaryKey = 'home_summary_cache';

  HomeLocalDataSource(this._prefs);

  Future<void> cacheHomeModules(List<HomeModuleModel> modules) async {
    final modulesJson = modules.map((m) => m.toJson()).toList();
    await _prefs.setString(_modulesKey, jsonEncode(modulesJson));
  }

  @override
  Future<List<HomeModule>> getHomeModules() async {
    final modulesJson = _prefs.getString(_modulesKey);
    if (modulesJson == null) return [];

    final List<dynamic> decoded = jsonDecode(modulesJson);
    return decoded.map((m) => HomeModuleModel.fromJson(m)).toList();
  }

  Future<void> cacheHealthSummary(String summary) async {
    await _prefs.setString(_summaryKey, summary);
  }

  @override
  Future<String> getHealthSummary() async {
    return _prefs.getString(_summaryKey) ?? '';
  }
}
