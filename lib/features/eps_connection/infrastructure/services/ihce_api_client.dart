import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:orionhealth_health/features/eps_connection/infrastructure/services/ihce_auth_service.dart';

/// Client HTTP para el API Gateway del IHCE Minsalud.
///
/// Sandbox: https://sandbox.ihcecol.gov.co/ihce
/// API Key: registrada por Minsalud para cada prestador
///
/// Documentación oficial:
///   https://vulcano.ihcecol.gov.co/guia/
///
/// Postman collection:
///   InteropAPI Minsalud Sandbox - Prestadores v1.5
class IhceApiClient {
  static const String sandboxBaseUrl = 'https://sandbox.ihcecol.gov.co/ihce';
  static const String sandboxApiKey =
      String.fromEnvironment('IHCE_SANDBOX_API_KEY', defaultValue: '');

  final String _baseUrl;
  final String _subscriptionKey;
  final IhceAuthService _authService;
  final http.Client _httpClient;

  String? _cachedToken;

  IhceApiClient({
    required IhceAuthService authService,
    String? baseUrl,
    String? subscriptionKey,
    http.Client? httpClient,
  })  : _authService = authService,
        _baseUrl = baseUrl ?? sandboxBaseUrl,
        _subscriptionKey = subscriptionKey ?? sandboxApiKey,
        _httpClient = httpClient ?? http.Client();

  // ─── HEADERS ───────────────────────────────────────────

