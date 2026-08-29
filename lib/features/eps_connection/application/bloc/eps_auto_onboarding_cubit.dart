import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';
import 'package:orionhealth_health/features/eps_connection/application/services/eps_auto_onboarding_service.dart';
import 'package:orionhealth_health/features/onboarding/domain/entities/user_profile.dart';

// ─── STATES ──────────────────────────────────────────────────────────────────

abstract class EpsAutoOnboardingState extends Equatable {
  const EpsAutoOnboardingState();
  @override
  List<Object?> get props => [];
}

/// Estado inicial — el usuario aún no ha iniciado el auto-onboarding.
class EpsAutoOnboardingInitial extends EpsAutoOnboardingState {
  const EpsAutoOnboardingInitial();
}

/// Conectando con la EPS vía IHCE.
class EpsAutoOnboardingConnecting extends EpsAutoOnboardingState {
  final String providerName;
  final double progress;
  final String message;

  const EpsAutoOnboardingConnecting({
    required this.providerName,
    this.progress = 0.1,
    this.message = 'Conectando...',
  });

  @override
  List<Object?> get props => [providerName, progress, message];
}

/// Extrayendo datos del IHCE.
class EpsAutoOnboardingFetching extends EpsAutoOnboardingState {
  final String message;
  final double progress;

  const EpsAutoOnboardingFetching({
    required this.message,
    required this.progress,
  });

  @override
  List<Object?> get props => [message, progress];
}

/// Procesando y mapeando datos al perfil.
class EpsAutoOnboardingProcessing extends EpsAutoOnboardingState {
  final double progress;

  const EpsAutoOnboardingProcessing({this.progress = 0.8});

  @override
  List<Object?> get props => [progress];
}

/// ✅ Auto-onboarding exitoso — perfil completo o parcial.
class EpsAutoOnboardingSuccess extends EpsAutoOnboardingState {
  final UserProfile profile;
  final bool isComplete; // true = todos los datos, false = algunos faltan
  final List<String> missingFields;
  final int skippedSteps;

  const EpsAutoOnboardingSuccess({
    required this.profile,
    required this.isComplete,
    this.missingFields = const [],
    required this.skippedSteps,
  });

  @override
  List<Object?> get props => [profile, isComplete, missingFields, skippedSteps];
}

/// ❌ Error en el auto-onboarding.
class EpsAutoOnboardingError extends EpsAutoOnboardingState {
  final String message;
  final EpsAutoOnboardingStatus errorStatus;
  final bool canRetry;

  const EpsAutoOnboardingError({
    required this.message,
    required this.errorStatus,
    this.canRetry = true,
  });

  @override
  List<Object?> get props => [message, errorStatus, canRetry];
}

// ─── CUBIT ───────────────────────────────────────────────────────────────────

class EpsAutoOnboardingCubit extends Cubit<EpsAutoOnboardingState> {
  final EpsAutoOnboardingService _service;

  EpsAutoOnboardingCubit(this._service)
    : super(const EpsAutoOnboardingInitial());

  /// Inicia el auto-onboarding con una EPS.
  ///
  /// [provider] — la EPS seleccionada del catálogo
  /// [tipoDocumento] — CC, TI, CE, etc.
  /// [numeroDocumento] — número de documento del paciente
  Future<void> start({
    required EPSProvider provider,
    required String tipoDocumento,
    required String numeroDocumento,
  }) async {
    emit(
      EpsAutoOnboardingConnecting(
        providerName: provider.name,
        message: 'Conectando con ${provider.name} vía IHCE Minsalud...',
      ),
    );

    // Escuchar progreso del servicio
    _service.progress.listen((progress) {
      switch (progress.stage) {
        case AutoOnboardingStage.connecting:
        case AutoOnboardingStage.authenticating:
          emit(
            EpsAutoOnboardingConnecting(
              providerName: provider.name,
              message: progress.message,
              progress: progress.progress,
            ),
          );
          break;
        case AutoOnboardingStage.fetchingData:
          emit(
            EpsAutoOnboardingFetching(
              message: progress.message,
              progress: progress.progress,
            ),
          );
          break;
        case AutoOnboardingStage.processing:
        case AutoOnboardingStage.complete:
          emit(EpsAutoOnboardingProcessing(progress: progress.progress));
          break;
        case AutoOnboardingStage.error:
          break;
      }
    });

    final result = await _service.autoOnboard(
      provider: provider,
      tipoDocumento: tipoDocumento,
      numeroDocumento: numeroDocumento,
    );

    switch (result.status) {
      case EpsAutoOnboardingStatus.success:
        emit(
          EpsAutoOnboardingSuccess(
            profile: result.profile!,
            isComplete: true,
            skippedSteps: result.skippedSteps ?? 0,
          ),
        );
        break;
      case EpsAutoOnboardingStatus.partialSuccess:
        emit(
          EpsAutoOnboardingSuccess(
            profile: result.profile!,
            isComplete: false,
            missingFields: result.missingFields ?? [],
            skippedSteps: result.skippedSteps ?? 0,
          ),
        );
        break;
      case EpsAutoOnboardingStatus.connectionError:
      case EpsAutoOnboardingStatus.timeout:
        emit(
          EpsAutoOnboardingError(
            message: result.errorMessage ?? 'Error de conexión',
            errorStatus: result.status,
            canRetry: true,
          ),
        );
        break;
      case EpsAutoOnboardingStatus.authError:
        emit(
          EpsAutoOnboardingError(
            message: result.errorMessage ?? 'Error de autenticación',
            errorStatus: result.status,
            canRetry: false,
          ),
        );
        break;
      case EpsAutoOnboardingStatus.noDataFound:
        emit(
          EpsAutoOnboardingError(
            message:
                'No se encontraron datos clínicos en ${provider.name}. Verifica tu documento.',
            errorStatus: result.status,
            canRetry: true,
          ),
        );
        break;
    }
  }

  /// Reinicia el estado para intentar de nuevo.
  void reset() {
    emit(const EpsAutoOnboardingInitial());
  }
}
