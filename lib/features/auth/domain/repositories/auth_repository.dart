import '../entities/auth_credentials.dart';

abstract class AuthRepository {
  /// Returns the current auth credentials from the database
  Future<AuthCredentials?> getCredentials();

  /// Saves or updates the auth credentials
  Future<void> saveCredentials(AuthCredentials credentials);

  /// Sets up a new PIN
  Future<void> setupPin(String pin);

  /// Verifies a PIN against the stored hash
  Future<bool> verifyPin(String pin);

  /// Toggles biometric authentication
  Future<void> setBiometricsEnabled(bool enabled);

  /// Checks if biometrics is supported and available on the device
  Future<bool> isBiometricsAvailable();

  /// Performs biometric authentication
  Future<bool> authenticateWithBiometrics();

  /// Increments the failed attempts and updates lockout time if necessary
  Future<void> recordFailedAttempt();

  /// Resets the failed attempts count
  Future<void> resetFailedAttempts();

  /// Checks if the user is currently locked out
  Future<bool> isLockedOut();

  /// Returns the remaining lockout duration in seconds
  Future<int> getRemainingLockoutSeconds();

  /// Deletes all auth-related data
  Future<void> clearAuthData();
}
