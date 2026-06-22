import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import '../services/distributed_storage_service.dart';

@lazySingleton
class DistributedCacheUsecase {
  final DistributedStorageService _storageService;

  DistributedCacheUsecase(this._storageService);

  /// Caches a medical standard chunk on distributed storage.
  Future<String?> cacheStandard(Uint8List data) async {
    try {
      return await _storageService.cacheData(data);
    } catch (e) {
      // Gracefully degrade if distributed storage is unavailable
      print('Distributed cache failed: $e. Falling back to direct storage/download.');
      return null;
    }
  }

  /// Retrieves a medical standard from distributed storage with fallback.
  Future<Uint8List> getStandard(String cid, String expectedHash, Future<Uint8List> Function() fallback) async {
    try {
      return await _storageService.getData(cid, expectedHash);
    } catch (e) {
      print('Distributed storage retrieval failed: $e. Using fallback.');
      return await fallback();
    }
  }
}
