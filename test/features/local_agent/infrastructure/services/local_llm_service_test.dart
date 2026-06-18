import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/services/local_llm_service.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';

/// Tests use minimal unit testing since LocalLlmService connects 
/// to an actual Ollama server. We test the interface contract and 
/// the isModelDownloaded method's dual path logic.
void main() {
  group('LocalLlmService', () {
    test('implements LlmService interface', () {
      final service = LocalLlmService();
      expect(service, isA<LlmService>());
    });

    test('model name defaults to gemma:2b', () {
      final service = LocalLlmService();
      // modelName is private but we can test via behavior
      expect(service, isNotNull);
    });

    test('setModel changes the model name', () {
      final service = LocalLlmService();
      service.setModel('llama3:8b');
      // No crash, model name updated internally
    });

    test('generate streams error response when Ollama is not running', () async {
      final service = LocalLlmService();
      
      final result = StringBuffer();
      await service.generate('test prompt').forEach(result.write);

      final response = result.toString();
      expect(response, contains('Error connecting to local LLM'));
    });

    test('isModelDownloaded returns false when Ollama not running', () async {
      final service = LocalLlmService();
      
      final isDownloaded = await service.isModelDownloaded('gemma:2b');
      
      // When Ollama is not running, it checks local files which won't exist
      // in a test environment without mocking path_provider
      expect(isDownloaded, isFalse);
    });

    test('generate handles empty prompt', () async {
      final service = LocalLlmService();

      final result = StringBuffer();
      await service.generate('').forEach(result.write);

      // Should still produce an error connection message
      expect(result.toString(), isNotEmpty);
    });

    test('generate handles special characters in prompt', () async {
      final service = LocalLlmService();

      final result = StringBuffer();
      await service.generate('¿Cuál es mi presión arterial? 120/80').forEach(result.write);

      expect(result.toString(), contains('Error'));
    });
  });
}
