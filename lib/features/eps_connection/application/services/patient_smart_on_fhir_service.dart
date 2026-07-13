import 'dart:async';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/oauth_token.dart';
import 'package:orionhealth_health/features/eps_connection/infrastructure/services/smart_on_fhir_client.dart';
import 'package:orionhealth_health/features/onboarding/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/eps_connection/infrastructure/mappers/fhir_to_profile_mapper.dart';
import 'package:orionhealth_health/features/eps_connection/infrastructure/services/local_fhir_engine.dart';
import 'package:orionhealth_health/features/eps_connection/infrastructure/services/ihce_api_client.dart';
import 'package:orionhealth_health/features/eps_connection/infrastructure/services/ihce_auth_service.dart';

/// Pasos del flujo de login como paciente.
enum PatientLoginStep {
  /// Iniciando — construyendo URL de autorización
  starting,

  /// Esperando que el paciente se autentique en el navegador
  waitingForBrowser,

  /// Recibiendo callback de la EPS con authorization code
  receivingCallback,

  /// Intercambiando code por token
  exchangingToken,

  /// Consultando datos FHIR del paciente
  fetchingData,

  /// Mapeando FHIR → perfil de OrionHealth
  buildingProfile,

  /// Listo — perfil cargado
  complete,

  /// Error
  error,
}

/// Progreso del login del paciente para UI.
class PatientLoginProgress {
  final PatientLoginStep step;
  final String message;
  final double progress;
  final String? epsName;

  const PatientLoginProgress({
    required this.step,
    required this.message,
    required this.progress,
    this.epsName,
  });
}

/// 🚀 Paciente Smart on FHIR Service — Login del paciente.
///
/// A DIFERENCIA del flujo de prestador (Client Credentials), este flujo
/// permite que un PACIENTE se autentique con sus propias credenciales
/// de la EPS y autorice a OrionHealth a acceder a sus datos.
///
/// Esto es lo que el paciente hace hoy manualmente:
/// 1. Entra a misura.com o app MiSURA
/// 2. Se loguea con su usuario y contraseña
/// 3. Ve sus citas, medicamentos, historia clínica
///
/// Con OrionHealth, automatizamos todo eso y además consolidamos
/// datos de TODAS las EPS en una sola app.
///
/// Flujo para el paciente:
/// ```
/// 1. Abre OrionHealth
/// 2. Selecciona su EPS (ej: SURA)
/// 3. La app abre el navegador → portal.sura.com/login
/// 4. El paciente ingresa su usuario y contraseña de SURA
/// 5. SURA pregunta: "¿Autorizas a OrionHealth a acceder a tus datos?"
/// 6. El paciente acepta
/// 7. SURA redirige a OrionHealth con un token
/// 8. OrionHealth descarga todos los datos del paciente
/// 9. Perfil listo — sin llenar formularios
/// ```
class PatientSmartOnFhirService {
  final SmartOnFhirClient? _smartClient;
  SmartOnFhirAuthUrl? _pendingAuth;

  final _progressController = StreamController<PatientLoginProgress>.broadcast();
  Stream<PatientLoginProgress> get progress => _progressController.stream;

  PatientSmartOnFhirService({SmartOnFhirClient? smartClient})
      : _smartClient = smartClient;

  /// Paso 1: Iniciar el login. Retorna la URL que se debe abrir en el navegador.
  ///
  /// [provider] — la EPS seleccionada por el paciente del catálogo
  Future<SmartOnFhirAuthUrl> startLogin(EPSProvider provider) async {
    _reportProgress(PatientLoginProgress(
      step: PatientLoginStep.starting,
      message: 'Preparando conexión segura con ${provider.name}...',
      progress: 0.05,
      epsName: provider.name,
    ));

    // Intentar descubrir configuración SMART on FHIR de la EPS
    final config = await SmartOnFhirClient.discoverConfig(provider.discoveryUrl);

    final client = _smartClient ?? SmartOnFhirClient(
      fhirBaseUrl: provider.discoveryUrl,
      tokenEndpoint: config?.tokenEndpoint ?? '${provider.discoveryUrl}/auth/token',
      authorizeEndpoint: config?.authorizeEndpoint ?? '${provider.discoveryUrl}/auth/authorize',
      clientId: provider.clientId,
      redirectUri: provider.redirectUrl,
      scopes: config?.scopesSupported.isNotEmpty == true
          ? config!.scopesSupported
          : _defaultScopes,
    );

    _reportProgress(PatientLoginProgress(
      step: PatientLoginStep.waitingForBrowser,
      message: 'Abriendo portal de ${provider.name} para que inicies sesión...',
      progress: 0.15,
      epsName: provider.name,
    ));

    final authUrl = client.startAuthorization();
    _pendingAuth = authUrl;

    return authUrl;
  }

