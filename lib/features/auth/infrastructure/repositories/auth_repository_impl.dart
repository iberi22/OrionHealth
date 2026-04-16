import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/auth_credentials.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/biometric_service.dart';
import '../services/encryption_service.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final Isar _isar;
  final EncryptionService _encryptionService;
  final BiometricService _biometricService;

  AuthRepositoryImpl(
    this._isar,
    this._encryptionService,
    this._biometricService,
  );

  @override
  Future<AuthCredentials?> getCredentials() async {
    return _isar.authCredentials.where().findFirst();
  }

  @override
  Future<void> saveCredentials(AuthCredentials credentials) async {
    await _isar.writeTxn(() async {
      await _isar.authCredentials.put(credentials);
    });
  }

  @override
  Future<void> setupPin(String pin) async {
    final salt = await _encryptionService.generatePinSalt();
    final hashedPin = await _encryptionService.hashPin(pin, salt);

    var credentials = await getCredentials();
    if (credentials == null) {
      credentials = AuthCredentials(
        hashedPin: hashedPin,
        salt: salt,
      );
    } else {
      credentials = credentials.copyWith(
        hashedPin: hashedPin,
        salt: salt,
        failedAttempts: 0,
        lockoutUntil: null,
      );
    }

    await saveCredentials(credentials);
  }

  @override
  Future<bool> verifyPin(String pin) async {
    final credentials = await getCredentials();
    if (credentials == null ||
        credentials.hashedPin == null ||
        credentials.salt == null) {
      return false;
    }

    final isValid = await _encryptionService.verifyPin(
      pin,
      credentials.hashedPin!,
      credentials.salt!,
    );

    if (isValid) {
      await resetFailedAttempts();
    } else {
      await recordFailedAttempt();
    }

    return isValid;
  }

  @override
  Future<void> setBiometricsEnabled(bool enabled) async {
    final credentials = await getCredentials();
    if (credentials != null) {
      await saveCredentials(credentials.copyWith(isBiometricsEnabled: enabled));
    }
  }

  @override
  Future<bool> isBiometricsAvailable() async {
    return _biometricService.isBiometricsAvailable();
  }

  @override
  Future<bool> authenticateWithBiometrics() async {
    final credentials = await getCredentials();
    if (credentials == null || !credentials.isBiometricsEnabled) {
      return false;
    }

    final authenticated = await _biometricService.authenticate();
    if (authenticated) {
      await resetFailedAttempts();
    }
    return authenticated;
  }

  @override
  Future<void> recordFailedAttempt() async {
    final credentials = await getCredentials();
    if (credentials == null) return;

    final newFailedAttempts = credentials.failedAttempts + 1;
    DateTime? lockoutUntil;

    if (newFailedAttempts >= 3) {
      // Progressive lockout: 1, 5, 15, 30, 60 minutes
      final minutes = _getLockoutMinutes(newFailedAttempts);
      lockoutUntil = DateTime.now().add(Duration(minutes: minutes));
    }

    await saveCredentials(
      credentials.copyWith(
        failedAttempts: newFailedAttempts,
        lockoutUntil: lockoutUntil,
      ),
    );
  }

  int _getLockoutMinutes(int failedAttempts) {
    final level = failedAttempts - 3; // 0 for 3rd attempt, 1 for 4th, etc.
    switch (level) {
      case 0:
        return 1;
      case 1:
        return 5;
      case 2:
        return 15;
      case 3:
        return 30;
      default:
        return 60;
    }
  }

  @override
  Future<void> resetFailedAttempts() async {
    final credentials = await getCredentials();
    if (credentials != null) {
      await saveCredentials(
        credentials.copyWith(
          failedAttempts: 0,
          lockoutUntil: null,
        ),
      );
    }
  }

  @override
  Future<bool> isLockedOut() async {
    final credentials = await getCredentials();
    if (credentials == null || credentials.lockoutUntil == null) {
      return false;
    }
    return DateTime.now().isBefore(credentials.lockoutUntil!);
  }

  @override
  Future<int> getRemainingLockoutSeconds() async {
    final credentials = await getCredentials();
    if (credentials == null || credentials.lockoutUntil == null) {
      return 0;
    }
    final diff = credentials.lockoutUntil!.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  @override
  Future<void> clearAuthData() async {
    await _isar.writeTxn(() async {
      await _isar.authCredentials.clear();
    });
    await _encryptionService.clearAllSecureData();
  }
}
