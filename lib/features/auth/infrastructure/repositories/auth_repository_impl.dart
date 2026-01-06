import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';

import '../../domain/entities/auth_credentials.dart';
import '../../domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final Isar _isar;

  AuthRepositoryImpl(this._isar);

  @override
  Future<AuthCredentials?> getCredentials() async {
    return _isar.authCredentials.where().findFirst();
  }

  @override
  Future<void> saveCredentials(AuthCredentials credentials) async {
    credentials.updatedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.authCredentials.put(credentials);
    });
  }

  @override
  Future<bool> hasSetupAuth() async {
    final credentials = await getCredentials();
    return credentials != null && credentials.pinHash != null;
  }

  @override
  Future<void> clearCredentials() async {
    await _isar.writeTxn(() async {
      await _isar.authCredentials.clear();
    });
  }

  @override
  Future<void> updateAuthMethod(AuthMethod method) async {
    final credentials = await getCredentials();
    if (credentials != null) {
      credentials.authMethod = method;
      await saveCredentials(credentials);
    }
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    final credentials = await getCredentials();
    if (credentials != null) {
      credentials.biometricEnabled = enabled;
      if (enabled) {
        credentials.authMethod = AuthMethod.both;
      } else if (credentials.authMethod == AuthMethod.biometric) {
        credentials.authMethod = AuthMethod.pin;
      }
      await saveCredentials(credentials);
    }
  }

  @override
  Future<void> recordFailedAttempt() async {
    final credentials = await getCredentials();
    if (credentials != null) {
      credentials.recordFailedAttempt();
      await saveCredentials(credentials);
    }
  }

  @override
  Future<void> resetFailedAttempts() async {
    final credentials = await getCredentials();
    if (credentials != null) {
      credentials.resetFailedAttempts();
      await saveCredentials(credentials);
    }
  }

  @override
  Future<void> updateSessionTimeout(int minutes) async {
    final credentials = await getCredentials();
    if (credentials != null) {
      credentials.sessionTimeoutMinutes = minutes;
      await saveCredentials(credentials);
    }
  }
}