  /// Paso 2: Procesar el callback de la EPS.
  ///
  /// La EPS redirige a orionhealth://callback?code=xxx&state=yyy
  /// Este método intercambia el code por un token y consulta los datos.
  ///
  /// [callbackUrl] — la URL completa de redirección
  /// [provider] — la EPS
  Future<PatientLoginResult> handleCallback({
    required String callbackUrl,
    required EPSProvider provider,
  }) async {
    if (_pendingAuth == null) {
      return PatientLoginResult.error('No hay autorización pendiente');
    }

    final client = _smartClient ?? SmartOnFhirClient(
      fhirBaseUrl: provider.discoveryUrl,
      tokenEndpoint: '${provider.discoveryUrl}/auth/token',
      authorizeEndpoint: '${provider.discoveryUrl}/auth/authorize',
      clientId: provider.clientId,
      redirectUri: provider.redirectUrl,
      scopes: _defaultScopes,
    );

    try {
      _reportProgress(PatientLoginProgress(
        step: PatientLoginStep.receivingCallback,
        message: 'Recibiendo autorización de ${provider.name}...',
        progress: 0.3,
        epsName: provider.name,
      ));

      // Intercambiar code por token
      _reportProgress(PatientLoginProgress(
        step: PatientLoginStep.exchangingToken,
        message: 'Verificando identidad...',
        progress: 0.5,
        epsName: provider.name,
      ));

      final token = await client.handleCallback(callbackUrl);

      _reportProgress(PatientLoginProgress(
        step: PatientLoginStep.fetchingData,
        message: 'Descargando tu historial clínico de ${provider.name}...',
        progress: 0.65,
        epsName: provider.name,
      ));

      // Buscar el paciente por su ID (viene en el id_token o patient claim)
      final patientId = _extractPatientId(token);
      if (patientId == null) {
        return PatientLoginResult.error(
          'No se pudo identificar al paciente en la respuesta de ${provider.name}',
        );
      }

      // Consultar todos los datos FHIR del paciente
      final results = await _fetchAllPatientFhirData(client, patientId, token);

      _reportProgress(PatientLoginProgress(
        step: PatientLoginStep.buildingProfile,
        message: 'Construyendo tu perfil de salud...',
        progress: 0.85,
        epsName: provider.name,
      ));

      // Mapear FHIR → UserProfile
      final clinicalData = PatientClinicalData(
        patient: results['patient'],
        rda: results['conditions'], // Aproximación — las conditions son parte del RDA
        encounterEncounters: results['encounters'],
        immunizations: results['immunizations'],
        medications: results['medications'],
        eapb: {'id': provider.id, 'name': provider.name},
      );

      final profile = FhirToProfileMapper.transform(
        fhirData: clinicalData,
        epsConnectedId: provider.id,
        patientDocumentId: patientId,
      );

      _reportProgress(PatientLoginProgress(
        step: PatientLoginStep.complete,
        message: '¡Perfil cargado exitosamente desde ${provider.name}!',
        progress: 1.0,
        epsName: provider.name,
      ));

      return PatientLoginResult.success(
        profile: profile,
        token: token,
        providerName: provider.name,
      );
    } on SmartOnFhirException catch (e) {
      _reportProgress(PatientLoginProgress(
        step: PatientLoginStep.error,
        message: e.message,
        progress: 0,
        epsName: provider.name,
      ));
      return PatientLoginResult.error(e.message);
    } catch (e) {
      _reportProgress(PatientLoginProgress(
        step: PatientLoginStep.error,
        message: 'Error inesperado: $e',
        progress: 0,
        epsName: provider.name,
      ));
      return PatientLoginResult.error('Error: $e');
    }
  }

