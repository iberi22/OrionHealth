import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/auth_credentials.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../infrastructure/services/encryption_service.dart';
import '../../infrastructure/services/biometric_service.dart';
import 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  final EncryptionService _encryptionService;
  final BiometricService _biometricService;

  Timer? _sessionTimer;
  static const int sessionTimeoutMinutes = 15;

  AuthCubit(
    this._repository,
    this._encryptionService,
    this._biometricService,
  ) : super(AuthInitial());

  Future<void> checkStatus() async {
    final credentials = await _repository.getCredentials();

    if (credentials == null || credentials.hashedPin == null) {
      emit(AuthNotSetup());
      return;
    }

    if (credentials.lastLockoutTime != null) {
      final lockoutDuration = _getLockoutDuration(credentials.failedAttempts);
      final lockoutUntil = credentials.lastLockoutTime!.add(lockoutDuration);

      if (DateTime.now().isBefore(lockoutUntil)) {
        emit(AuthLocked(lockoutUntil));
        return;
      }
    }

    emit(const AuthUnauthenticated());
  }

  Future<void> setupPin(String pin) async {
    emit(AuthLoading());
    final salt = const Uuid().v4();
    final hashedPin = await _encryptionService.hashPin(pin, salt);

    final credentials = AuthCredentials()
      ..hashedPin = hashedPin
      ..salt = salt
      ..biometricEnabled = false
      ..failedAttempts = 0;

    await _repository.saveCredentials(credentials);
    _startSession();
  }

  Future<void> loginWithPin(String pin) async {
    final credentials = await _repository.getCredentials();
    if (credentials == null) return;

    if (state is AuthLocked) {
      final lockedState = state as AuthLocked;
      if (DateTime.now().isBefore(lockedState.lockoutUntil)) return;
    }

    final hashedInput = await _encryptionService.hashPin(pin, credentials.salt!);

    if (hashedInput == credentials.hashedPin) {
      credentials.failedAttempts = 0;
      credentials.lastLockoutTime = null;
      await _repository.saveCredentials(credentials);
      _startSession();
    } else {
      credentials.failedAttempts++;
      if (credentials.failedAttempts >= 5) {
        credentials.lastLockoutTime = DateTime.now();
        final lockoutDuration = _getLockoutDuration(credentials.failedAttempts);
        final lockoutUntil = credentials.lastLockoutTime!.add(lockoutDuration);
        await _repository.saveCredentials(credentials);
        emit(AuthLocked(lockoutUntil));
      } else {
        await _repository.saveCredentials(credentials);
        emit(AuthUnauthenticated(
          failedAttempts: credentials.failedAttempts,
          errorMessage: 'pin incorrecto',
        ));
      }
    }
  }

  Future<void> loginWithBiometrics() async {
    final credentials = await _repository.getCredentials();
    if (credentials == null || !credentials.biometricEnabled) return;

    final authenticated = await _biometricService.authenticate(
      localizedReason: 'Autentícate para acceder a tus datos médicos',
    );

    if (authenticated) {
      _startSession();
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

  void logout() {
    _sessionTimer?.cancel();
    emit(const AuthUnauthenticated());
  }

  void _startSession() {
    final expiry = DateTime.now().add(const Duration(minutes: sessionTimeoutMinutes));
    emit(AuthAuthenticated(expiry));

    _sessionTimer?.cancel();
    _sessionTimer = Timer(const Duration(minutes: sessionTimeoutMinutes), () {
      logout();
    });
  }

  Duration _getLockoutDuration(int failedAttempts) {
    if (failedAttempts >= 10) return const Duration(minutes: 60);
    if (failedAttempts >= 9) return const Duration(minutes: 30);
    if (failedAttempts >= 8) return const Duration(minutes: 15);
    if (failedAttempts >= 7) return const Duration(minutes: 5);
    if (failedAttempts >= 5) return const Duration(minutes: 1);
    return Duration.zero;
  }

  @override
  Future<void> close() {
    _sessionTimer?.cancel();
    return super.close();
  }
}
