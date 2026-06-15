import '../../domain/entities/did.dart';
import '../../domain/entities/verifiable_credential.dart';
import '../../domain/repositories/ssi_repository.dart';
import '../datasources/ssi_local_datasource.dart';
import '../datasources/ssi_remote_datasource.dart';

class SsiRepositoryImpl implements SsiRepository {
  final SsiLocalDataSource _localDataSource;
  final SsiRemoteDataSource _remoteDataSource;
  SsiRepositoryImpl(this._localDataSource, this._remoteDataSource);

  @override
  Future<void> saveDid(Did did, Map<String, dynamic> dd) => _localDataSource.saveDid(did, dd);
  @override
  Future<List<Did>> getDids() => _localDataSource.getDids();
  @override
  Future<Map<String, dynamic>?> getDidDocument(String did) => _localDataSource.getDidDocument(did);
  @override
  Future<void> saveCredential(VerifiableCredential c) => _localDataSource.saveCredential(c);
  @override
  Future<List<VerifiableCredential>> getCredentials() => _localDataSource.getCredentials();
  @override
  Future<VerifiableCredential?> getCredentialById(String id) => _localDataSource.getCredentialById(id);
  @override
  Future<void> deleteCredential(String id) => _localDataSource.deleteCredential(id);
  @override
  Future<void> saveRevocationEntry(RevocationEntry e) => _localDataSource.saveRevocationEntry(
    e.credentialId, e.issuerPublicKey, e.credentialIndex, e.revokedAt, e.issuerSignature);
  @override
  Future<RevocationEntry?> getRevocationEntry(String k, int i) async {
    final d = await _localDataSource.getRevocationEntry(k, i);
    if (d == null) return null;
    return RevocationEntry(credentialId: d['credentialId'] as String, credentialIndex: d['credentialIndex'] as int,
      issuerPublicKey: d['issuerPublicKey'] as String, revokedAt: d['revokedAt'] as DateTime, issuerSignature: d['issuerSignature'] as String);
  }
}