  /// Extraer patient_id del token o respuesta SMART on FHIR.
  String? _extractPatientId(OAuthToken token) {
    // SMART on FHIR v2 incluye 'patient' claim en el access_token
    // o en el id_token como 'fhirUser'
    // También puede venir como launch context patient
    //
    // Si no está en el token, se puede buscar con Patient?identifier=
    return token.idToken; // Por ahora, el id token puede contenerlo
  }

  /// Consulta todos los recursos FHIR del paciente en paralelo.
  Future<Map<String, dynamic>> _fetchAllPatientFhirData(
    SmartOnFhirClient client,
    String patientId,
    OAuthToken token,
  ) async {
    final results = <String, dynamic>{};

    try {
      // Consultar en paralelo: Patient, Conditions, Medications, Immunizations, Encounters
      final futures = await Future.wait([
        _safeFhirCall(() => client.findPatient(
          system: 'CO-CC', // Asumimos cédula colombiana
          value: patientId,
          token: token,
        )),
        _safeFhirCall(() => client.getConditions(patientId: patientId, token: token)),
        _safeFhirCall(() => client.getAllergies(patientId: patientId, token: token)),
        _safeFhirCall(() => client.getMedications(patientId: patientId, token: token)),
        _safeFhirCall(() => client.getImmunizations(patientId: patientId, token: token)),
        _safeFhirCall(() => client.getEncounters(patientId: patientId, token: token)),
        _safeFhirCall(() => client.getObservations(
          patientId: patientId,
          token: token,
          category: 'vital-signs',
        )),
      ]);

      results['patient'] = futures[0];
      results['conditions'] = futures[1];
      results['allergies'] = futures[2];
      results['medications'] = _extractEntries(futures[3]);
      results['immunizations'] = _extractEntries(futures[4]);
      results['encounters'] = _extractEntries(futures[5]);
      results['observations'] = _extractEntries(futures[6]);
    } catch (_) {
      // Datos parciales son mejor que nada
    }

    return results;
  }

  Future<Map<String, dynamic>?> _safeFhirCall(
    Future<Map<String, dynamic>> Function() call,
  ) async {
    try {
      return await call();
    } catch (_) {
      return null;
    }
  }

  List<Map<String, dynamic>>? _extractEntries(Map<String, dynamic>? bundle) {
    if (bundle == null) return null;
    if (bundle['resourceType'] == 'Bundle') {
      final entries = bundle['entry'] as List<dynamic>?;
      return entries
          ?.map((e) => (e as Map<String, dynamic>)['resource'] as Map<String, dynamic>)
          .toList();
    }
    return null;
  }

  void _reportProgress(PatientLoginProgress progress) {
    _progressController.add(progress);
  }

  void dispose() {
    _progressController.close();
    _smartClient?.dispose();
  }
}

/// Resultado del login del paciente.
class PatientLoginResult {
  final bool success;
  final UserProfile? profile;
  final OAuthToken? token;
  final String? errorMessage;
  final String? providerName;

  const PatientLoginResult._({
    required this.success,
    this.profile,
    this.token,
    this.errorMessage,
    this.providerName,
  });

  factory PatientLoginResult.success({
    required UserProfile profile,
    required OAuthToken token,
    required String providerName,
  }) =>
      PatientLoginResult._(
        success: true,
        profile: profile,
        token: token,
        providerName: providerName,
      );

  factory PatientLoginResult.error(String message) =>
      PatientLoginResult._(success: false, errorMessage: message);
}

/// Scopes estándar SMART on FHIR para apps de paciente.
const List<String> _defaultScopes = [
  'openid',
  'fhirUser',
  'launch/patient',
  'patient/Patient.read',
  'patient/Observation.read',
  'patient/Condition.read',
  'patient/MedicationRequest.read',
  'patient/AllergyIntolerance.read',
  'patient/Immunization.read',
  'patient/Encounter.read',
  'patient/Procedure.read',
  'patient/DiagnosticReport.read',
  'patient/DocumentReference.read',
  'offline_access',
];
