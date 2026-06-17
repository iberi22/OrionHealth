import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import '../../infrastructure/services/ipfs_service.dart';

@lazySingleton
class DistributedCacheUsecase {
  final IpfsService _ipfsService;

  DistributedCacheUsecase(this._ipfsService);

  /// Caches a medical standard chunk on IPFS.
  Future<String?> cacheStandard(Uint8List data) async {
    try {
      return await _ipfsService.cacheData(data);
    } catch (e) {
      // Gracefully degrade if IPFS is unavailable
      print('Distributed cache failed: $e. Falling back to direct storage/download.');
      return null;
    }
  }

  /// Retrieves a medical standard from IPFS with fallback.
  Future<Uint8List> getStandard(String cid, String expectedHash, Future<Uint8List> Function() fallback) async {
    try {
      return await _ipfsService.getData(cid, expectedHash);
    } catch (e) {
      print('IPFS retrieval failed: $e. Using fallback.');
      return await fallback();
    }
  }
}
