import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/auth_service.dart';
import 'auth_state.dart';

import 'package:injectable/injectable.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService)
      : super(const AuthState());

  Future<void> checkAuth() async {
    emit(state.copyWith(status: AuthStatus.loading));

    final isPinSet = await _authService.isPinSet();
    final isBiometricAvailable = await _authService.isBiometricAvailable();

    if (!isPinSet) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        isPinSet: false,
        isBiometricAvailable: isBiometricAvailable,
      ));
      return;
    }

    emit(state.copyWith(
      status: AuthStatus.pinRequired,
      isPinSet: true,
      isBiometricAvailable: isBiometricAvailable,
    ));

    if (isBiometricAvailable) {
      await verifyBiometric();
    }
  }

  Future<void> submitPin(String pin) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await _authService.verifyPin(pin);

    if (result.success) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        lastAuthTime: DateTime.now(),
      ));
    } else {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: result.error ?? 'Authentication failed',
      ));
    }
  }

  Future<void> setPin(String pin) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await _authService.setPin(pin);

    if (result.success) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        isPinSet: true,
        lastAuthTime: DateTime.now(),
      ));
    } else {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: result.error ?? 'Failed to set pin',
      ));
    }
  }

  Future<void> verifyBiometric() async {
    emit(state.copyWith(status: AuthStatus.biometricPrompt));

    final result = await _authService.verifyBiometric();

    if (result.success) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        lastAuthTime: DateTime.now(),
      ));
    } else {
      emit(state.copyWith(
        status: AuthStatus.pinRequired,
        error: null,
      ));
    }
  }

  Future<void> logout() async {
    emit(state.copyWith(status: AuthStatus.unauthenticated));
  }

  Future<void> clearAuth() async {
    await _authService.clearAuth();
    emit(const AuthState(status: AuthStatus.unauthenticated, isPinSet: false));
  }
}
