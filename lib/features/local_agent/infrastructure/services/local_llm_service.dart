import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

@lazySingleton
class LocalLlmService implements LlmService {
  final Dio _dio = Dio();
  String _modelName = 'gemma:2b';
  final String _baseUrl = 'http://localhost:11434';

  @override
  Stream<String> generate(String prompt) async* {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/generate',
        data: {
          'model': _modelName,
          'prompt': prompt,
          'stream': true,
        },
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data.stream as Stream<List<int>>;

      await for (final chunk in stream.transform(utf8.decoder).transform(const LineSplitter())) {
        if (chunk.trim().isEmpty) continue;
        try {
          final json = jsonDecode(chunk);
          final text = json['response'] as String?;
          if (text != null) {
            yield text;
          }
          if (json['done'] == true) {
            break;
          }
        } catch (e) {
          // Ignore parse errors for partial chunks
        }
      }
    } catch (e) {
      yield 'Error connecting to local LLM: $e';
    }
  }

  void setModel(String modelName) {
    _modelName = modelName;
  }

  Future<bool> isModelDownloaded(String modelName) async {
    // For Ollama, we'd ideally check via tags API, but the task also mentions GGUF files.
    // Let's check both if possible or stick to a simple check.
    try {
      final response = await _dio.get('$_baseUrl/api/tags');
      if (response.statusCode == 200) {
        final models = response.data['models'] as List;
        return models.any((m) => m['name'] == modelName);
      }
    } catch (e) {
      // If Ollama is not running or other error
    }

    // Also check local models directory for GGUF
    final directory = await getApplicationDocumentsDirectory();
    final modelsPath = p.join(directory.path, 'models');
    final file = File(p.join(modelsPath, modelName));
    return await file.exists();
  }
}
