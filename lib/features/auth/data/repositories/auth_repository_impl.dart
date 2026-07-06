import 'package:injectable/injectable.dart';
import '../../domain/entities/auth_credentials.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _localDataSource;

  AuthSession? _currentSession;
  AuthUser? _authenticatedUser;

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

  @override
  Future<AuthSession?> getSession() async {
    return _currentSession;
  }

  @override
  Future<void> saveSession(AuthSession session) async {
    _currentSession = session;
    // In a real app, you might persist this token securely
  }

  @override
  Future<void> deleteSession() async {
    _currentSession = null;
  }

  @override
  Future<AuthUser?> getAuthenticatedUser() async {
    return _authenticatedUser;
  }

  void setAuthenticatedUser(AuthUser? user) {
    _authenticatedUser = user;
  }
}
