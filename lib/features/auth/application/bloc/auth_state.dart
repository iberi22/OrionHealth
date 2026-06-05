import 'package:equatable/equatable.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthNotSetup extends AuthState {
  const AuthNotSetup();
}

class AuthLocked extends AuthState {
  final DateTime lockoutUntil;
  const AuthLocked(this.lockoutUntil);

  @override
  List<Object?> get props => [lockoutUntil];
}

class AuthUnauthenticated extends AuthState {
  final int failedAttempts;
  final String? errorMessage;
  const AuthUnauthenticated({this.failedAttempts = 0, this.errorMessage});

  @override
  List<Object?> get props => [failedAttempts, errorMessage];
}

class AuthAuthenticated extends AuthState {
  final DateTime sessionExpiry;
  const AuthAuthenticated(this.sessionExpiry);

  @override
  List<Object?> get props => [sessionExpiry];
}

class AuthLoading extends AuthState {
  const AuthLoading();
}
