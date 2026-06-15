// TODO: migrate from data/ — moved to infrastructure/services/fhir_client.dart
// This file is kept temporarily. Remove after verifying new imports work.

/// FHIR Client for IHCE Colombia
/// Native Dart implementation - no backend needed
/// Uses flutter_appauth for OAuth and http for FHIR API calls
library;

import 'dart:convert';
import 'package:http/http.dart' as http;

class FhirClient {
  final String baseUrl;
  final http.Client _client;

  FhirClient({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? 'https://fhir.ihcecol.gov.co/fhir',
        _client = client ?? http.Client();

  /// Fetch a Patient resource by ID
  Future<Map<String, dynamic>> getPatient(
    String id,
    String accessToken,
  ) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/Patient/$id'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/fhir+json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw FhirException(
          'Error fetching Patient $id',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is FhirException) rethrow;
      throw FhirException('Network error fetching Patient: $e', 0, null);
    }
  }

  /// Fetch RDA (Resumen Digital de Atención) for a patient
  /// Uses Composition resource with LOINC code for patient summary
  Future<Map<String, dynamic>> getRDA(
    String patientId,
    String accessToken,
  ) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/Composition').replace(
          queryParameters: {
            'patient': patientId,
            'type': 'http://loinc.org|60591-5', // Patient Summary
            '_sort': '-date',
            '_count': '1',
          },
        ),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/fhir+json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw FhirException(
          'Error fetching RDA for Patient $patientId',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is FhirException) rethrow;
      throw FhirException('Network error fetching RDA: $e', 0, null);
    }
  }

  /// Search Patient by identifier (document number)
  Future<Map<String, dynamic>> searchPatient({
    String? identifier,
    String? name,
    String? birthDate,
    required String accessToken,
  }) async {
    final params = <String, String>{};
    if (identifier != null) params['identifier'] = identifier;
    if (name != null) params['name'] = name;
    if (birthDate != null) params['birthdate'] = birthDate;

    if (params.isEmpty) {
      throw ArgumentError('At least one search parameter required');
    }

    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/Patient').replace(queryParameters: params),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/fhir+json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw FhirException(
          'Error searching Patient',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is FhirException) rethrow;
      throw FhirException('Network error searching Patient: $e', 0, null);
    }
  }

  /// Fetch specific resource type by reference
  Future<Map<String, dynamic>?> fetchResource(
    String resourceType,
    String id,
    String accessToken,
  ) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/$resourceType/$id'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/fhir+json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw FhirException(
          'Error fetching $resourceType/$id',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is FhirException) rethrow;
      throw FhirException('Network error fetching resource: $e', 0, null);
    }
  }

  void dispose() {
    _client.close();
  }
}

class FhirException implements Exception {
  final String message;
  final int? statusCode;
  final String? body;

  const FhirException(this.message, this.statusCode, this.body);

  @override
  String toString() =>
      'FhirException: $message (status: $statusCode)';
}
