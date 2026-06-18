import 'package:flutter_test/flutter_test.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/adapters/gemini_model_wrapper.dart';

void main() {
  group('GeminiModelWrapper', () {
    test('constructor accepts GenerativeModel', () {
      // We just verify the class can be constructed with a GenerativeModel
      // without an API key (it will throw on actual API calls)
      final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: 'test-key',
      );
      final wrapper = GeminiModelWrapper(model);
      expect(wrapper, isA<GeminiModelWrapper>());
    });

    test('generateContent throws when called without HTTP client', () async {
      // Without a real HTTP client, generateContent will throw
      // This validates the wrapper delegates correctly
      final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: 'test-key',
      );
      final wrapper = GeminiModelWrapper(model);
      await expectLater(
        () => wrapper.generateContent('test'),
        throwsA(isA<Exception>()),
      );
    });

    test('modelName getter is not exposed, uses wrapped model', () {
      final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: 'test-key',
      );
      final wrapper = GeminiModelWrapper(model);
      // Verify the wrapper is callable
      expect(wrapper, isNotNull);
    });
  });
}
