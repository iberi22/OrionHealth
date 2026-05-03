// Sync service for downloading and caching full medical standards datasets.
//
// This service handles background synchronization of medical standards
// from GitHub releases or raw file sources. Sync is for UPDATES only —
// AI inference runs entirely from local cached data.
//
// Key insight: AI inference happens locally with full context.
// Sync is for updates, not for runtime.

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Represents the sync state and version of a dataset.
class DatasetVersion {
  final String datasetName;
  final String version;
  final DateTime lastSynced;
  final String sourceUrl;
  final bool isLocal;

  const DatasetVersion({
    required this.datasetName,
    required this.version,
    required this.lastSynced,
    required this.sourceUrl,
    this.isLocal = true,
  });

  Map<String, dynamic> toJson() => {
        'datasetName': datasetName,
        'version': version,
        'lastSynced': lastSynced.toIso8601String(),
        'sourceUrl': sourceUrl,
        'isLocal': isLocal,
      };

  factory DatasetVersion.fromJson(Map<String, dynamic> json) {
    return DatasetVersion(
      datasetName: json['datasetName'] as String,
      version: json['version'] as String,
      lastSynced: DateTime.parse(json['lastSynced'] as String),
      sourceUrl: json['sourceUrl'] as String,
      isLocal: json['isLocal'] as bool? ?? true,
    );
  }
}

/// Result of a sync operation.
class SyncResult {
  final bool success;
  final String datasetName;
  final String? newVersion;
  final String? error;
  final bool wasUpdated;

  const SyncResult({
    required this.success,
    required this.datasetName,
    this.newVersion,
    this.error,
    this.wasUpdated = false,
  });
}

/// Sync service configuration for each dataset.
class SyncConfig {
  final String datasetName;
  final String localFileName;
  final String? githubRepo;
  final String? githubReleaseAsset;
  final String? rawBaseUrl;
  final String version;

  const SyncConfig({
    required this.datasetName,
    required this.localFileName,
    this.githubRepo,
    this.githubReleaseAsset,
    this.rawBaseUrl,
    required this.version,
  });

  String get localPath => 'data/$localFileName';
}

/// Sync service for medical standards datasets.
///
/// Usage:
/// ```dart
/// final sync = SyncService();
/// await sync.syncAll();
/// final versions = sync.getSyncedVersions();
/// ```
class SyncService {
  static const String _versionFileName = '.sync_versions.json';
  static const String _packageName = 'medical_standards';

  /// Datasets managed by this sync service.
  static const List<SyncConfig> datasets = [
    SyncConfig(
      datasetName: 'icd10',
      localFileName: 'full_icd10.json',
      githubRepo: 'iberi22/OrionHealth',
      version: '2024-1',
    ),
    SyncConfig(
      datasetName: 'loinc',
      localFileName: 'full_loinc.json',
      githubRepo: 'iberi22/OrionHealth',
      version: '2.72',
    ),
    SyncConfig(
      datasetName: 'snomed',
      localFileName: 'full_snomed.json',
      githubRepo: 'iberi22/OrionHealth',
      version: '2024-01-31',
    ),
    SyncConfig(
      datasetName: 'rxnorm',
      localFileName: 'full_rxnorm.json',
      githubRepo: 'iberi22/OrionHealth',
      version: '2024-03-04',
    ),
  ];

  /// Cache directory for this package.
  Directory? _cacheDir;

  /// HTTP client for network requests.
  final http.Client _client;

  SyncService({http.Client? client}) : _client = client ?? http.Client();

  /// Get the cache directory for this package.
  Future<Directory> _getCacheDir() async {
    if (_cacheDir != null) return _cacheDir!;

    // Try package-specific cache dir first
    try {
      final appDir = await getApplicationSupportDirectory();
      _cacheDir = Directory(p.join(appDir.path, _packageName, 'standards_cache'));
    } catch (_) {
      // Fallback to temp directory
      _cacheDir = Directory(p.join(
        Directory.systemTemp.path,
        _packageName,
        'standards_cache',
      ));
    }

    if (!await _cacheDir!.exists()) {
      await _cacheDir!.create(recursive: true);
    }

    return _cacheDir!;
  }

  /// Get the version tracking file.
  Future<File> _getVersionFile() async {
    final cacheDir = await _getCacheDir();
    return File(p.join(cacheDir.path, _versionFileName));
  }

  /// Get cached version info for a dataset.
  Future<DatasetVersion?> _getCachedVersion(String datasetName) async {
    try {
      final file = await _getVersionFile();
      if (!await file.exists()) return null;

      final content = await file.readAsString();
      final versions = jsonDecode(content) as Map<String, dynamic>;

      if (versions.containsKey(datasetName)) {
        return DatasetVersion.fromJson(
          versions[datasetName] as Map<String, dynamic>,
        );
      }
    } catch (_) {}
    return null;
  }

