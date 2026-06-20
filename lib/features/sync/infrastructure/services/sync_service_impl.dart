import 'package:injectable/injectable.dart';
import 'package:medical_standards/medical_standards.dart' as ms;
import '../../domain/repositories/sync_repository.dart';
import '../../domain/services/sync_service.dart';

@LazySingleton(as: SyncService)
class SyncServiceImpl implements SyncService {
  final SyncRepository _syncRepository;
  final ms.SyncService _medicalStandardsSyncService;

  SyncServiceImpl(
    this._syncRepository,
    this._medicalStandardsSyncService,
  );

  @override
  Future<void> performFullSync() async {
    // 1. Sync Medical Standards via P2P or fallback to remote
    await _syncMedicalStandards();

    // 2. Sync FHIR/RDA data
    await _syncRepository.syncAll();
  }

  Future<void> _syncMedicalStandards() async {
    final peers = _syncRepository.getDiscoveredNodes();

    if (peers.isNotEmpty) {
      // Try to sync from the first available peer
      final peer = peers.first;
      final peerIp = '${peer.host}:${peer.port}';
      await _medicalStandardsSyncService.syncAll(peerIp: peerIp);
    } else {
      // Fallback to default (GitHub)
      await _medicalStandardsSyncService.syncAll();
    }
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    return _syncRepository.getLastSyncTime();
  }
}
