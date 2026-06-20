import '../entities/sync_node.dart';

/// Interface for synchronizing patient and clinical data from IHCE FHIR APIs.
abstract class SyncRepository {
  /// Gets the stored IHCE access token.
  Future<String?> getAccessToken();

  /// Saves the IHCE access token.
  Future<void> saveAccessToken(String token);

  /// Gets the timestamp of the last successful synchronization.
  Future<DateTime?> getLastSyncTime();

  /// Updates the timestamp of the last successful synchronization.
  Future<void> setLastSyncTime(DateTime time);

  /// Synchronizes patient profile and clinical data (medications, allergies, vitals, conditions).
  ///
  /// Throws an [Exception] if the token is missing or if the sync fails.
  Future<void> syncAll();

  /// Synchronizes patient profile data.
  Future<void> syncPatient(String patientId, String token);

  /// Synchronizes RDA clinical data.
  Future<void> syncRda(String patientId, String token);

  /// Synchronizes data only if the last sync was performed more than 6 hours ago.
  ///
  /// Returns `true` if sync was performed, `false` otherwise.
  Future<bool> syncIfStale();

  /// Returns a list of discovered nodes in the local network.
  List<SyncNode> getDiscoveredNodes();
}
