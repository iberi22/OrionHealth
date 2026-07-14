// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

/// Country detection service via IP geolocation.
///
/// Uses a lightweight IP geolocation API to determine the user's country.
/// EPS features are only relevant for Colombian users (CO).
///
/// Privacy: Only the country code is sent to the service; no personal data.
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CountryDetector {
  static const _cacheKey = 'detected_country_code';
  static const _cacheTimeKey = 'detected_country_time';
  static const _cacheTtl = Duration(hours: 24);

  final http.Client _client;

  CountryDetector({http.Client? client}) : _client = client ?? http.Client();

  /// Detects the user's country code (ISO 3166-1 alpha-2) via IP geolocation.
  ///
  /// Uses ipapi.co (free tier, no API key needed for basic usage).
  /// Falls back to cached value if network fails.
  ///
  /// Returns null if detection fails entirely.
  Future<String?> detectCountry() async {
    // 1. Check cache first
    final cached = await _getCachedCountry();
    if (cached != null) return cached;

    // 2. Try primary service (ipapi.co)
    try {
      final code = await _tryIpApi();
      if (code != null) {
        await _cacheCountry(code);
        return code;
      }
    } catch (_) {
      // Fall through to backup
    }

    // 3. Try backup (ip-api.com)
    try {
      final code = await _tryIpApiCom();
      if (code != null) {
        await _cacheCountry(code);
        return code;
      }
    } catch (_) {
      // Fall through to final
    }

    // 4. Last resort: try third service
    try {
      final code = await _tryIpinfo();
      if (code != null) {
        await _cacheCountry(code);
        return code;
      }
    } catch (_) {
      // Failed
    }

    return null;
  }

  /// Whether the user is in Colombia.
  Future<bool> isColombia() async {
    final country = await detectCountry();
    return country?.toUpperCase() == 'CO';
  }

  // ─── Private providers ─────────────────────────────────────

  Future<String?> _tryIpApi() async {
    final response = await _client
        .get(Uri.parse('https://ipapi.co/json/'))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final code = data['country_code'] as String?;
      return code?.trim().toUpperCase();
    }
    return null;
  }

  Future<String?> _tryIpApiCom() async {
    final response = await _client
        .get(Uri.parse('http://ip-api.com/json/?fields=countryCode'))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final code = data['countryCode'] as String?;
      return code?.trim().toUpperCase();
    }
    return null;
  }

  Future<String?> _tryIpinfo() async {
    final response = await _client
        .get(Uri.parse('https://ipinfo.io/json'))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final code = data['country'] as String?;
      return code?.trim().toUpperCase();
    }
    return null;
  }

  // ─── Cache ────────────────────────────────────────────────

  Future<void> _cacheCountry(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, code);
    await prefs.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<String?> _getCachedCountry() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_cacheKey);
    final time = prefs.getInt(_cacheTimeKey);
    if (code != null && time != null) {
      final age = DateTime.now().millisecondsSinceEpoch - time;
      if (age < _cacheTtl.inMilliseconds) {
        return code;
      }
    }
    return null;
  }

  void dispose() {
    _client.close();
  }
}
