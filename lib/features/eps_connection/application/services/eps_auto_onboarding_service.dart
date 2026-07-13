import 'dart:async';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';
import 'package:orionhealth_health/features/eps_connection/infrastructure/mappers/fhir_to_profile_mapper.dart';
import 'package:orionhealth_health/features/eps_connection/infrastructure/repositories/local_fhir_oauth_repository.dart';
import 'package:orionhealth_health/features/eps_connection/infrastructure/services/ihce_api_client.dart';
import 'package:orionhealth_health/features/eps_connection/infrastructure/services/ihce_auth_service.dart';
import 'package:orionhealth_health/features/eps_connection/infrastructure/services/local_fhir_engine.dart';
import 'package:orionhealth_health/features/onboarding/domain/entities/user_profile.dart';

/// Resultado del auto-onboarding desde EPS.
enum EpsAutoOnboardingStatus {
  /// Conexión exitosa, perfil extraído completamente
  success,

  /// Conexión exitosa, pero algunos datos no estaban disponibles
  partialSuccess,

  /// Error de conexión con la EPS
  connectionError,

  /// Error de autenticación (credenciales inválidas)
  authError,

  /// La EPS respondió pero no se encontraron datos del paciente
  noDataFound,

  /// Timeout en la conexión
  timeout,
}

class EpsAutoOnboardingResult {
  final EpsAutoOnboardingStatus status;
  final UserProfile? profile;
  final String? errorMessage;
  final int? skippedSteps; // Cuántos pasos del onboarding se saltan
  final List<String>? missingFields; // Campos que faltaron en la EPS

  const EpsAutoOnboardingResult({
    required this.status,
    this.profile,
    this.errorMessage,
    this.skippedSteps,
    this.missingFields,
  });

  bool get isSuccess =>
      status == EpsAutoOnboardingStatus.success ||
      status == EpsAutoOnboardingStatus.partialSuccess;

  factory EpsAutoOnboardingResult.success(UserProfile profile, {int? skippedSteps}) =>
      EpsAutoOnboardingResult(
        status: EpsAutoOnboardingStatus.success,
        profile: profile,
        skippedSteps: skippedSteps,
      );

  factory EpsAutoOnboardingResult.partialSuccess(UserProfile profile, {
    required List<String> missingFields,
    int? skippedSteps,
  }) =>
      EpsAutoOnboardingResult(
        status: EpsAutoOnboardingStatus.partialSuccess,
        profile: profile,
        skippedSteps: skippedSteps,
        missingFields: missingFields,
      );

  factory EpsAutoOnboardingResult.error(EpsAutoOnboardingStatus status, String message) =>
      EpsAutoOnboardingResult(status: status, errorMessage: message);
}

/// 🚀 EPS Auto-Onboarding Service
///
/// Orquesta el flujo completo:
/// 1. Usuario selecciona su EPS del catálogo
/// 2. Se autentica vía OAuth2 Client Credentials (IHCE)
/// 3. Extrae TODOS los datos clínicos del paciente del IHCE
/// 4. Mapea FHIR → UserProfile de OrionHealth
/// 5. El perfil pre-poblado se entrega al OnboardingCubit
/// 6. El onboarding muestra los datos pre-llenados y salta pasos completos
///
/// Esto elimina la fricción del onboarding manual — el usuario solo
/// necesita hacer login con su EPS y la app se llena sola.
class EpsAutoOnboardingService {
  final LocalFhirOAuthRepository _repository;
  LocalFhirEngine? _engine;

  /// Stream para reportar progreso del auto-onboarding.
  final _progressController = StreamController<AutoOnboardingProgress>.broadcast();
  Stream<AutoOnboardingProgress> get progress => _progressController.stream;

  EpsAutoOnboardingService(this._repository);

