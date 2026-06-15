import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

@lazySingleton
class EmailRemoteDataSource {
  final http.Client _client;

  static const String _baseUrl = 'http://localhost:3000/api';
  static const String _gmailClientId = 'YOUR_GMAIL_CLIENT_ID';
  static const String _outlookClientId = 'YOUR_OUTLOOK_CLIENT_ID';

  EmailRemoteDataSource({http.Client? client}) : _client = client ?? http.Client();

  Future<bool> connectGmail() async {
    final url = Uri.parse(
      'https://accounts.google.com/o/oauth2/v2/auth'
      '?client_id=$_gmailClientId'
      '&response_type=code'
      '&scope=https://www.googleapis.com/auth/gmail.readonly'
      '&redirect_uri=orionhealth://oauth2redirect',
    );
    return await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<bool> connectOutlook() async {
    final url = Uri.parse(
      'https://login.microsoftonline.com/common/oauth2/v2.0/authorize'
      '?client_id=$_outlookClientId'
      '&response_type=code'
      '&scope=Mail.Read'
      '&redirect_uri=orionhealth://oauth2redirect',
    );
    return await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<List<Map<String, dynamic>>?> fetchParsedAppointments(
    String provider,
    String code,
  ) async {
    try {
      final endpoint = provider == 'Gmail' ? '/gmail/appointments' : '/outlook/appointments';
      final response = await _client.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': code}),
      );
      if (response.statusCode == 200) {
        return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  void dispose() => _client.close();
}
