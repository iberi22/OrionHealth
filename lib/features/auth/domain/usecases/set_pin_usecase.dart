import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../entities/auth_credentials.dart';
import '../repositories/auth_repository.dart';
import '../../infrastructure/services/encryption_service.dart';

@injectable
class SetPinUseCase {
  final AuthRepository _repository;
  final EncryptionService _encryptionService;

  SetPinUseCase(this._repository, this._encryptionService);

  Future<bool> call(String pin) async {
    if (pin.length < 4 || pin.length > 6) {
      return false;
    }

    final salt = const Uuid().v4();
    final hash = await _encryptionService.hashPin(pin, salt);

    final credentials = AuthCredentials()
      ..hashedPin = hash
      ..salt = salt
      ..biometricEnabled = false
      ..failedAttempts = 0;

    await _repository.saveCredentials(credentials);
    return true;
  }
}
