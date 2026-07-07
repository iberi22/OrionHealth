import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/auth/infrastructure/services/encryption_service.dart';
import 'package:orionhealth_health/core/services/secure_storage_service.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late EncryptionService encryptionService;
  late MockSecureStorageService mockSecureStorage;

  setUp(() {
    mockSecureStorage = MockSecureStorageService();
    encryptionService = EncryptionService(mockSecureStorage);
  });

  group('EncryptionService', () {
    test('hashPin should produce consistent hash for same pin and salt', () async {
      const pin = '1234';
      const salt = 'some-salt';

      final hash1 = await encryptionService.hashPin(pin, salt);
      final hash2 = await encryptionService.hashPin(pin, salt);

      expect(hash1, equals(hash2));
    });

    test('hashPin should produce different hash for different pin', () async {
      const salt = 'some-salt';

      final hash1 = await encryptionService.hashPin('1234', salt);
      final hash2 = await encryptionService.hashPin('4321', salt);

      expect(hash1, isNot(equals(hash2)));
    });

    test('encrypt and decrypt should return original data', () async {
      const data = 'secret-medical-data';
      const key = 'a-very-secure-key-12345678901234';

      final encrypted = await encryptionService.encrypt(data, key);
      final decrypted = await encryptionService.decrypt(encrypted, key);

      expect(decrypted, equals(data));
      expect(encrypted, isNot(equals(data)));
    });

    test('health encryption should work correctly', () async {
      const data = 'patient-sensitive-data';
      const masterSecret = '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

      when(() => mockSecureStorage.readSecure(any(), any()))
          .thenAnswer((_) async => masterSecret);

      final encrypted = await encryptionService.encryptHealthData(data);
      final decrypted = await encryptionService.decryptHealthData(encrypted);

      expect(decrypted, equals(data));
      expect(encrypted, isNot(equals(data)));

      verify(() => mockSecureStorage.readSecure('health_encryption', 'master_secret')).called(2);
    });

    test('initialize should create master secret if not exists', () async {
      when(() => mockSecureStorage.containsKey(any())).thenAnswer((_) async => false);
      when(() => mockSecureStorage.writeSecure(any(), any(), any())).thenAnswer((_) async => {});

      await encryptionService.initialize();

      verify(() => mockSecureStorage.writeSecure(
        'health_encryption',
        'master_secret',
        any(),
      )).called(1);
    });
  });
}
