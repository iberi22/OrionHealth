import '../entities/auth_credentials.dart';

abstract class AuthRepository {
  Future<AuthCredentials?> getCredentials();
  Future<void> saveCredentials(AuthCredentials credentials);
  Future<void> deleteCredentials();
  Future<bool> hasPinSet();
  Future<bool> isBiometricsEnabled();
}
