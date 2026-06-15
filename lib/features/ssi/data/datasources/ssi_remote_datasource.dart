import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:http/http.dart' as http;

@lazySingleton
class SsiRemoteDataSource {
  final http.Client _client;
  SsiRemoteDataSource({http.Client? client}) : _client = client ?? http.Client();

  /// Resolve a DID document from a universal resolver or ledger.
  Future<Map<String, dynamic>?> resolveDid(String did) async {
    try {
      final response = await _client.get(
        Uri.parse('https://dev.uniresolver.io/1.0/identifiers/\'),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) return jsonDecode(response.body) as Map<String, dynamic>;
      return null;
    } catch (_) { return null; }
  }

  /// Verify a verifiable credential against a remote registry.
  Future<bool> verifyCredentialRemotely(String credentialJson) async => false;

  void dispose() => _client.close();
}
