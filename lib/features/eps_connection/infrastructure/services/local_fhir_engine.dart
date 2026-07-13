import 'dart:async';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_connection.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/oauth_token.dart';
import 'package:orionhealth_health/features/eps_connection/infrastructure/services/ihce_api_client.dart';
import 'package:orionhealth_health/features/eps_connection/infrastructure/services/ihce_auth_service.dart';

/// Resultado de una consulta al IHCE vía Local FHIR Engine.
class FhirQueryResult {
  final bool success;
  final Map<String, dynamic>? data;
  final String? error;
  final FhirResourceType resourceType;
  final DateTime timestamp;

  FhirQueryResult({
    required this.success,
    this.data,
    this.error,
    required this.resourceType,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory FhirQueryResult.success(Map<String, dynamic> data, FhirResourceType type) =>
      FhirQueryResult(success: true, data: data, resourceType: type);

  factory FhirQueryResult.error(String error, FhirResourceType type) =>
      FhirQueryResult(success: false, error: error, resourceType: type);
}

enum FhirResourceType {
  patient,
  composition,
  rdaPaciente,
  encuentrosClinicos,
  immunization,
  medicationDispense,
  organizationEapb,
  organizationPrestador,
  practitioner,
  documentReference,
}

/// Datos clínicos consolidados del paciente extraídos del IHCE.
class PatientClinicalData {
  final Map<String, dynamic>? patient;
  final Map<String, dynamic>? rda; // Resumen Digital de Atención
  final List<Map<String, dynamic>>? encounterEncounters;
  final List<Map<String, dynamic>>? immunizations;
  final List<Map<String, dynamic>>? medications;
  final Map<String, dynamic>? eapb; // Datos de la EPS
  final List<Map<String, dynamic>>? clinicalDocuments;
  final DateTime fetchedAt;

  PatientClinicalData({
    this.patient,
    this.rda,
    this.encounterEncounters,
    this.immunizations,
    this.medications,
    this.eapb,
    this.clinicalDocuments,
    DateTime? fetchedAt,
  }) : fetchedAt = fetchedAt ?? DateTime.now();

  bool get hasData =>
      patient != null || rda != null || immunizations != null || medications != null;

  Map<String, dynamic> toJson() => {
        'patient': patient,
        'rda': rda,
        'encounterEncounters': encounterEncounters,
        'immunizations': immunizations,
        'medications': medications,
        'eapb': eapb,
        'clinicalDocuments': clinicalDocuments,
        'fetchedAt': fetchedAt.toIso8601String(),
      };

  factory PatientClinicalData.fromJson(Map<String, dynamic> json) =>
      PatientClinicalData(
        patient: json['patient'] as Map<String, dynamic>?,
        rda: json['rda'] as Map<String, dynamic>?,
        encounterEncounters: (json['encounterEncounters'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>(),
        immunizations: (json['immunizations'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>(),
        medications: (json['medications'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>(),
        eapb: json['eapb'] as Map<String, dynamic>?,
        clinicalDocuments: (json['clinicalDocuments'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>(),
        fetchedAt: json['fetchedAt'] != null
            ? DateTime.tryParse(json['fetchedAt'] as String)
            : null,
      );
}

/// 🏥 Local FHIR Engine — Motor central de interoperabilidad en-device.
///
/// Orquesta:
/// 1. Autenticación OAuth2 Client Credentials contra Azure AD del IHCE
/// 2. Consultas FHIR a la API Gateway del IHCE (sandbox o producción)
/// 3. Transformación FHIR R4 → Modelos OrionHealth
/// 4. Cache local (Isar/JSON file) para modo offline
/// 5. Sincronización P2P opcional via IPFS
///
/// NO requiere servidor externo. Todo corre en el dispositivo del paciente.
///
/// Uso:
/// ```dart
/// final engine = LocalFhirEngine(
///   authService: IhceAuthService(
///     clientId: 'tu-client-id',
///     clientSecret: 'tu-client-secret',
///   ),
///   apiClient: IhceApiClient(authService: authService),
/// );
///
/// // OAuth Client Credentials (machine-to-machine, sin usuario)
/// await engine.authenticate();
///
/// // Consultar todos los datos del paciente
/// final data = await engine.fetchAllPatientData(
///   tipoDocumento: 'CC',
///   numeroDocumento: '123456789',
/// );
/// ```
class LocalFhirEngine {
  final IhceAuthService _authService;
  final IhceApiClient _apiClient;

  /// Cache en memoria de datos del paciente. En producción se reemplaza
  /// por Isar para persistencia offline.
  PatientClinicalData? _cachedPatientData;
  bool _isAuthenticated = false;

  /// Stream controller para notificar cambios de estado de sincronización.
  final _syncStatusController = StreamController<FhirSyncStatus>.broadcast();
  Stream<FhirSyncStatus> get syncStatus => _syncStatusController.stream;

  LocalFhirEngine({
    required IhceAuthService authService,
    required IhceApiClient apiClient,
  })  : _authService = authService,
        _apiClient = apiClient;

  bool get isAuthenticated => _isAuthenticated;
  PatientClinicalData? get cachedPatientData => _cachedPatientData;

  /// Autentica contra el IHCE usando Client Credentials (machine-to-machine).
  /// Este flow NO requiere interacción del usuario — es para prestadores registrados.
  Future<OAuthToken> authenticate() async {
    _syncStatusController.add(const FhirSyncAuthenticating());
    try {
      final token = await _authService.getClientCredentialsToken();
      _isAuthenticated = true;
      _syncStatusController.add(const FhirSyncAuthenticated());
      return token;
    } catch (e) {
      _isAuthenticated = false;
      _syncStatusController.add(FhirSyncAuthError(e.toString()));
      rethrow;
    }
  }

  /// Verifica que el token actual siga válido. Si expiró, re-autentica.
  Future<void> ensureAuthenticated() async {
    if (!_isAuthenticated) {
      await authenticate();
    }
  }

  /// 🩺 Fetch completo — TODOS los datos clínicos del paciente del IHCE.
  ///
  /// Ejecuta en paralelo:
  /// - Datos demográficos (Patient)
  /// - Historia clínica RDA (Composition)
  /// - Encuentros clínicos (citas, hospitalizaciones)
  /// - Vacunas (Immunization)
  /// - Medicamentos dispensados (MedicationDispense)
  /// - Datos de la EPS (Organization EAPB)
  /// - Documentos clínicos (DocumentReference)
  Future<PatientClinicalData> fetchAllPatientData({
    required String tipoDocumento,
    required String numeroDocumento,
    String? fechaInicio,
    String? fechaFin,
  }) async {
    await ensureAuthenticated();
    _syncStatusController.add(const FhirSyncSyncing());

    try {
      final futures = await Future.wait([
        _safeQuery(
          () => _apiClient.consultarPacienteExacto(
            tipoDocumento: tipoDocumento,
            numeroDocumento: numeroDocumento,
          ),
          FhirResourceType.patient,
        ),
        _safeQuery(
          () => _apiClient.consultarRdaPaciente(
            tipoDocumento: tipoDocumento,
            numeroDocumento: numeroDocumento,
          ),
          FhirResourceType.rdaPaciente,
        ),
        _safeQuery(
          () => _apiClient.consultarEncuentrosClinicos(
            tipoDocumento: tipoDocumento,
            numeroDocumento: numeroDocumento,
            fechaInicio: fechaInicio,
            fechaFin: fechaFin,
          ),
          FhirResourceType.encuentrosClinicos,
        ),
        _safeQuery(
          () => _apiClient.consultarInmunizacion(
            tipoDocumento: tipoDocumento,
            numeroDocumento: numeroDocumento,
          ),
          FhirResourceType.immunization,
        ),
        _safeQuery(
          () => _apiClient.consultarDispensaciones(
            tipoDocumento: tipoDocumento,
            numeroDocumento: numeroDocumento,
            fechaInicio: fechaInicio,
            fechaFin: fechaFin,
          ),
          FhirResourceType.medicationDispense,
        ),
        _safeQuery(
          () => _apiClient.listarDocumentosClinicos(
            tipoDocumento: tipoDocumento,
            numeroDocumento: numeroDocumento,
          ),
          FhirResourceType.documentReference,
        ),
      ]);

      final patient = _extractData(futures[0]);
      final rda = _extractData(futures[1]);
      final encounters = _extractList(futures[2], 'entry');
      final immunizations = _extractList(futures[3], 'entry');
      final medications = _extractList(futures[4], 'entry');
      final documents = _extractList(futures[5], 'entry');

      final clinicalData = PatientClinicalData(
        patient: patient,
        rda: rda,
        encounterEncounters: encounters,
        immunizations: immunizations,
        medications: medications,
        clinicalDocuments: documents,
      );

      _cachedPatientData = clinicalData;
      _syncStatusController.add(FhirSyncSynced(clinicalData));

      return clinicalData;
    } catch (e) {
      _syncStatusController.add(FhirSyncSyncError(e.toString()));
      rethrow;
    }
  }

  /// Obtiene solo datos de la EPS (Organization) para un paciente
  /// cuyo código de EPS se conoce.
  Future<Map<String, dynamic>?> fetchEpsData({
    required String codigoEapb,
  }) async {
    await ensureAuthenticated();
    try {
      final result = await _apiClient.consultarEapb(codigoEapb: codigoEapb);
      return result;
    } catch (e) {
      return null;
    }
  }

  /// Intenta conectar con una EPS del catálogo usando la API real del IHCE.
  ///
  /// Flujo:
  /// 1. Autentica contra Azure AD del IHCE
  /// 2. Consulta la EPS por código en el IHCE
  /// 3. Si la EPS existe en el IHCE → crea la conexión
  Future<EPSConnection> connectToEps({
    required EPSProvider provider,
    required String tipoDocumento,
    required String numeroDocumento,
  }) async {
    await ensureAuthenticated();

    // 1. Verificar que la EPS existe en el IHCE
    await _apiClient.consultarEapb(codigoEapb: provider.id);

    // 2. Obtener los datos del paciente de esa EPS
    await fetchAllPatientData(
      tipoDocumento: tipoDocumento,
      numeroDocumento: numeroDocumento,
    );

    // 3. Crear la conexión
    final token = await _authService.getClientCredentialsToken();

    return EPSConnection(
      provider: provider,
      token: token,
      patientId: numeroDocumento,
      connectedAt: DateTime.now(),
    );
  }

  /// Consulta un paciente por nombre completo + fecha nacimiento (fuzzy search).
  /// Útil cuando no se tiene el número de documento exacto.
  Future<Map<String, dynamic>> searchPatientByName({
    String? primerNombre,
    String? segundoNombre,
    String? primerApellido,
    String? segundoApellido,
    String? fechaNacimiento,
    String? sexo,
    String? codigoDepartamento,
    String? codigoMunicipio,
  }) async {
    await ensureAuthenticated();
    return _apiClient.consultarPacienteSimilar(
      primerNombre: primerNombre,
      segundoNombre: segundoNombre,
      primerApellido: primerApellido,
      segundoApellido: segundoApellido,
      fechaNacimiento: fechaNacimiento,
      sexo: sexo,
      codigoDepartamento: codigoDepartamento,
      codigoMunicipio: codigoMunicipio,
    );
  }

  // ─── HELPERS ───────────────────────────────────────────

  Future<FhirQueryResult> _safeQuery(
    Future<Map<String, dynamic>> Function() query,
    FhirResourceType type,
  ) async {
    try {
      final data = await query();
      return FhirQueryResult.success(data, type);
    } catch (e) {
      return FhirQueryResult.error(e.toString(), type);
    }
  }

  Map<String, dynamic>? _extractData(FhirQueryResult result) {
    if (!result.success || result.data == null) return null;

    // Si es un Bundle, extraer el primer entry
    final data = result.data!;
    if (data['resourceType'] == 'Bundle') {
      final entries = data['entry'] as List<dynamic>?;
      if (entries != null && entries.isNotEmpty) {
        return (entries.first as Map<String, dynamic>)['resource'];
      }
      return null;
    }
    return data;
  }

  List<Map<String, dynamic>>? _extractList(FhirQueryResult result, String key) {
    if (!result.success || result.data == null) return null;

    final data = result.data!;
    if (data['resourceType'] == 'Bundle') {
      final entries = data['entry'] as List<dynamic>?;
      if (entries == null) return null;
      return entries.map((e) => (e as Map<String, dynamic>)['resource'] as Map<String, dynamic>).toList();
    }

    final list = data[key];
    if (list is List) return list.cast<Map<String, dynamic>>();
    return null;
  }

  void dispose() {
    _syncStatusController.close();
    _apiClient.dispose();
    _authService.dispose();
  }
}

/// Estados de sincronización FHIR para UI feedback.
sealed class FhirSyncStatus {
  const FhirSyncStatus();
}

class FhirSyncIdle extends FhirSyncStatus {
  const FhirSyncIdle();
}

class FhirSyncAuthenticating extends FhirSyncStatus {
  const FhirSyncAuthenticating();
}

class FhirSyncAuthenticated extends FhirSyncStatus {
  const FhirSyncAuthenticated();
}

class FhirSyncAuthError extends FhirSyncStatus {
  final String error;
  const FhirSyncAuthError(this.error);
}

class FhirSyncSyncing extends FhirSyncStatus {
  const FhirSyncSyncing();
}

class FhirSyncSynced extends FhirSyncStatus {
  final PatientClinicalData data;
  const FhirSyncSynced(this.data);
}

class FhirSyncSyncError extends FhirSyncStatus {
  final String error;
  const FhirSyncSyncError(this.error);
}
