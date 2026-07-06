import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../entities/auth_credential.dart';
import '../entities/auth_credentials.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';
import '../../infrastructure/services/encryption_service.dart';
import '../../infrastructure/services/biometric_service.dart';

@injectable
class LoginUseCase {
  final AuthRepository _repository;
  final EncryptionService _encryptionService;
  final BiometricService _biometricService;

  static const int sessionTimeoutMinutes = 15;

  LoginUseCase(
    this._repository,
    this._encryptionService,
    this._biometricService,
  );

  Future<AuthSession?> call(AuthCredential credential) async {
    if (credential is PinCredential) {
      return _loginWithPin(credential.pin);
    } else if (credential is BiometricCredential) {
      return _loginWithBiometrics();
    }
    return null;
  }

  Future<AuthSession?> _loginWithPin(String pin) async {
    final credentials = await _repository.getCredentials();
    if (credentials == null) return null;

    if (credentials.isLocked) return null;

    final hashedInput = await _encryptionService.hashPin(pin, credentials.salt!);

    if (hashedInput == credentials.hashedPin) {
      credentials.failedAttempts = 0;
      credentials.lastLockoutTime = null;
      await _repository.saveCredentials(credentials);
      return _createSession();
    } else {
      credentials.failedAttempts++;
      if (credentials.failedAttempts >= 5) {
        credentials.lastLockoutTime = DateTime.now();
      }
      await _repository.saveCredentials(credentials);
      return null;
    }
  }

  Future<AuthSession?> _loginWithBiometrics() async {
    final credentials = await _repository.getCredentials();
    if (credentials == null || !credentials.biometricEnabled) return null;

    if (credentials.isLocked) return null;

    final authenticated = await _biometricService.authenticate(
      localizedReason: 'Autentícate para acceder a tus datos médicos',
    );

    if (authenticated) {
      return _createSession();
    }
    return null;
  }

  AuthSession _createSession() {
    final expiry = DateTime.now().add(const Duration(minutes: sessionTimeoutMinutes));
    final session = AuthSession(
      token: const Uuid().v4(),
      expiresAt: expiry,
    );
    _repository.saveSession(session);
    return session;
  }
}
