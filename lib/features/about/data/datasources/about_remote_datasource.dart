// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/config/environment.dart';

/// Remote datasource for fetching about content from a server.
///
/// Currently a placeholder for future remote about/landing page API.
/// When implemented, this will fetch mission, blog posts, and news
/// from a CMS/backend endpoint.
@lazySingleton
class AboutRemoteDataSource {
  final Dio _dio;
  final String _baseUrl;

  AboutRemoteDataSource(this._dio)
      : _baseUrl = '${AppEnvironment.current.cmsBaseUrl}/api/about';

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
      return null;
    }
  }

  /// Fetch the current application version from the remote server.
  Future<String?> fetchAppVersion() async {
    try {
      final response = await _dio.get('$_baseUrl/version');
      if (response.statusCode == 200) {
        return response.data['version'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Fetch the general "about" content for the application.
  Future<Map<String, dynamic>?> fetchAboutContent() async {
    try {
      final response = await _dio.get('$_baseUrl/content');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
