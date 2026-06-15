import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:http/http.dart' as http;

/// Remote datasource for AI assistant LLM API calls.
@lazySingleton
class AiRemoteDataSource {
  final http.Client _client;

  AiRemoteDataSource({http.Client? client}) : _client = client ?? http.Client();

  /// Send a question to the configured LLM backend and stream the response.
  Stream<String> streamQuestion({
    required String text,
    Map<String, dynamic>? metadata,
  }) async* {
    try {
      final response = await _client.post(
        Uri.parse('http://localhost:11434/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': metadata?['model'] ?? 'llama3',
          'prompt': text,
          'stream': true,
        }),
      );

      final lines = LineSplitter.split(response.body);
      for (final line in lines) {
        if (line.trim().isEmpty) continue;
        try {
          final chunk = jsonDecode(line);
          if (chunk['response'] != null) {
            yield chunk['response'] as String;
          }
        } catch (_) {}
      }
    } catch (e) {
      yield 'Lo siento, no puedo conectar con el asistente en este momento. '
          'Verifica que el servidor LLM esté disponible.';
    }
  }

  /// Save a conversation entry to local history.
  Future<void> saveToHistory(String query, String response) async {
    // TODO: persist to Isar/SharedPreferences
  }

  void dispose() => _client.close();
}
