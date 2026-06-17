import 'entities/sync_node.dart';

abstract class SyncRepository {
  /// Get access token from secure storage
  Future<String?> getAccessToken();

  /// Save access token to secure storage
  Future<void> saveAccessToken(String token);

  /// Get the timestamp of the last successful sync
  Future<DateTime?> getLastSyncTime();

  /// Update the timestamp of the last successful sync
  Future<void> setLastSyncTime(DateTime time);

  /// Synchronize patient profile from IHCE
  Future<void> syncPatient(String patientId, String token);

  /// Synchronize RDA (medications, allergies, vitals, conditions) from IHCE
  Future<void> syncRda(String patientId, String token);

  /// Get list of discovered OrionHealth nodes on the local network
  List<SyncNode> getDiscoveredNodes();

  /// Perform a full sync of all data types
  Future<void> syncAll();
}
