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
    return await _isar.authCredentials.where().findFirst();
  }

  @override
  Future<void> saveCredentials(AuthCredentials credentials) async {
    await _isar.writeTxn(() async {
      await _isar.authCredentials.put(credentials);
    });
  }

  @override
  Future<void> deleteCredentials() async {
    await _isar.writeTxn(() async {
      await _isar.authCredentials.where().deleteAll();
    });
  }

  @override
  Future<bool> hasPinSet() async {
    final credentials = await getCredentials();
    return credentials?.hashedPin != null;
  }

  @override
  Future<bool> isBiometricsEnabled() async {
    final credentials = await getCredentials();
    return credentials?.biometricEnabled == true;
  }
}
