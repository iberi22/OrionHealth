import 'package:injectable/injectable.dart';
import 'package:medical_standards/medical_standards.dart' as medical;
import '../../user_profile/domain/repositories/user_profile_repository.dart';
import 'sync_repository.dart';

@lazySingleton
class SyncService {
  final SyncRepository _syncRepository;
  final UserProfileRepository _userProfileRepository;

  SyncService(this._syncRepository, this._userProfileRepository);

  /// Full sync: Patient profile + RDA (medications, allergies, vitals, conditions) + P2P Medical Standards
  Future<void> syncAll() async {
    // 0. Sync Medical Standards via P2P if possible
    await _syncMedicalStandards();

    final token = await _syncRepository.getAccessToken();
    if (token == null) {
      throw Exception('No hay conexión con IHCE. Conectá tu EPS primero.');
    }

    final profile = await _userProfileRepository.getUserProfile();
    if (profile == null || profile.epsPatientId == null) {
      throw Exception('Perfil no encontrado o sin ID de paciente IHCE.');
    }

    final patientId = profile.epsPatientId!;

    // 1. Sync Patient -> UserProfile
    await _syncRepository.syncPatient(patientId, token);

    // 2. Sync RDA
    await _syncRepository.syncRda(patientId, token);

    await _syncRepository.setLastSyncTime(DateTime.now());
  }

  /// Sync medical standards from peers if any are discovered
  Future<void> _syncMedicalStandards() async {
    final peers = _syncRepository.getDiscoveredNodes();
    final medicalSyncService = medical.SyncService();

    if (peers.isNotEmpty) {
      // Try to sync from the first available peer
      final peer = peers.first;
      if (peer.host != null) {
        final peerIp = '${peer.host}:${peer.port}';
        await medicalSyncService.syncAll(peerIp: peerIp);
        return;
      }
    }

    // Fallback to default (GitHub)
    await medicalSyncService.syncAll();
  }

  /// Quick sync - only refresh if last sync was > 6 hours ago
  Future<bool> syncIfStale() async {
    final lastSync = await _syncRepository.getLastSyncTime();
    if (lastSync != null) {
      final staleThreshold = DateTime.now().subtract(const Duration(hours: 6));
      if (lastSync.isAfter(staleThreshold)) {
        return false; // Not stale, skip
      }
    }
    await syncAll();
    return true; // Synced
  }

  Future<DateTime?> getLastSyncTime() => _syncRepository.getLastSyncTime();
}
