import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/auth/infrastructure/services/encryption_service.dart';

void main() {
  late EncryptionService encryptionService;

  setUp(() {
    encryptionService = EncryptionService();
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
  });
}