  /// Save version info to cache.
  Future<void> _saveVersion(DatasetVersion version) async {
    try {
      final file = await _getVersionFile();
      Map<String, dynamic> versions = {};

      if (await file.exists()) {
        try {
          versions = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        } catch (_) {}
      }

      versions[version.datasetName] = version.toJson();
      await file.writeAsString(jsonEncode(versions));
    } catch (_) {}
  }

  /// Check if a newer version is available on GitHub.
  Future<bool> _hasNewerVersion(SyncConfig config) async {
    if (config.githubRepo == null) return false;

    try {
      final latestReleaseUrl =
          'https://api.github.com/repos/${config.githubRepo}/releases/latest';
      final response = await _client
          .get(Uri.parse(latestReleaseUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final release = jsonDecode(response.body) as Map<String, dynamic>;
        final tagName = release['tag_name'] as String?;
        return tagName != null && tagName != config.version;
      }
    } catch (_) {}
    return false;
  }

  /// Download a dataset from a URL.
  Future<String?> _downloadDataset(String url) async {
    try {
      final response = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (_) {}
    return null;
  }

  /// Sync a single dataset.
  ///
  /// Returns a [SyncResult] indicating success/failure and whether
  /// the dataset was updated.
  Future<SyncResult> syncDataset(SyncConfig config) async {
    // Validate local file exists
    final localFile = File(config.localPath);
    if (!await localFile.exists()) {
      return SyncResult(
        success: false,
        datasetName: config.datasetName,
        error: 'Local file not found: ${config.localPath}',
      );
    }

    // Check for newer version on GitHub
    final hasUpdate = await _hasNewerVersion(config);
    if (!hasUpdate) {
      // Cache current version
      await _saveVersion(DatasetVersion(
        datasetName: config.datasetName,
        version: config.version,
        lastSynced: DateTime.now(),
        sourceUrl: 'https://github.com/${config.githubRepo}',
        isLocal: true,
      ));

      return SyncResult(
        success: true,
        datasetName: config.datasetName,
        newVersion: config.version,
        wasUpdated: false,
      );
    }

    // Download newer version from GitHub releases or raw files
    try {
      final downloadUrl =
          'https://raw.githubusercontent.com/${config.githubRepo}/main/packages/medical_standards/${config.localPath}';
      final content = await _downloadDataset(downloadUrl);

      if (content != null) {
        // Validate JSON
        jsonDecode(content);

        // Save to cache
        final cacheDir = await _getCacheDir();
        final cachedFile = File(p.join(cacheDir.path, config.localFileName));
        await cachedFile.writeAsString(content);

        await _saveVersion(DatasetVersion(
          datasetName: config.datasetName,
          version: config.version,
          lastSynced: DateTime.now(),
          sourceUrl: 'https://github.com/${config.githubRepo}',
          isLocal: true,
        ));

        return SyncResult(
          success: true,
          datasetName: config.datasetName,
          newVersion: config.version,
          wasUpdated: true,
        );
      }
    } catch (e) {
      return SyncResult(
        success: false,
        datasetName: config.datasetName,
        error: 'Download failed: $e',
      );
    }

    return SyncResult(
      success: true,
      datasetName: config.datasetName,
      wasUpdated: false,
    );
  }

  /// Sync all datasets managed by this service.
  ///
  /// Returns a list of [SyncResult] for each dataset.
  Future<List<SyncResult>> syncAll() async {
    final results = <SyncResult>[];
    for (final config in datasets) {
      results.add(await syncDataset(config));
    }
    return results;
  }

  /// Get the sync versions for all datasets.
  Future<Map<String, DatasetVersion>> getSyncedVersions() async {
    final versions = <String, DatasetVersion>{};
    for (final config in datasets) {
      final cached = await _getCachedVersion(config.datasetName);
      if (cached != null) {
        versions[config.datasetName] = cached;
      }
    }
    return versions;
  }

  /// Get sync status summary.
  Future<String> getSyncStatus() async {
    final versions = await getSyncedVersions();
    final buffer = StringBuffer('Medical Standards Sync Status\n');
    buffer.writeln('=' * 40);

    for (final config in datasets) {
      final v = versions[config.datasetName];
      if (v != null) {
        buffer.writeln('${config.datasetName}: ${v.version} (synced: ${v.lastSynced})');
      } else {
        buffer.writeln('${config.datasetName}: NOT SYNCED');
      }
    }
    return buffer.toString();
  }

  /// Check if local data is available for offline AI inference.
  Future<bool> isDataAvailable() async {
    for (final config in datasets) {
      final file = File(config.localPath);
      if (!await file.exists()) return false;
    }
    return true;
  }

  /// Clear cached sync versions.
  Future<void> clearCache() async {
    try {
      final cacheDir = await _getCacheDir();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    } catch (_) {}
  }

  void dispose() {
    _client.close();
  }
}
