import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/mock_llm_service.dart';

void main() {
  group('MockLlmService', () {
    test('generate streams mock response containing prompt', () async {
      final service = MockLlmService();

      final result = StringBuffer();
      await service.generate('what is my blood pressure?').forEach((char) {
        result.write(char);
      });

      final response = result.toString();
      expect(response, contains('mock response'));
      expect(response, contains('what is my blood pressure?'));
      expect(response, contains('Orion AI'));
    });

    test('generate streams characters one by one', () async {
      final service = MockLlmService();

      final chars = <String>[];
      await service.generate('test').forEach(chars.add);

      expect(chars.length, greaterThan(10));
      expect(chars.join(), contains('mock response'));
    });
  });
}
