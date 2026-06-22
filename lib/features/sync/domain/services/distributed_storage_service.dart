import 'dart:typed_data';

/// Interface for distributed storage operations (IPFS/Filecoin).
abstract class DistributedStorageService {
  /// Caches data on distributed storage and returns its CID.
  Future<String> cacheData(Uint8List data, {bool backupToFilecoin = false});

  /// Retrieves data from distributed storage and verifies its integrity.
  Future<Uint8List> getData(String cid, String expectedHash);
}
