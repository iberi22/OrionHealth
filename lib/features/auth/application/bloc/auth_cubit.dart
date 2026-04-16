import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  Timer? _lockoutTimer;
  Timer? _sessionTimer;
  static const Duration _sessionTimeout = Duration(minutes: 15);

  AuthCubit(this._authRepository) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final credentials = await _authRepository.getCredentials();
      if (credentials == null || credentials.hashedPin == null) {
        emit(AuthNoPinSet());
      } else {
        final isLocked = await _authRepository.isLockedOut();
        if (isLocked) {
          _startLockoutTimer();
        } else {
          final biometricsAvailable = await _authRepository.isBiometricsAvailable() &&
              credentials.isBiometricsEnabled;
          emit(AuthUnauthenticated(isBiometricsAvailable: biometricsAvailable));
        }
      }
    } catch (e) {
      emit(AuthError('Error al verificar el estado de autenticación: $e'));
    }
  }

  Future<void> setupPin(String pin) async {
    emit(AuthLoading());
    try {
      await _authRepository.setupPin(pin);
      emit(AuthAuthenticated());
      _startSessionTimer();
    } catch (e) {
      emit(AuthError('Error al configurar el PIN: $e'));
    }
  }

  Future<void> loginWithPin(String pin) async {
    if (state is AuthLoading) return;

    emit(AuthLoading());
    try {
      final isValid = await _authRepository.verifyPin(pin);
      if (isValid) {
        emit(AuthAuthenticated());
        _startSessionTimer();
      } else {
        final isLocked = await _authRepository.isLockedOut();
        if (isLocked) {
          _startLockoutTimer();
        } else {
          final credentials = await _authRepository.getCredentials();
          final biometricsAvailable = await _authRepository.isBiometricsAvailable() &&
              (credentials?.isBiometricsEnabled ?? false);
          emit(AuthUnauthenticated(
            isBiometricsAvailable: biometricsAvailable,
            error: 'PIN incorrecto',
          ));
        }
      }
    } catch (e) {
      emit(AuthError('Error al iniciar sesión: $e'));
    }
  }

  Future<void> loginWithBiometrics() async {
    if (state is AuthLoading) return;

    try {
      final authenticated = await _authRepository.authenticateWithBiometrics();
      if (authenticated) {
        emit(AuthAuthenticated());
        _startSessionTimer();
      }
    } catch (e) {
      // Don't emit error state for biometric failure, just stay in unauthenticated
      print('Error en biometría: $e');
    }
  }

  void _startLockoutTimer() async {
    _lockoutTimer?.cancel();
    final remainingSeconds = await _authRepository.getRemainingLockoutSeconds();
    if (remainingSeconds > 0) {
      emit(AuthLocked(remainingSeconds));
      _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        final remaining = await _authRepository.getRemainingLockoutSeconds();
        if (remaining <= 0) {
          timer.cancel();
          checkAuthStatus();
        } else {
          emit(AuthLocked(remaining));
        }
      });
    } else {
      checkAuthStatus();
    }
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer(_sessionTimeout, () {
      logout();
    });
  }

  void resetSessionTimer() {
    if (state is AuthAuthenticated) {
      _startSessionTimer();
    }
  }

  Future<void> logout() async {
    _sessionTimer?.cancel();
    final credentials = await _authRepository.getCredentials();
    final biometricsAvailable = await _authRepository.isBiometricsAvailable() &&
        (credentials?.isBiometricsEnabled ?? false);
    emit(AuthUnauthenticated(isBiometricsAvailable: biometricsAvailable));
  }

  @override
  Future<void> close() {
    _lockoutTimer?.cancel();
    _sessionTimer?.cancel();
    return super.close();
  }
}
