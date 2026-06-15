import '../../domain/entities/auth_credentials.dart';

class AuthCredentialsDto {
  final String? hashedPin;
  final bool biometricEnabled;
  final String? sessionToken;

  const AuthCredentialsDto({this.hashedPin, required this.biometricEnabled, this.sessionToken});

  factory AuthCredentialsDto.fromEntity(AuthCredentials e) => AuthCredentialsDto(
    hashedPin: e.hashedPin, biometricEnabled: e.biometricEnabled, sessionToken: e.sessionToken,
  );

  AuthCredentials toEntity() => AuthCredentials(
    hashedPin: hashedPin, biometricEnabled: biometricEnabled, sessionToken: sessionToken,
  );

  Map<String, dynamic> toJson() => {
    if (hashedPin != null) 'hashedPin': hashedPin,
    'biometricEnabled': biometricEnabled,
    if (sessionToken != null) 'sessionToken': sessionToken,
  };

  factory AuthCredentialsDto.fromJson(Map<String, dynamic> j) => AuthCredentialsDto(
    hashedPin: j['hashedPin'] as String?, biometricEnabled: j['biometricEnabled'] as bool? ?? false,
    sessionToken: j['sessionToken'] as String?,
  );
}
