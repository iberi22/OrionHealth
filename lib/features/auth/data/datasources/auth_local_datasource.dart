import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/auth_credentials.dart';

@lazySingleton
class AuthLocalDataSource {
  final Isar _isar;
  AuthLocalDataSource(this._isar);

  Future<AuthCredentials?> getCredentials() => _isar.authCredentials.where().findFirst();

  Future<void> saveCredentials(AuthCredentials c) =>
      _isar.writeTxn(() async => _isar.authCredentials.put(c));

  Future<void> deleteCredentials() =>
      _isar.writeTxn(() async => _isar.authCredentials.where().deleteAll());
}
