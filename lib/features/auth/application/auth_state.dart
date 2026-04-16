import 'package:equatable/equatable.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  pinRequired,
  biometricPrompt,
  loading,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String? error;
  final bool isPinSet;
  final bool isBiometricAvailable;
  final DateTime? lastAuthTime;

  const AuthState({
    this.status = AuthStatus.initial,
    this.error,
    this.isPinSet = false,
    this.isBiometricAvailable = false,
    this.lastAuthTime,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? error,
    bool? isPinSet,
    bool? isBiometricAvailable,
    DateTime? lastAuthTime,
  }) {
    return AuthState(
      status: status ?? this.status,
      error: error,
      isPinSet: isPinSet ?? this.isPinSet,
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
      lastAuthTime: lastAuthTime ?? this.lastAuthTime,
    );
  }

  @override
  List<Object?> get props => [status, error, isPinSet, isBiometricAvailable, lastAuthTime];
}
