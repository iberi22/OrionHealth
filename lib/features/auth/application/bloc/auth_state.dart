import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

/// State when no PIN has been set up yet
class AuthNoPinSet extends AuthState {}

/// State when the user is unauthenticated (needs to enter PIN or use biometrics)
class AuthUnauthenticated extends AuthState {
  final bool isBiometricsAvailable;
  final String? error;

  const AuthUnauthenticated({
    this.isBiometricsAvailable = false,
    this.error,
  });

  @override
  List<Object?> get props => [isBiometricsAvailable, error];
}

/// State when the user is locked out due to too many failed attempts
class AuthLocked extends AuthState {
  final int remainingSeconds;

  const AuthLocked(this.remainingSeconds);

  @override
  List<Object?> get props => [remainingSeconds];
}

/// State when the user is successfully authenticated
class AuthAuthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
