import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:http/http.dart' as http;

@lazySingleton
class DoctorRemoteDataSource {
  final http.Client _client;
  DoctorRemoteDataSource({http.Client? client}) : _client = client ?? http.Client();

  /// Verify a doctor's license against the national registry API.
  Future<Map<String, dynamic>?> verifyLicense(String licenseNumber, String country) async {
    try {
      final response = await _client.get(
        Uri.parse('https://api.example.com/verify/\/\'),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) return jsonDecode(response.body) as Map<String, dynamic>;
      return null;
    } catch (_) { return null; }
  }

  void dispose() => _client.close();
}
