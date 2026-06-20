import '../entities/sync_node.dart';

/// Interface for synchronizing patient and clinical data from IHCE FHIR APIs.
abstract class SyncRepository {
  /// Gets the stored IHCE access token.
  Future<String?> getAccessToken();

  /// Saves the IHCE access token.
  Future<void> saveAccessToken(String token);

  /// Gets the timestamp of the last successful synchronization.
  Future<DateTime?> getLastSyncTime();

  /// Sets the timestamp of the last successful synchronization.
  Future<void> setLastSyncTime(DateTime time);

  /// Synchronizes patient profile and clinical data (medications, allergies, vitals, conditions).
  ///
  /// Throws an [Exception] if the token is missing or if the sync fails.
  Future<void> syncAll();

  /// Synchronizes data only if the last sync was performed more than 6 hours ago.
  ///
  /// Returns `true` if sync was performed, `false` otherwise.
  Future<bool> syncIfStale();

  /// Synchronizes the patient profile from the FHIR server.
  Future<void> syncPatient(String patientId, String token);

  /// Synchronizes the RDA (clinical data) from the FHIR server.
  Future<void> syncRda(String patientId, String token);

  /// Returns a list of discovered nodes in the local network.
  Future<List<SyncNode>> getDiscoveredNodes();
}