  /// Ejecuta el flujo completo de auto-onboarding.
  ///
  /// [tipoDocumento] y [numeroDocumento] vienen del login con la EPS
  /// o los ingresa el usuario en el paso inicial.
  Future<EpsAutoOnboardingResult> autoOnboard({
    required EPSProvider provider,
    required String tipoDocumento,
    required String numeroDocumento,
  }) async {
    try {
      _reportProgress(AutoOnboardingProgress(
        stage: AutoOnboardingStage.connecting,
        message: 'Conectando con ${provider.name}...',
        progress: 0.1,
      ));

      // 1. Login con la EPS vía IHCE
      final loginResult = await _repository.login(provider);
      if (loginResult == null) {
        return EpsAutoOnboardingResult.error(
          EpsAutoOnboardingStatus.authError,
          'No se pudo autenticar con ${provider.name}',
        );
      }

      _reportProgress(AutoOnboardingProgress(
        stage: AutoOnboardingStage.authenticating,
        message: 'Autenticado. Consultando historial clínico...',
        progress: 0.3,
      ));

      // 2. Obtener el engine y extraer todos los datos
      final engine = await _repository.getEngine();

      _reportProgress(AutoOnboardingProgress(
        stage: AutoOnboardingStage.fetchingData,
        message: 'Extrayendo datos del IHCE...',
        progress: 0.4,
      ));

      // Escuchar estado de sync para UI
      engine.syncStatus.listen((status) {
        if (status is FhirSyncSyncing) {
          _reportProgress(AutoOnboardingProgress(
            stage: AutoOnboardingStage.fetchingData,
            message: 'Consultando historia clínica...',
            progress: 0.5,
          ));
        } else if (status is FhirSyncSynced) {
          _reportProgress(AutoOnboardingProgress(
            stage: AutoOnboardingStage.processing,
            message: 'Procesando datos clínicos...',
            progress: 0.7,
          ));
        }
      });

      // 3. Fetch completo de datos del paciente
      final clinicalData = await engine.fetchAllPatientData(
        tipoDocumento: tipoDocumento,
        numeroDocumento: numeroDocumento,
      );

      _reportProgress(AutoOnboardingProgress(
        stage: AutoOnboardingStage.processing,
        message: 'Mapeando datos a tu perfil de salud...',
        progress: 0.8,
      ));

      // 4. Mapear FHIR → UserProfile
      final profile = FhirToProfileMapper.transform(
        fhirData: clinicalData,
        epsConnectedId: provider.id,
        patientDocumentId: numeroDocumento,
      );

      // 5. Determinar qué pasos del onboarding se completaron automáticamente
      final analysis = _analyzeProfileCompleteness(profile);

      _reportProgress(AutoOnboardingProgress(
        stage: AutoOnboardingStage.complete,
        message: '¡Perfil cargado desde ${provider.name}!',
        progress: 1.0,
        details: '${analysis.skippedSteps} de 7 pasos completados automáticamente',
      ));

      if (analysis.isComplete) {
        return EpsAutoOnboardingResult.success(profile,
            skippedSteps: analysis.skippedSteps);
      } else {
        return EpsAutoOnboardingResult.partialSuccess(
          profile,
          missingFields: analysis.missingFields,
          skippedSteps: analysis.skippedSteps,
        );
      }
    } on IhceAuthException catch (e) {
      return EpsAutoOnboardingResult.error(
        EpsAutoOnboardingStatus.authError,
        'Error de autenticación: $e',
      );
    } on IhceApiException catch (e) {
      return EpsAutoOnboardingResult.error(
        EpsAutoOnboardingStatus.connectionError,
        'Error del IHCE (${e.statusCode}): $e',
      );
    } on TimeoutException {
      return EpsAutoOnboardingResult.error(
        EpsAutoOnboardingStatus.timeout,
        'La conexión con ${provider.name} excedió el tiempo límite',
      );
    } catch (e) {
      return EpsAutoOnboardingResult.error(
        EpsAutoOnboardingStatus.connectionError,
        'Error inesperado: $e',
      );
    }
  }

  /// Analiza qué campos del perfil se completaron vía EPS
  /// y cuáles requieren entrada manual del usuario.
  _ProfileCompletenessAnalysis _analyzeProfileCompleteness(UserProfile profile) {
    final missing = <String>[];
    int completedFields = 0;
    const totalFields = 5; // nombre, fecha, sexo, condiciones, medicamentos

    if (profile.name != null && profile.name!.isNotEmpty) completedFields++;
    else missing.add('Nombre completo');

    if (profile.birthDate != null) completedFields++;
    else missing.add('Fecha de nacimiento');

    if (profile.sex != null) completedFields++;
    else missing.add('Sexo');

    if (profile.conditions.isNotEmpty) completedFields++;
    else missing.add('Condiciones médicas');

    if (profile.medications.isNotEmpty) completedFields++;
    else missing.add('Medicamentos');

    // Calcular pasos saltados
    int skipped = 0;
    if (profile.name != null && profile.birthDate != null && profile.sex != null) skipped++; // BasicInfo
    if (profile.conditions.isNotEmpty) skipped++; // Conditions
    // FamilyHistory siempre se salta si viene del RDA (se extrae de antecedentes)
    if (profile.medications.isNotEmpty) skipped++; // Medications
    // Privacy siempre requiere confirmación explícita

    return _ProfileCompletenessAnalysis(
      isComplete: missing.isEmpty,
      skippedSteps: skipped,
      missingFields: missing,
      completedFields: completedFields,
      totalFields: totalFields,
    );
  }

  void _reportProgress(AutoOnboardingProgress progress) {
    _progressController.add(progress);
  }

  void dispose() {
    _progressController.close();
  }
}

/// Progreso del auto-onboarding para UI feedback.
enum AutoOnboardingStage {
  connecting,
  authenticating,
  fetchingData,
  processing,
  complete,
  error,
}

class AutoOnboardingProgress {
  final AutoOnboardingStage stage;
  final String message;
  final double progress;
  final String? details;

  const AutoOnboardingProgress({
    required this.stage,
    required this.message,
    required this.progress,
    this.details,
  });
}

class _ProfileCompletenessAnalysis {
  final bool isComplete;
  final int skippedSteps;
  final List<String> missingFields;
  final int completedFields;
  final int totalFields;

  const _ProfileCompletenessAnalysis({
    required this.isComplete,
    required this.skippedSteps,
    required this.missingFields,
    required this.completedFields,
    required this.totalFields,
  });
}
