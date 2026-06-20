import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';

/// Minimal concrete implementation for testing the interface contract.
class TestLlmService implements LlmService {
  final String responsePrefix;

  TestLlmService({this.responsePrefix = 'Test: '});

  @override
  Stream<String> generate(String prompt) async* {
    final response = '$responsePrefix$prompt';
    for (var i = 0; i < response.length; i++) {
      yield response[i];
    }
  }
}

void main() {
  group('LlmService interface', () {
    test('generate streams response characters', () async {
      final service = TestLlmService();

      final result = StringBuffer();
      await service.generate('test query').forEach(result.write);

      expect(result.toString(), 'Test: test query');
    });

    test('generate returns empty stream for empty prompt', () async {
      final service = TestLlmService();

      final result = StringBuffer();
      await service.generate('').forEach(result.write);

      expect(result.toString(), 'Test: ');
    });

    test('multiple calls generate new streams', () async {
      final service = TestLlmService();

      final result1 = StringBuffer();
      await service.generate('first').forEach(result1.write);

      final result2 = StringBuffer();
      await service.generate('second').forEach(result2.write);

      expect(result1.toString(), 'Test: first');
      expect(result2.toString(), 'Test: second');
    });
  });
}
