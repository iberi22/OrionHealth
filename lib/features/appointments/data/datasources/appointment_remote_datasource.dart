import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:http/http.dart' as http;

@lazySingleton
class AppointmentRemoteDataSource {
  final http.Client _client;
  AppointmentRemoteDataSource({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Map<String, dynamic>>?> fetchFromEmailApi(String provider, String code) async {
    try {
      final response = await _client.post(
        Uri.parse('http://localhost:3000/api/\/appointments'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': code}),
      );
      if (response.statusCode == 200) return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
      return null;
    } catch (_) { return null; }
  }

  void dispose() => _client.close();
}
