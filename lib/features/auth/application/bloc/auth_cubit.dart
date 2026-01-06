import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/auth_credentials.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../infrastructure/services/biometric_service.dart';
import '../../infrastructure/services/encryption_service.dart';

part 'auth_state.dart';

/// Cubit para gestionar el estado de autenticación
@injectable
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final EncryptionService _encryptionService;
  final BiometricService _biometricService;

  DateTime? _lastActivityTime;

  AuthCubit(
    this._authRepository,
    this._encryptionService,
    this._biometricService,
  ) : super(AuthInitial());

  /// Verifica el estado de autenticación al iniciar la app
  Future<void> checkAuthStatus() async {
    emit(AuthLoading());

    try {
      final hasSetup = await _authRepository.hasSetupAuth();

      if (!hasSetup) {
        // Primera vez - necesita configurar PIN
        emit(AuthSetupRequired());
        return;
      }

      final credentials = await _authRepository.getCredentials();
      if (credentials == null) {
        emit(AuthSetupRequired());
        return;
      }

      // Verificar si está bloqueado
      if (credentials.isCurrentlyLocked) {
        emit(
          AuthLocked(
            remainingMinutes: credentials.lockRemainingMinutes,
            failedAttempts: credentials.failedAttempts,
          ),
        );
        return;
      }

      // Verificar biométrico disponible
      final biometricAvailable = await _biometricService
          .hasBiometricsEnrolled();

      emit(
        AuthRequired(
          biometricAvailable:
              biometricAvailable && credentials.biometricEnabled,
          authMethod: credentials.authMethod,
        ),
      );
    } catch (e) {
      emit(AuthError('Error verificando autenticación: $e'));
    }
  }

  /// Configura el PIN por primera vez
  Future<void> setupPin(String pin) async {
    emit(AuthLoading());

    try {
      // Generar salt y hash del PIN
      final salt = await _encryptionService.generatePinSalt();
      final pinHash = await _encryptionService.hashPin(pin, salt);

      // Verificar si biométrico está disponible
      final biometricAvailable = await _biometricService
          .hasBiometricsEnrolled();

      // Crear credenciales
      final credentials = AuthCredentials()
        ..pinHash = pinHash
        ..pinSalt = salt
        ..biometricEnabled = false
        ..authMethod = AuthMethod.pin
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      await _authRepository.saveCredentials(credentials);

      // Inicializar encriptación
      await _encryptionService.initialize();

      _lastActivityTime = DateTime.now();
      emit(
        AuthAuthenticated(
          biometricAvailable: biometricAvailable,
          authMethod: AuthMethod.pin,
        ),
      );
    } catch (e) {
      emit(AuthError('Error configurando PIN: $e'));
    }
  }

  /// Autentica con PIN
  Future<void> authenticateWithPin(String pin) async {
    emit(AuthLoading());

    try {
      final credentials = await _authRepository.getCredentials();
      if (credentials == null) {
        emit(AuthSetupRequired());
        return;
      }

      // Verificar bloqueo
      if (credentials.isCurrentlyLocked) {
        emit(
          AuthLocked(
            remainingMinutes: credentials.lockRemainingMinutes,
            failedAttempts: credentials.failedAttempts,
          ),
        );
        return;
      }

      // Verificar PIN
      final isValid = await _encryptionService.verifyPin(
        pin,
        credentials.pinHash!,
        credentials.pinSalt!,
      );

      if (isValid) {
        await _authRepository.resetFailedAttempts();
        _lastActivityTime = DateTime.now();

        final biometricAvailable = await _biometricService
            .hasBiometricsEnrolled();

        emit(
          AuthAuthenticated(
            biometricAvailable:
                biometricAvailable && credentials.biometricEnabled,
            authMethod: credentials.authMethod,
          ),
        );
      } else {
        await _authRepository.recordFailedAttempt();
        final updatedCredentials = await _authRepository.getCredentials();

        if (updatedCredentials?.isCurrentlyLocked ?? false) {
          emit(
            AuthLocked(
              remainingMinutes: updatedCredentials!.lockRemainingMinutes,
              failedAttempts: updatedCredentials.failedAttempts,
            ),
          );
        } else {
          emit(
            AuthPinIncorrect(
              remainingAttempts: 5 - (updatedCredentials?.failedAttempts ?? 0),
            ),
          );
        }
      }
    } catch (e) {
      emit(AuthError('Error de autenticación: $e'));
    }
  }

  /// Autentica con biométrico
  Future<void> authenticateWithBiometric() async {
    emit(AuthLoading());

    try {
      final credentials = await _authRepository.getCredentials();
      if (credentials == null || !credentials.biometricEnabled) {
        emit(AuthError('Autenticación biométrica no configurada'));
        return;
      }

      final result = await _biometricService.authenticate(
        reason: 'Verifica tu identidad para acceder a OrionHealth',
      );

      switch (result) {
        case BiometricResult.success:
          await _authRepository.resetFailedAttempts();
          _lastActivityTime = DateTime.now();
          emit(
            AuthAuthenticated(
              biometricAvailable: true,
              authMethod: credentials.authMethod,
            ),
          );
          break;

        case BiometricResult.cancelled:
          final biometricAvailable = await _biometricService
              .hasBiometricsEnrolled();
          emit(
            AuthRequired(
              biometricAvailable: biometricAvailable,
              authMethod: credentials.authMethod,
            ),
          );
          break;

        case BiometricResult.lockedOut:
          emit(AuthBiometricLocked());
          break;

        case BiometricResult.notAvailable:
        case BiometricResult.notEnrolled:
          await _authRepository.setBiometricEnabled(false);
          emit(
            AuthRequired(biometricAvailable: false, authMethod: AuthMethod.pin),
          );
          break;

        default:
          emit(AuthError('Error de autenticación biométrica'));
      }
    } catch (e) {
      emit(AuthError('Error: $e'));
    }
  }

  /// Habilita autenticación biométrica
  Future<void> enableBiometric() async {
    try {
      final result = await _biometricService.authenticate(
        reason: 'Confirma tu identidad para habilitar biométricos',
      );

      if (result == BiometricResult.success) {
        await _authRepository.setBiometricEnabled(true);
        emit(
          AuthAuthenticated(
            biometricAvailable: true,
            authMethod: AuthMethod.both,
          ),
        );
      }
    } catch (e) {
      emit(AuthError('Error habilitando biométrico: $e'));
    }
  }

  /// Deshabilita autenticación biométrica
  Future<void> disableBiometric() async {
    await _authRepository.setBiometricEnabled(false);
    final credentials = await _authRepository.getCredentials();
    emit(
      AuthAuthenticated(
        biometricAvailable: false,
        authMethod: credentials?.authMethod ?? AuthMethod.pin,
      ),
    );
  }

  /// Cambia el PIN
  Future<void> changePin(String currentPin, String newPin) async {
    emit(AuthLoading());

    try {
      final credentials = await _authRepository.getCredentials();
      if (credentials == null) {
        emit(AuthError('No hay credenciales configuradas'));
        return;
      }

      // Verificar PIN actual
      final isValid = await _encryptionService.verifyPin(
        currentPin,
        credentials.pinHash!,
        credentials.pinSalt!,
      );

      if (!isValid) {
        emit(AuthPinIncorrect(remainingAttempts: -1));
        return;
      }

      // Generar nuevo hash
      final newSalt = await _encryptionService.generatePinSalt();
      final newHash = await _encryptionService.hashPin(newPin, newSalt);

      credentials
        ..pinHash = newHash
        ..pinSalt = newSalt;

      await _authRepository.saveCredentials(credentials);

      emit(
        AuthAuthenticated(
          biometricAvailable: credentials.biometricEnabled,
          authMethod: credentials.authMethod,
        ),
      );
    } catch (e) {
      emit(AuthError('Error cambiando PIN: $e'));
    }
  }

  /// Verifica si la sesión ha expirado (llamar en app lifecycle)
  Future<void> checkSessionTimeout() async {
    if (_lastActivityTime == null) {
      await checkAuthStatus();
      return;
    }

    final credentials = await _authRepository.getCredentials();
    if (credentials == null) return;

    final timeoutDuration = Duration(
      minutes: credentials.sessionTimeoutMinutes,
    );
    final elapsed = DateTime.now().difference(_lastActivityTime!);

    if (elapsed > timeoutDuration && credentials.requireAuthOnResume) {
      _lastActivityTime = null;

      final biometricAvailable = await _biometricService
          .hasBiometricsEnrolled();

      emit(
        AuthRequired(
          biometricAvailable:
              biometricAvailable && credentials.biometricEnabled,
          authMethod: credentials.authMethod,
        ),
      );
    }
  }

  /// Registra actividad del usuario (para timeout)
  void recordActivity() {
    _lastActivityTime = DateTime.now();
  }

  /// Cierra sesión (vuelve a requerir autenticación)
  Future<void> lockApp() async {
    _lastActivityTime = null;
    await checkAuthStatus();
  }

  /// Elimina todas las credenciales y datos seguros
  Future<void> resetAllAuth() async {
    await _authRepository.clearCredentials();
    await _encryptionService.clearAllSecureData();
    emit(AuthSetupRequired());
  }
}
