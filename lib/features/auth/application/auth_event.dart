import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthPinSubmitted extends AuthEvent {
  final String pin;
  const AuthPinSubmitted(this.pin);

  @override
  List<Object?> get props => [pin];
}

class AuthPinSetRequested extends AuthEvent {
  final String pin;
  const AuthPinSetRequested(this.pin);

  @override
  List<Object?> get props => [pin];
}

class AuthBiometricRequested extends AuthEvent {}

class AuthLogoutRequested extends AuthEvent {}

class AuthClearRequested extends AuthEvent {}
