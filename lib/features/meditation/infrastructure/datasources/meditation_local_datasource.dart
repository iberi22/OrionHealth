// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/meditation_preferences.dart';
import '../../domain/entities/meditation_session.dart';

@lazySingleton
class MeditationLocalDataSource {
  static const String _prefsKey = 'meditation_preferences';
  static const String _historyKey = 'meditation_history';

  Future<void> savePreferences(MeditationPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(preferences.toJson()));
  }

  Future<MeditationPreferences?> getPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_prefsKey);
    if (json == null) return null;
    return MeditationPreferences.fromJson(jsonDecode(json));
  }

  Future<void> saveHistory(List<MeditationSession> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _historyKey,
      jsonEncode(history.map((s) => s.toJson()).toList()),
    );
  }

  Future<List<MeditationSession>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_historyKey);
    if (json == null) return [];
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map((e) => MeditationSession.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
