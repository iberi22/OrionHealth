import 'package:injectable/injectable.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../domain/entities/auth_credentials.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _localDataSource;
  final SecureStorageService _secureStorage;

  static const _sessionKey = 'auth_session';
  static const _credentialsNamespace = 'auth_credentials';

  static const _userKey = 'auth_user';

  AuthSession? _currentSession;
  AuthUser? _authenticatedUser;

  AuthRepositoryImpl(this._localDataSource, this._secureStorage);

  @override
  Future<AuthCredentials?> getCredentials() async {
    final credentials = await _localDataSource.getCredentials();
    if (credentials == null) return null;

    // Merge sensitive data from secure storage
    credentials.hashedPin = await _secureStorage.readSecure(_credentialsNamespace, 'hashedPin');
    credentials.salt = await _secureStorage.readSecure(_credentialsNamespace, 'salt');

    final biometricStr = await _secureStorage.readSecure(_credentialsNamespace, 'biometricEnabled');
    if (biometricStr != null) {
      credentials.biometricEnabled = biometricStr == 'true';
    }

    return credentials;
  }

  @override
  Future<void> saveCredentials(AuthCredentials credentials) async {
    // 1. Save sensitive data to Secure Storage
    if (credentials.hashedPin != null) {
      await _secureStorage.writeSecure(_credentialsNamespace, 'hashedPin', credentials.hashedPin!);
    }
    if (credentials.salt != null) {
      await _secureStorage.writeSecure(_credentialsNamespace, 'salt', credentials.salt!);
    }
    await _secureStorage.writeSecure(_credentialsNamespace, 'biometricEnabled', credentials.biometricEnabled.toString());

    // 2. Clear sensitive data from credentials object before saving to Isar
    final credentialsToSave = AuthCredentials()
      ..id = credentials.id
      ..biometricEnabled = credentials.biometricEnabled
      ..failedAttempts = credentials.failedAttempts
      ..lastLockoutTime = credentials.lastLockoutTime;
    // We explicitly DO NOT set hashedPin and salt here

    // 3. Save to local data source (Isar)
    await _localDataSource.saveCredentials(credentialsToSave);
  }

  @override
  Future<void> deleteCredentials() async {
    await _secureStorage.deleteSecure(_credentialsNamespace, 'hashedPin');
    await _secureStorage.deleteSecure(_credentialsNamespace, 'salt');
    await _secureStorage.deleteSecure(_credentialsNamespace, 'biometricEnabled');
    await _localDataSource.deleteCredentials();
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
    if (_currentSession != null) return _currentSession;

    final json = await _secureStorage.readJson(_sessionKey);
    if (json != null) {
      _currentSession = AuthSession(
        token: json['token'] as String,
        expiresAt: DateTime.parse(json['expiresAt'] as String),
      );
    }
    return _currentSession;
  }

  @override
  Future<void> saveSession(AuthSession session) async {
    _currentSession = session;
    await _secureStorage.writeJson(_sessionKey, {
      'token': session.token,
      'expiresAt': session.expiresAt.toIso8601String(),
    });
  }

  @override
  Future<void> deleteSession() async {
    _currentSession = null;
    await _secureStorage.delete(_sessionKey);
  }

  @override
  Future<AuthUser?> getAuthenticatedUser() async {
    if (_authenticatedUser != null) return _authenticatedUser;

    final json = await _secureStorage.readJson(_userKey);
    if (json != null) {
      _authenticatedUser = AuthUser(
        id: json['id'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
      );
    }
    return _authenticatedUser;
  }

  Future<void> _saveAuthenticatedUser(AuthUser user) async {
    _authenticatedUser = user;
    await _secureStorage.writeJson(_userKey, {
      'id': user.id,
      'email': user.email,
      'role': user.role,
    });
  }

  @override
  Future<void> setAuthenticatedUser(AuthUser? user) async {
    _authenticatedUser = user;
    if (user != null) {
      await _saveAuthenticatedUser(user);
    } else {
      await _secureStorage.delete(_userKey);
    }
  }
}
