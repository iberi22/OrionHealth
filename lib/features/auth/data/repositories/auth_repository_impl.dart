import 'package:injectable/injectable.dart';
import '../../domain/entities/auth_credentials.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(this._localDataSource);

  @override
  Future<AuthCredentials?> getCredentials() {
    return _localDataSource.getCredentials();
  }

  @override
  Future<void> saveCredentials(AuthCredentials credentials) {
    return _localDataSource.saveCredentials(credentials);
  }

  @override
  Future<void> deleteCredentials() {
    return _localDataSource.deleteCredentials();
  }

  @override
  Future<bool> hasPinSet() async {
    final creds = await getCredentials();
    return creds?.hashedPin != null;
  }

  @override
  Future<bool> isBiometricsEnabled() async {
    final creds = await getCredentials();
    return creds?.biometricEnabled ?? false;
  }
}
