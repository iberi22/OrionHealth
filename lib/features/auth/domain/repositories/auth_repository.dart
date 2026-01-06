import '../entities/auth_credentials.dart';

/// Repositorio para gestionar credenciales de autenticación
abstract class AuthRepository {
  /// Obtiene las credenciales guardadas (si existen)
  Future<AuthCredentials?> getCredentials();

  /// Guarda las credenciales de autenticación
  Future<void> saveCredentials(AuthCredentials credentials);

  /// Verifica si el usuario ha configurado autenticación
  Future<bool> hasSetupAuth();

  /// Elimina todas las credenciales (reset completo)
  Future<void> clearCredentials();

  /// Actualiza solo el método de autenticación preferido
  Future<void> updateAuthMethod(AuthMethod method);

  /// Habilita/deshabilita autenticación biométrica
  Future<void> setBiometricEnabled(bool enabled);

  /// Registra un intento fallido
  Future<void> recordFailedAttempt();

  /// Resetea intentos fallidos después de login exitoso
  Future<void> resetFailedAttempts();

  /// Actualiza el timeout de sesión
  Future<void> updateSessionTimeout(int minutes);
}
