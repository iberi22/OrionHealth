import '../../domain/entities/did.dart';
import '../../domain/entities/verifiable_credential.dart';
import '../entities/revocation_entry.dart';

abstract class SsiRepository {
  /// Save a DID and its document
  Future<void> saveDid(Did did, Map<String, dynamic> didDocument);

  /// Get all DIDs
  Future<List<Did>> getDids();

  /// Get a DID Document by DID string
  Future<Map<String, dynamic>?> getDidDocument(String did);

  /// Save a Verifiable Credential
  Future<void> saveCredential(VerifiableCredential credential);

  /// Get all credentials
  Future<List<VerifiableCredential>> getCredentials();

  /// Get a credential by ID
  Future<VerifiableCredential?> getCredentialById(String credentialId);

  /// Remove a credential
  Future<void> deleteCredential(String credentialId);

  /// Save a revocation entry
  Future<void> saveRevocationEntry(RevocationEntry entry);

  /// Get a revocation entry by issuer and credential index
  Future<RevocationEntry?> getRevocationEntry(String issuerPublicKey, int credentialIndex);
}