  Future<Map<String, String>> _headers() async {
    final token = _cachedToken ?? (await _authService.getClientCredentialsToken()).accessToken;
    _cachedToken = token;
    return {
      'Authorization': 'Bearer $token',
      'Ocp-Apim-Subscription-Key': _subscriptionKey,
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // ─── PATIENT ───────────────────────────────────────────

  /// Busca un paciente por documento de identidad (CC, TI, CE, etc.)
  ///
  /// POST /Patient/$consultar-paciente-exacto
  ///
  /// Body: { "resourceType": "Parameters", "parameter": [
  ///   { "name": "tipoDocumento", "valueString": "CC" },
  ///   { "name": "numeroDocumento", "valueString": "123456789" }
  /// ]}
  Future<Map<String, dynamic>> consultarPacienteExacto({
    required String tipoDocumento,
    required String numeroDocumento,
  }) async {
    final headers = await _headers();
    final body = {
      'resourceType': 'Parameters',
      'parameter': [
        {'name': 'tipoDocumento', 'valueString': tipoDocumento},
        {'name': 'numeroDocumento', 'valueString': numeroDocumento},
      ],
    };

    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/Patient/\$consultar-paciente-exacto'),
      headers: headers,
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  /// Busca pacientes similares (fuzzy match) por nombre + fecha nacimiento.
  ///
  /// POST /Patient/$consultar-paciente-similar
  ///
  /// Body: Parameters con: primerNombre, segundoNombre, primerApellido,
  ///   segundoApellido, fechaNacimiento, sexo, codigoDepartamento, codigoMunicipio
  Future<Map<String, dynamic>> consultarPacienteSimilar({
    String? primerNombre,
    String? segundoNombre,
    String? primerApellido,
    String? segundoApellido,
    String? fechaNacimiento,
    String? sexo,
    String? codigoDepartamento,
    String? codigoMunicipio,
  }) async {
    final headers = await _headers();
    final params = <Map<String, dynamic>>[];

    if (primerNombre != null) params.add({'name': 'primerNombre', 'valueString': primerNombre});
    if (segundoNombre != null) params.add({'name': 'segundoNombre', 'valueString': segundoNombre});
    if (primerApellido != null) params.add({'name': 'primerApellido', 'valueString': primerApellido});
    if (segundoApellido != null) params.add({'name': 'segundoApellido', 'valueString': segundoApellido});
    if (fechaNacimiento != null) params.add({'name': 'fechaNacimiento', 'valueString': fechaNacimiento});
    if (sexo != null) params.add({'name': 'sexo', 'valueString': sexo});
    if (codigoDepartamento != null) params.add({'name': 'codigoDepartamento', 'valueString': codigoDepartamento});
    if (codigoMunicipio != null) params.add({'name': 'codigoMunicipio', 'valueString': codigoMunicipio});

    final body = {
      'resourceType': 'Parameters',
      'parameter': params,
    };

    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/Patient/\$consultar-paciente-similar'),
      headers: headers,
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  // ─── CLINICAL DATA (RDA) ───────────────────────────────

  /// Consulta el Resumen Digital de Atención (RDA) completo de un paciente.
  /// Incluye: diagnósticos, alergias, medicamentos, antecedentes familiares.
  ///
  /// POST /Composition/$consultar-rda-paciente
  Future<Map<String, dynamic>> consultarRdaPaciente({
    required String tipoDocumento,
    required String numeroDocumento,
  }) async {
    final headers = await _headers();
    final body = {
      'resourceType': 'Parameters',
      'parameter': [
        {'name': 'tipoDocumento', 'valueString': tipoDocumento},
        {'name': 'numeroDocumento', 'valueString': numeroDocumento},
      ],
    };

    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/Composition/\$consultar-rda-paciente'),
      headers: headers,
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  /// Consulta los encuentros clínicos (citas, hospitalizaciones, urgencias)
  /// de un paciente. Incluye fechas, diagnóstico, profesional, organización.
  ///
  /// POST /Composition/$consultar-rda-encuentros-clinicos
  Future<Map<String, dynamic>> consultarEncuentrosClinicos({
    required String tipoDocumento,
    required String numeroDocumento,
    String? fechaInicio,
    String? fechaFin,
  }) async {
    final headers = await _headers();
    final params = <Map<String, dynamic>>[
      {'name': 'tipoDocumento', 'valueString': tipoDocumento},
      {'name': 'numeroDocumento', 'valueString': numeroDocumento},
    ];
    if (fechaInicio != null) params.add({'name': 'fechaInicio', 'valueString': fechaInicio});
    if (fechaFin != null) params.add({'name': 'fechaFin', 'valueString': fechaFin});

    final body = {
      'resourceType': 'Parameters',
      'parameter': params,
    };

    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/Composition/\$consultar-rda-encuentros-clinicos'),
      headers: headers,
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  // ─── IMMUNIZATIONS ─────────────────────────────────────

  /// Consulta el historial de vacunación de un paciente.
  /// Retorna Immunization resources con: vacuna, fecha, dosis, lote, fabricante.
  ///
  /// POST /Immunization/$consultar-inmunizacion
  Future<Map<String, dynamic>> consultarInmunizacion({
    required String tipoDocumento,
    required String numeroDocumento,
  }) async {
    final headers = await _headers();
    final body = {
      'resourceType': 'Parameters',
      'parameter': [
        {'name': 'tipoDocumento', 'valueString': tipoDocumento},
        {'name': 'numeroDocumento', 'valueString': numeroDocumento},
      ],
    };

    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/Immunization/\$consultar-inmunizacion'),
      headers: headers,
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  // ─── MEDICATIONS ───────────────────────────────────────

  /// Consulta las dispensaciones de medicamentos de un paciente.
  /// Retorna MedicationDispense: medicamento, fecha, cantidad, prescriptor, EPS.
  ///
  /// POST /MedicationDispense/$consultar-dispensacion-paciente
  Future<Map<String, dynamic>> consultarDispensaciones({
    required String tipoDocumento,
    required String numeroDocumento,
    String? fechaInicio,
    String? fechaFin,
  }) async {
    final headers = await _headers();
    final params = <Map<String, dynamic>>[
      {'name': 'tipoDocumento', 'valueString': tipoDocumento},
      {'name': 'numeroDocumento', 'valueString': numeroDocumento},
    ];
    if (fechaInicio != null) params.add({'name': 'fechaInicio', 'valueString': fechaInicio});
    if (fechaFin != null) params.add({'name': 'fechaFin', 'valueString': fechaFin});

    final body = {
      'resourceType': 'Parameters',
      'parameter': params,
    };

    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/MedicationDispense/\$consultar-dispensacion-paciente'),
      headers: headers,
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  // ─── ORGANIZATIONS ─────────────────────────────────────

  /// Consulta una EPS/EAPB por código.
  ///
  /// POST /Organization/$consultar-eapb
  Future<Map<String, dynamic>> consultarEapb({
    required String codigoEapb,
  }) async {
    final headers = await _headers();
    final body = {
      'resourceType': 'Parameters',
      'parameter': [
        {'name': 'codigoEapb', 'valueString': codigoEapb},
      ],
    };

    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/Organization/\$consultar-eapb'),
      headers: headers,
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  /// Consulta una organización prestadora por código de habilitación REPS.
  ///
  /// POST /Organization/$consultar-organizacion
  Future<Map<String, dynamic>> consultarOrganizacion({
    required String codigoHabilitacion,
  }) async {
    final headers = await _headers();
    final body = {
      'resourceType': 'Parameters',
      'parameter': [
        {'name': 'codigoHabilitacion', 'valueString': codigoHabilitacion},
      ],
    };

    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/Organization/\$consultar-organizacion'),
      headers: headers,
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  /// Consulta un profesional de salud por documento.
  ///
  /// POST /Practitioner/$consultar-profesional-salud
  Future<Map<String, dynamic>> consultarProfesionalSalud({
    required String tipoDocumento,
    required String numeroDocumento,
  }) async {
    final headers = await _headers();
    final body = {
      'resourceType': 'Parameters',
      'parameter': [
        {'name': 'tipoDocumento', 'valueString': tipoDocumento},
        {'name': 'numeroDocumento', 'valueString': numeroDocumento},
      ],
    };

    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/Practitioner/\$consultar-profesional-salud'),
      headers: headers,
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  // ─── DOCUMENT REFERENCE ────────────────────────────────

  /// Lista referencias a documentos clínicos del paciente
  /// (resultados de laboratorio, imágenes, notas de evolución).
  ///
  /// POST /DocumentReference/$document-reference-index-query
  Future<Map<String, dynamic>> listarDocumentosClinicos({
    required String tipoDocumento,
    required String numeroDocumento,
  }) async {
    final headers = await _headers();
    final body = {
      'resourceType': 'Parameters',
      'parameter': [
        {'name': 'tipoDocumento', 'valueString': tipoDocumento},
        {'name': 'numeroDocumento', 'valueString': numeroDocumento},
      ],
    };

    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/DocumentReference/\$document-reference-index-query'),
      headers: headers,
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  // ─── RESPONSE HANDLER ──────────────────────────────────

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    String? message;
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body.containsKey('issue')) {
        message = body['issue'].toString();
      }
    } catch (_) {
      message = response.body;
    }

    throw IhceApiException(
      'IHCE API error (${response.statusCode}): ${message ?? 'Unknown'}',
      statusCode: response.statusCode,
      responseBody: response.body,
    );
  }

  void dispose() => _httpClient.close();
}

class IhceApiException implements Exception {
  final String message;
  final int statusCode;
  final String? responseBody;

  IhceApiException(this.message, {required this.statusCode, this.responseBody});

  @override
  String toString() => message;
}
