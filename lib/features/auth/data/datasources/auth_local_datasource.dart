import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/auth_credentials.dart';

@lazySingleton
class AuthLocalDataSource {
  final Isar _isar;

  AuthLocalDataSource(this._isar);

  Future<AuthCredentials?> getCredentials() async {
    return await _isar.authCredentials.where().findFirst();
  }

  Future<void> saveCredentials(AuthCredentials credentials) async {
    await _isar.writeTxn(() async {
      await _isar.authCredentials.put(credentials);
    });
  }

  Future<void> deleteCredentials() async {
    await _isar.writeTxn(() async {
      await _isar.authCredentials.clear();
    });
  }
}
