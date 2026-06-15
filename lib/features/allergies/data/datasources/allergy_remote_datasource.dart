// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:http/http.dart' as http;

/// Remote datasource for fetching allergy data from FHIR API.
@lazySingleton
class AllergyRemoteDataSource {
  final http.Client _client;

  AllergyRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  /// Fetch allergies from a FHIR-compatible endpoint.
  Future<List<Map<String, dynamic>>?> fetchAllergiesFromFhir({
    required String patientId,
    required String accessToken,
    String? baseUrl,
  }) async {
    try {
      final url = Uri.parse('${baseUrl ?? "https://fhir.ihcecol.gov.co/fhir"}/AllergyIntolerance')
          .replace(queryParameters: {'patient': patientId});
      final response = await _client.get(
        url,
        headers: {'Authorization': 'Bearer $accessToken', 'Accept': 'application/fhir+json'},
      );
      if (response.statusCode == 200) {
        final bundle = jsonDecode(response.body) as Map<String, dynamic>;
        final entries = bundle['entry'] as List<dynamic>? ?? [];
        return entries.map((e) => (e as Map<String, dynamic>)['resource'] as Map<String, dynamic>).toList();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  void dispose() => _client.close();
}
