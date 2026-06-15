import '../../domain/entities/auth_credentials.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_secure_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _localDataSource;
  final AuthSecureDataSource _secureDataSource;
  AuthRepositoryImpl(this._localDataSource, this._secureDataSource);

  @override
  Future<AuthCredentials?> getCredentials() => _localDataSource.getCredentials();
  @override
  Future<void> saveCredentials(AuthCredentials c) => _localDataSource.saveCredentials(c);
  @override
  Future<void> deleteCredentials() => _localDataSource.deleteCredentials();
  @override
  Future<bool> hasPinSet() async => (await _localDataSource.getCredentials())?.hashedPin != null;
  @override
  Future<bool> isBiometricsEnabled() async => (await _localDataSource.getCredentials())?.biometricEnabled == true;
}
