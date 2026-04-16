import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/auth/infrastructure/services/encryption_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late EncryptionService encryptionService;

  setUp(() {
    encryptionService = EncryptionService();
  });

  group('EncryptionService PIN Hashing', () {
    test('should hash PIN and verify it correctly', () async {
      const pin = '123456';
      final salt = await encryptionService.generatePinSalt();
      final hash = await encryptionService.hashPin(pin, salt);

      final isValid = await encryptionService.verifyPin(pin, hash, salt);
      expect(isValid, isTrue);

      final isInvalid = await encryptionService.verifyPin('654321', hash, salt);
      expect(isInvalid, isFalse);
    });

    test('should fail verification with wrong salt', () async {
      const pin = '123456';
      final salt1 = await encryptionService.generatePinSalt();
      final hash1 = await encryptionService.hashPin(pin, salt1);

      final salt2 = await encryptionService.generatePinSalt();

      final isInvalid = await encryptionService.verifyPin(pin, hash1, salt2);
      expect(isInvalid, isFalse);
    });
  });
}
