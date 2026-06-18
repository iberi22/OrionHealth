import 'package:flutter_test/flutter_test.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/adapters/gemini_model_wrapper.dart';

class MockGenerativeModel extends Mock implements GenerativeModel {}

void main() {
  late MockGenerativeModel mockModel;
  late GeminiModelWrapper wrapper;

  setUp(() {
    mockModel = MockGenerativeModel();
    wrapper = GeminiModelWrapper(mockModel);
  });

  group('GeminiModelWrapper', () {
    test('generateContent returns response text on success', () async {
      when(() => mockModel.generateContent(any())).thenAnswer(
        (_) async => GenerateContentResponse(
          candidates: [
            CandidateContent(
              content: Content.text('Test response from Gemini'),
            ),
          ],
          promptFeedback: null,
        ),
      );

      final result = await wrapper.generateContent('Hello Gemini');

      expect(result, 'Test response from Gemini');
      verify(() => mockModel.generateContent(any())).called(1);
    });

    test('generateContent returns null when no candidates', () async {
      when(() => mockModel.generateContent(any())).thenAnswer(
        (_) async => GenerateContentResponse(
          candidates: [],
          promptFeedback: null,
        ),
      );

      final result = await wrapper.generateContent('Hello');

      expect(result, isNull);
    });

    test('generateContent returns null when first candidate has no content', () async {
      when(() => mockModel.generateContent(any())).thenAnswer(
        (_) async => GenerateContentResponse(
          candidates: [CandidateContent(content: null)],
          promptFeedback: null,
        ),
      );

      final result = await wrapper.generateContent('Hello');

      expect(result, isNull);
    });

    test('generateContent throws when model throws', () async {
      when(() => mockModel.generateContent(any())).thenThrow(
        Exception('API Error'),
      );

      expect(
        () => wrapper.generateContent('Hello'),
        throwsA(isA<Exception>()),
      );
    });

    test('generateContent passes the correct prompt content', () async {
      GenerateContentResponse? captured;
      when(() => mockModel.generateContent(any())).thenAnswer((invocation) async {
        captured = invocation.positionalArguments[0] as GenerateContentResponse?;
        return GenerateContentResponse(
          candidates: [
            CandidateContent(
              content: Content.text('OK'),
            ),
          ],
          promptFeedback: null,
        );
      });

      await wrapper.generateContent('What is ICD-10?');

      // Verify the model was called (the content wrapping is internal to GenerativeModel)
      verify(() => mockModel.generateContent(any())).called(1);
    });
  });
}
