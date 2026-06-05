import 'dart:convert';
import 'package:dio/dio.dart';
import 'encryption_service.dart';

/// Sync state machine.
enum SyncState { idle, syncing, success, error, offline }

/// Result of a sync operation.
class SyncResult {
  SyncResult({
    required this.success,
    this.error,
    required this.syncedAt,
    required this.recordsSynced,
  });

  final bool success;
  final String? error;
  final DateTime syncedAt;
  final int recordsSynced;
}

/// Service for syncing encrypted health data between Orion nodes.
class SyncService {
  SyncService(this._encryption, {Dio? dio}) : _dio = dio ?? Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(minutes: 5),
  ));

  final EncryptionService _encryption;
  final Dio _dio;

  static const String _defaultDiscoveryEndpoint =
      'https://orion-network.io/api/v1/nodes';
  static const String _protocolVersion = '1.0';

  /// Push encrypted health data to a target Orion node.
  Future<SyncResult> pushToNode({
    required String targetNodeId,
    required Map<String, dynamic> healthData,
    required String senderNodeId,
    String? pin,
  }) async {
    try {
      final encrypted = await _encryption.encryptPayload(healthData, pin);
      final package = {
        'version': _protocolVersion,
        'senderNodeId': senderNodeId,
        'targetNodeId': targetNodeId,
        'timestamp': DateTime.now().toIso8601String(),
        'payload': encrypted,
      };

      // Real implementation: send via NFC/BLE/WiFi direct or relay server
      // For now simulate success
      return SyncResult(
        success: true,
        syncedAt: DateTime.now(),
        recordsSynced: _countRecords(healthData),
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

  /// Pull encrypted data from a remote node and decrypt it.
  Future<Map<String, dynamic>?> pullFromNode({
    required String packageJson,
    required String pin,
  }) async {
    try {
      final package = jsonDecode(packageJson) as Map<String, dynamic>;
      if (package['version'] != _protocolVersion) {
        throw Exception('Incompatible sync protocol version');
      }

      final encrypted = package['payload'] as Map<String, dynamic>;
      return _encryption.decryptPayload(encrypted, pin);
    } catch (e) {
      return null;
    }
  }

  /// Create an encrypted transfer package for one-time sharing.
  Future<String> createTransferPackage({
    required Map<String, dynamic> healthData,
    required String senderNodeId,
    required String recipientNodeId,
    String? pin,
    Duration? expiresIn,
  }) async {
    final encrypted = await _encryption.encryptPayload(healthData, pin);
    final signature = await _encryption.signPackage(healthData);

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
      'signature': signature,
    };

    return jsonEncode(package);
  }

  /// Download public medical standards (ICD-10, LOINC, RxNorm).
  Future<void> syncMedicalStandards({
    void Function(double progress)? onProgress,
  }) async {
    try {
      onProgress?.call(0.1);
      // Real: download from GitHub releases / distributed cache
      // - ICD-10 full dataset
      // - SNOMED CT subset
      // - LOINC full dataset
      // - RxNorm full dataset
      onProgress?.call(1.0);
    } catch (e) {
      rethrow;
    }
  }

  /// Discover peer nodes on the Orion network.
  Future<List<Map<String, dynamic>>> discoverPeerNodes() async {
    try {
      final response = await _dio.get(_defaultDiscoveryEndpoint);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['nodes'] ?? []);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Check whether remote data has changed since last sync.
  Future<bool> hasRemoteUpdates(String lastSyncHash) async {
    // Real: compare merkle root or content hash
    return false;
  }

  int _countRecords(Map<String, dynamic> data) {
    int count = 0;
    for (final value in data.values) {
      if (value is List) count += value.length;
    }
    return count;
  }
}
