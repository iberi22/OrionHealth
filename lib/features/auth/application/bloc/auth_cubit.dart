import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/auth_credentials.dart';
import '../../domain/entities/auth_credential.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/validate_session_usecase.dart';
import '../../domain/usecases/set_pin_usecase.dart';
import '../../infrastructure/services/biometric_service.dart';
import 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  final BiometricService _biometricService;
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final ValidateSessionUseCase _validateSessionUseCase;
  final SetPinUseCase _setPinUseCase;

  Timer? _sessionTimer;

  AuthCubit(
    this._repository,
    this._biometricService,
    this._loginUseCase,
    this._logoutUseCase,
    this._validateSessionUseCase,
    this._setPinUseCase,
  ) : super(AuthInitial());

  Future<void> checkStatus() async {
    final session = await _validateSessionUseCase();
    if (session != null) {
      _startSessionTimer(session.expiresAt);
      emit(AuthAuthenticated(session.expiresAt));
      return;
    }

    final credentials = await _repository.getCredentials();

    if (credentials == null || credentials.hashedPin == null) {
      emit(AuthNotSetup());
      return;
    }

    if (credentials.isLocked) {
      emit(AuthLocked(credentials.lockoutUntil!));
      return;
    }

    emit(const AuthUnauthenticated());
  }

  Future<void> setupPin(String pin) async {
    emit(AuthLoading());
    final success = await _setPinUseCase(pin);
    if (!success) {
       emit(const AuthUnauthenticated(errorMessage: 'PIN inválido'));
       return;
    }

    final session = await _loginUseCase(PinCredential(pin));
    if (session != null) {
      _startSessionTimer(session.expiresAt);
      emit(AuthAuthenticated(session.expiresAt));
    }
  }

  Future<void> loginWithPin(String pin) async {
    if (state is AuthLocked) {
      final lockedState = state as AuthLocked;
      if (DateTime.now().isBefore(lockedState.lockoutUntil)) return;
    }

    final session = await _loginUseCase(PinCredential(pin));

    if (session != null) {
      _startSessionTimer(session.expiresAt);
      emit(AuthAuthenticated(session.expiresAt));
    } else {
      final credentials = await _repository.getCredentials();
      if (credentials != null && credentials.isLocked) {
        emit(AuthLocked(credentials.lockoutUntil!));
      } else {
        emit(AuthUnauthenticated(
          failedAttempts: credentials?.failedAttempts ?? 0,
          errorMessage: 'PIN incorrecto',
        ));
      }
    }
  }

  Future<void> loginWithBiometrics() async {
    final session = await _loginUseCase(const BiometricCredential());
    if (session != null) {
      _startSessionTimer(session.expiresAt);
      emit(AuthAuthenticated(session.expiresAt));
    }
  }

  Future<void> toggleBiometrics(bool enabled) async {
    final credentials = await _repository.getCredentials();
    if (credentials == null) return;

    if (enabled) {
      final authenticated = await _biometricService.authenticate(
        localizedReason: 'Confirma tu identidad para habilitar biometría',
      );
      if (!authenticated) return;
    }

    credentials.biometricEnabled = enabled;
    await _repository.saveCredentials(credentials);
  }

  Future<void> logout() async {
    _sessionTimer?.cancel();
    await _logoutUseCase();
    emit(const AuthUnauthenticated());
  }

  void _startSessionTimer(DateTime expiresAt) {
    _sessionTimer?.cancel();
    final duration = expiresAt.difference(DateTime.now());
    if (duration.isNegative) {
      logout();
    } else {
      _sessionTimer = Timer(duration, () {
        logout();
      });
    }
  }

  @override
  Future<void> close() {
    _sessionTimer?.cancel();
    return super.close();
  }
}
