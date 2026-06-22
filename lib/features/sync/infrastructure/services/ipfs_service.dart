import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:injectable/injectable.dart';
import '../../domain/services/distributed_storage_service.dart';
import '../datasources/ipfs_datasource.dart';
import '../datasources/filecoin_datasource.dart';

@LazySingleton(as: DistributedStorageService)
class IpfsService implements DistributedStorageService {
  final IpfsDatasource _ipfsDatasource;
  final FilecoinDatasource _filecoinDatasource;

  IpfsService(this._ipfsDatasource, this._filecoinDatasource);

  /// Caches data on IPFS and pins it. Optionally backs up to Filecoin.
  @override
  Future<String> cacheData(Uint8List data, {bool backupToFilecoin = false}) async {
    final cid = await _ipfsDatasource.add(data);
    await _ipfsDatasource.pin(cid);

    if (backupToFilecoin) {
      await _filecoinDatasource.store(data);
    }

    return cid;
  }

  /// Retrieves data from IPFS and verifies integrity.
  @override
  Future<Uint8List> getData(String cid, String expectedHash) async {
    final data = await _ipfsDatasource.get(cid);

    // Verify integrity
    final actualHash = sha256.convert(data).toString();
    if (actualHash != expectedHash) {
      throw Exception('Data integrity verification failed. Expected $expectedHash, got $actualHash');
    }

    return data;
  }
}
