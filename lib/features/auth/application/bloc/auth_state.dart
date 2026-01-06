part of 'auth_cubit.dart';

/// Estados de autenticación
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial - verificando autenticación
class AuthInitial extends AuthState {}

/// Cargando / procesando autenticación
class AuthLoading extends AuthState {}

/// Primera vez - necesita configurar PIN
class AuthSetupRequired extends AuthState {}

/// Requiere autenticación (PIN o biométrico)
class AuthRequired extends AuthState {
  final bool biometricAvailable;
  final AuthMethod authMethod;

  const AuthRequired({
    required this.biometricAvailable,
    required this.authMethod,
  });

  @override
  List<Object?> get props => [biometricAvailable, authMethod];
}

/// PIN incorrecto
class AuthPinIncorrect extends AuthState {
  final int remainingAttempts;

  const AuthPinIncorrect({required this.remainingAttempts});

  @override
  List<Object?> get props => [remainingAttempts];
}

/// Cuenta bloqueada por demasiados intentos
class AuthLocked extends AuthState {
  final int remainingMinutes;
  final int failedAttempts;

  const AuthLocked({
    required this.remainingMinutes,
    required this.failedAttempts,
  });

  @override
  List<Object?> get props => [remainingMinutes, failedAttempts];
}

/// Biométrico bloqueado temporalmente
class AuthBiometricLocked extends AuthState {}

/// Autenticado exitosamente
class AuthAuthenticated extends AuthState {
  final bool biometricAvailable;
  final AuthMethod authMethod;

  const AuthAuthenticated({
    required this.biometricAvailable,
    required this.authMethod,
  });

  @override
  List<Object?> get props => [biometricAvailable, authMethod];
}

/// Error de autenticación
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
