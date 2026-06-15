// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:injectable/injectable.dart';

/// Remote datasource for fetching about content from a server.
///
/// Currently a placeholder for future remote about/landing page API.
/// When implemented, this will fetch mission, blog posts, and news
/// from a CMS/backend endpoint.
@lazySingleton
class AboutRemoteDataSource {
  /// Fetch latest blog posts from the backend.
  /// Returns null if not reachable (graceful fallback to local datasource).
  Future<List<Map<String, dynamic>>?> fetchLatestBlogPosts() async {
    // TODO: Implement HTTP call to CMS endpoint
    // e.g. GET /api/about/blog-posts
    return null;
  }
}
