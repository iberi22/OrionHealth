import '../../domain/entities/auth_credentials.dart';
import '../../domain/entities/auth_user.dart';

class AuthUserDto {
  final String id;
  final String email;
  final String role;

  const AuthUserDto({
    required this.id,
    required this.email,
    required this.role,
  });

  factory AuthUserDto.fromEntity(AuthUser entity) {
    return AuthUserDto(
      id: entity.id,
      email: entity.email,
      role: entity.role,
    );
  }

  AuthUser toEntity() {
    return AuthUser(
      id: id,
      email: email,
      role: role,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
    };
  }

  factory AuthUserDto.fromJson(Map<String, dynamic> json) {
    return AuthUserDto(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }
}

class AuthCredentialsDto {
  final int? id;
  final String? hashedPin;
  final String? salt;
  final bool biometricEnabled;
  final DateTime? lastLockoutTime;
  final int failedAttempts;

  const AuthCredentialsDto({
    this.id,
    this.hashedPin,
    this.salt,
    this.biometricEnabled = false,
    this.lastLockoutTime,
    this.failedAttempts = 0,
  });

  factory AuthCredentialsDto.fromEntity(AuthCredentials entity) {
    return AuthCredentialsDto(
      id: entity.id,
      hashedPin: entity.hashedPin,
      salt: entity.salt,
      biometricEnabled: entity.biometricEnabled,
      lastLockoutTime: entity.lastLockoutTime,
      failedAttempts: entity.failedAttempts,
    );
  }

  AuthCredentials toEntity() {
    return AuthCredentials()
      ..id = id ?? 0
      ..hashedPin = hashedPin
      ..salt = salt
      ..biometricEnabled = biometricEnabled
      ..lastLockoutTime = lastLockoutTime
      ..failedAttempts = failedAttempts;
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'hashedPin': hashedPin,
      'salt': salt,
      'biometricEnabled': biometricEnabled,
      'lastLockoutTime': lastLockoutTime?.toIso8601String(),
      'failedAttempts': failedAttempts,
    };
  }

  factory AuthCredentialsDto.fromJson(Map<String, dynamic> json) {
    return AuthCredentialsDto(
      id: json['id'] as int?,
      hashedPin: json['hashedPin'] as String?,
      salt: json['salt'] as String?,
      biometricEnabled: json['biometricEnabled'] as bool? ?? false,
      lastLockoutTime: json['lastLockoutTime'] != null
          ? DateTime.parse(json['lastLockoutTime'] as String)
          : null,
      failedAttempts: json['failedAttempts'] as int? ?? 0,
    );
  }
}
