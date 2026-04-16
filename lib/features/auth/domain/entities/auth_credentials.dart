import 'package:isar/isar.dart';

part 'auth_credentials.g.dart';

@collection
class AuthCredentials {
  Id id = Isar.autoIncrement;

  /// Argon2id hashed PIN
  String? hashedPin;

  /// Salt used for PIN hashing
  String? salt;

  /// Whether biometric authentication is enabled
  bool isBiometricsEnabled;

  /// Number of consecutive failed PIN attempts
  int failedAttempts;

  /// Timestamp until which the user is locked out
  DateTime? lockoutUntil;

  AuthCredentials({
    this.hashedPin,
    this.salt,
    this.isBiometricsEnabled = false,
    this.failedAttempts = 0,
    this.lockoutUntil,
  });

  AuthCredentials copyWith({
    String? hashedPin,
    String? salt,
    bool? isBiometricsEnabled,
    int? failedAttempts,
    DateTime? lockoutUntil,
  }) {
    return AuthCredentials(
      hashedPin: hashedPin ?? this.hashedPin,
      salt: salt ?? this.salt,
      isBiometricsEnabled: isBiometricsEnabled ?? this.isBiometricsEnabled,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lockoutUntil: lockoutUntil ?? this.lockoutUntil,
    )..id = this.id;
  }
}
