import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class ResearchLocalDataSource {
  static const String _cacheKey = 'medical_research_cache';

  Future<void> cacheResult(String query, String result) async {
    final prefs = await SharedPreferences.getInstance();
    final cache = jsonDecode(prefs.getString(_cacheKey) ?? '{}') as Map<String, dynamic>;
    cache[query] = result;
    await prefs.setString(_cacheKey, jsonEncode(cache));
  }

  Future<String?> getCachedResult(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final cache = jsonDecode(prefs.getString(_cacheKey) ?? '{}') as Map<String, dynamic>;
    return cache[query] as String?;
  }
}
