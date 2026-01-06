import 'package:isar/isar.dart';

part 'auth_credentials.g.dart';

/// Tipo de autenticación configurada por el usuario
enum AuthMethod {
  pin,
  biometric,
  both, // Biométrico con PIN como fallback
}

/// Credenciales de autenticación del usuario
/// Almacena el PIN hasheado y configuración de seguridad
@collection
class AuthCredentials {
  Id id = Isar.autoIncrement;

  /// PIN hasheado con salt (nunca se almacena en texto plano)
  String? pinHash;

  /// Salt único para el hash del PIN
  String? pinSalt;

  /// Método de autenticación preferido
  @enumerated
  AuthMethod authMethod = AuthMethod.pin;

  /// Si la autenticación biométrica está habilitada
  bool biometricEnabled = false;

  /// Número de intentos fallidos consecutivos
  int failedAttempts = 0;

  /// Timestamp del último intento fallido (para rate limiting)
  DateTime? lastFailedAttempt;

  /// Si la cuenta está bloqueada por demasiados intentos fallidos
  bool isLocked = false;

  /// Timestamp cuando se desbloqueará automáticamente
  DateTime? lockUntil;

  /// Fecha de creación de las credenciales
  DateTime createdAt = DateTime.now();

  /// Fecha de última modificación
  DateTime updatedAt = DateTime.now();

  /// Duración del timeout de sesión en minutos
  int sessionTimeoutMinutes = 5;

  /// Si requerir autenticación al volver del background
  bool requireAuthOnResume = true;

  AuthCredentials();

  /// Verifica si la cuenta está actualmente bloqueada
  bool get isCurrentlyLocked {
    if (!isLocked) return false;
    if (lockUntil == null) return true;
    if (DateTime.now().isAfter(lockUntil!)) {
      return false; // El bloqueo expiró
    }
    return true;
  }

  /// Minutos restantes de bloqueo
  int get lockRemainingMinutes {
    if (!isCurrentlyLocked || lockUntil == null) return 0;
    return lockUntil!.difference(DateTime.now()).inMinutes + 1;
  }

  /// Incrementa intentos fallidos y bloquea si es necesario
  void recordFailedAttempt() {
    failedAttempts++;
    lastFailedAttempt = DateTime.now();
    updatedAt = DateTime.now();

    // Bloquear después de 5 intentos fallidos
    if (failedAttempts >= 5) {
      isLocked = true;
      // Bloqueo progresivo: 1 min, 5 min, 15 min, 30 min, 1 hora
      final lockDurations = [1, 5, 15, 30, 60];
      final lockIndex = (failedAttempts - 5).clamp(0, lockDurations.length - 1);
      lockUntil = DateTime.now().add(
        Duration(minutes: lockDurations[lockIndex]),
      );
    }
  }

  /// Resetea los intentos fallidos después de autenticación exitosa
  void resetFailedAttempts() {
    failedAttempts = 0;
    lastFailedAttempt = null;
    isLocked = false;
    lockUntil = null;
    updatedAt = DateTime.now();
  }
}
