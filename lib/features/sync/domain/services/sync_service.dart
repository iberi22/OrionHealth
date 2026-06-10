/// Domain service for orchestrating the full synchronization process.
///
/// This service coordinates data sync from FHIR/RDA sources and
/// medical standards updates from local peers or remote repositories.
abstract class SyncService {
  /// Synchronizes everything: Patient profile, clinical data, and medical standards.
  Future<void> performFullSync();

  /// Gets the last successful synchronization time.
  Future<DateTime?> getLastSyncTime();
}
