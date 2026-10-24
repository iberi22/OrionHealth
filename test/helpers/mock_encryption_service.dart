import 'package:flutter/foundation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/auth/infrastructure/services/encryption_service.dart';

@visibleForTesting
class MockEncryptionService extends Mock implements EncryptionService {}

/// Reversible stand-in for repositories that only need encrypt/decrypt to
/// round-trip (the real service derives an Argon2id key from secure storage).
@visibleForTesting
class FakeEncryptionService extends Fake implements EncryptionService {
  @override
  Future<String> encryptHealthData(String data) async => 'enc:$data';

  @override
  Future<String> decryptHealthData(String encryptedData) async =>
      encryptedData.substring('enc:'.length);
}
