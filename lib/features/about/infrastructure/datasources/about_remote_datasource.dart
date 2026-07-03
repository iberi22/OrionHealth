// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/config/environment.dart';
import '../../../../core/services/app_logger.dart';

/// Remote datasource for fetching about content from a server.
///
/// This datasource fetches mission, terms, privacy policy and other
/// "about" related info from a CMS/backend endpoint.
@lazySingleton
class AboutRemoteDataSource {
  final Dio _dio;
  final String _baseUrl;

  AboutRemoteDataSource(this._dio)
      : _baseUrl = '${AppEnvironment.current.cmsBaseUrl}/api/about';

  /// Helper to extract text from various response formats (string or map).
  String? _extractText(dynamic data) {
    if (data == null) return null;
    if (data is String) return data;
    if (data is Map<String, dynamic>) {
      final text = data['content'] ?? data['text'] ?? data['value'];
      if (text != null) return text.toString();
    }
    return data.toString();
  }

  /// Fetch Terms and Conditions from the CMS.
  Future<String?> getTermsAndConditions() async {
    try {
      final response = await _dio.get('$_baseUrl/terms');
      if (response.statusCode == 200) {
        return _extractText(response.data);
      }
      return null;
    } catch (e) {
      AppLogger.e('AboutRemoteDataSource', 'Failed to fetch terms', error: e);
      return null;
    }
  }

  /// Fetch Privacy Policy from the CMS.
  Future<String?> getPrivacyPolicy() async {
    try {
      final response = await _dio.get('$_baseUrl/privacy');
      if (response.statusCode == 200) {
        return _extractText(response.data);
      }
      return null;
    } catch (e) {
      AppLogger.e('AboutRemoteDataSource', 'Failed to fetch privacy policy', error: e);
      return null;
    }
  }

  /// Fetch the general "about" content for the application.
  Future<Map<String, dynamic>?> getAboutInfo() async {
    try {
      final response = await _dio.get('$_baseUrl/content');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      AppLogger.e('AboutRemoteDataSource', 'Failed to fetch about content', error: e);
      return null;
    }
  }

  /// Fetch latest blog posts from the backend.
  /// Returns null if not reachable (graceful fallback to local datasource).
  Future<List<Map<String, dynamic>>?> fetchLatestBlogPosts() async {
    try {
      final response = await _dio.get('$_baseUrl/blog-posts');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data as List);
      }
      return null;
    } catch (e) {
      AppLogger.e('AboutRemoteDataSource', 'Failed to fetch blog posts', error: e);
      return null;
    }
  }

  /// Fetch the current application version from the remote server.
  Future<String?> fetchAppVersion() async {
    try {
      final response = await _dio.get('$_baseUrl/version');
      if (response.statusCode == 200) {
        if (response.data is Map) {
          return response.data['version']?.toString();
        }
        return response.data?.toString();
      }
      return null;
    } catch (e) {
      AppLogger.e('AboutRemoteDataSource', 'Failed to fetch app version', error: e);
      return null;
    }
  }

  /// Legacy alias for getAboutInfo.
  Future<Map<String, dynamic>?> fetchAboutContent() => getAboutInfo();
}
