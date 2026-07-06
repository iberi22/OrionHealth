import '../entities/auth_credentials.dart';
import '../entities/auth_session.dart';
import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthCredentials?> getCredentials();
  Future<void> saveCredentials(AuthCredentials credentials);
  Future<void> deleteCredentials();
  Future<bool> hasPinSet();
  Future<bool> isBiometricsEnabled();

  Future<AuthSession?> getSession();
  Future<void> saveSession(AuthSession session);
  Future<void> deleteSession();
  Future<AuthUser?> getAuthenticatedUser();
}
