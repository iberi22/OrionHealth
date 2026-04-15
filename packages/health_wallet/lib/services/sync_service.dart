import 'dart:convert';
import 'package:dio/dio.dart';
import 'encryption_service.dart';

/// Sync status
enum SyncState {
  idle,
  syncing,
  success,
  error,
  offline,
}

/// Sync result
class SyncResult {
  final bool success;
  final String? error;
  final DateTime syncedAt;
  final int recordsSynced;

  SyncResult({
    required this.success,
    this.error,
    required this.syncedAt,
    required this.recordsSynced,
  });
}

/// Service for syncing encrypted health data between nodes
class SyncService {
  final EncryptionService _encryption;
  final Dio _dio;

  // Node discovery endpoint (could be IPFS, libp2p, or centralized)
  static const String _defaultDiscoveryEndpoint =
      'https://orion-network.io/api/v1/nodes';

  // Sync protocol version
  static const String _protocolVersion = '1.0';

  SyncService(this._encryption) : _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(minutes: 5),
  ));

  /// Sync health data to a receiving Orion node
  Future<SyncResult> syncToNode({
    required String targetNodeId,
    required Map<String, dynamic> encryptedData,
    required String senderNodeId,
    String? pin,
  }) async {
    try {
      // Build sync package
      final package = {
        'version': _protocolVersion,
        'senderNodeId': senderNodeId,
        'targetNodeId': targetNodeId,
        'timestamp': DateTime.now().toIso8601String(),
        'encryptedPayload': encryptedData,
        'pinRequired': pin != null,
      };

      // In real implementation, would connect via NFC/BLE/WiFi directly
      // or through a relay server if both nodes are online

      // For now, simulate successful sync
      return SyncResult(
        success: true,
        syncedAt: DateTime.now(),
        recordsSynced: _countRecords(encryptedData),
      );
    } catch (e) {
      return SyncResult(
        success: false,
        error: e.toString(),
        syncedAt: DateTime.now(),
        recordsSynced: 0,
      );
    }
  }

  /// Receive sync package from another Orion node
  Future<Map<String, dynamic>?> receivePackage(
    String packageJson, {
    required String pin,
  }) async {
    try {
      final package = jsonDecode(packageJson) as Map<String, dynamic>;

      // Verify protocol version
      if (package['version'] != _protocolVersion) {
        throw Exception('Incompatible sync protocol version');
      }

      // Decrypt payload
      final encryptedPayload = package['encryptedPayload'] as Map<String, dynamic>;
      final decrypted = await _encryption.decryptPayload(encryptedPayload, pin);

      return decrypted;
    } catch (e) {
      return null;
    }
  }

  /// Create encrypted package for transfer
  Future<String> createTransferPackage({
    required Map<String, dynamic> healthData,
    required String senderNodeId,
    required String recipientNodeId,
    String? pin,
    Duration? expiresIn,
  }) async {
    // Encrypt the health data
    final encrypted = await _encryption.encryptPayload(healthData, pin);

    final package = {
      'header': {
        'version': _protocolVersion,
        'type': 'ORION_HEALTH_TRANSFER',
        'senderNodeId': senderNodeId,
        'recipientNodeId': recipientNodeId,
        'createdAt': DateTime.now().toIso8601String(),
        'expiresAt': expiresIn != null
            ? DateTime.now().add(expiresIn).toIso8601String()
            : null,
      },
      'payload': encrypted,
      'signature': await _encryption.signPackage(healthData),
    };

    return jsonEncode(package);
  }

  /// Sync medical standards from network (public data)
  Future<Map<String, dynamic>> syncMedicalStandards({
    void Function(double progress)? onProgress,
  }) async {
    // This is for syncing PUBLIC standards, not private health data
    final standards = <String, dynamic>{};

    try {
      // In real implementation, would download from GitHub releases
      // or from a distributed cache

      onProgress?.call(0.1);

      // Sync would happen here - for now return empty
      // Real implementation would download:
      // - ICD-10 full dataset
      // - SNOMED CT subset
      // - LOINC full dataset
      // - RxNorm full dataset
      // - Clinical guidelines

      onProgress?.call(1.0);

      return standards;
    } catch (e) {
      rethrow;
    }
  }

  /// Check for updates to synced data
  Future<bool> checkForUpdates(String lastSyncHash) async {
    // In real implementation, would check a hash/checksum
    // of the latest available data vs local
    return false;
  }

  /// Get peer nodes for sync
  Future<List<Map<String, dynamic>>> discoverPeerNodes() async {
    try {
      final response = await _dio.get(_defaultDiscoveryEndpoint);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['nodes'] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  int _countRecords(Map<String, dynamic> data) {
    int count = 0;
    for (final key in data.keys) {
      if (data[key] is List) {
        count += (data[key] as List).length;
      }
    }
    return count;
  }
}
