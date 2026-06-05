import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/entities/medical_query.dart';
import 'package:orionhealth_health/features/medical_assistant/infrastructure/llm/medical_response_generator.dart';

void main() {
  group('MedicalResponseGenerator Malformed Response Tests', () {
    test('handles empty user context gracefully', () {
      final result = MedicalResponseGenerator.generate(
        question: '¿Cómo estoy?',
        userContext: {},
        confidence: 0.5,
      );

      expect(result.explanation, isNotEmpty);
      expect(result.confidenceLevel, 'low');
    });

    test('handles extremely low confidence', () {
      final result = MedicalResponseGenerator.generate(
        question: '¿Cura para todo?',
        userContext: {},
        confidence: 0.0,
      );

      expect(result.explanation, contains('no cuento con suficientes datos'));
      expect(result.possibleInterpretation, isNull);
    });

    test('formatResponse handles missing interpretation', () {
      final result = MedicalAnalysisResult(
        explanation: 'Test explanation',
        confidence: 0.4,
        confidenceLevel: 'low',
        needsMoreData: true,
      );

      final formatted = MedicalResponseGenerator.formatResponse(result, 'Test question');

      expect(formatted, contains('Test explanation'));
      expect(formatted, isNot(contains('INTERPRETACIÓN:')));
      expect(formatted, contains('Se recomienda proporcionar más datos'));
    });

    test('formatResponse handles very long questions', () {
      final longQuestion = 'A' * 1000;
      final result = MedicalAnalysisResult(
        explanation: 'Short explanation',
        confidence: 0.9,
        confidenceLevel: 'high',
        needsMoreData: false,
      );

      final formatted = MedicalResponseGenerator.formatResponse(result, longQuestion);
      expect(formatted, contains(longQuestion));
    });

    test('handles edge case confidence values', () {
      // Exactly 0.70 (boundary for medium)
      final result70 = MedicalResponseGenerator.generate(
        question: 'Q',
        userContext: {},
        confidence: 0.70,
      );
      expect(result70.confidenceLevel, 'medium');

      // Exactly 0.90 (boundary for high)
      final result90 = MedicalResponseGenerator.generate(
        question: 'Q',
        userContext: {},
        confidence: 0.90,
      );
      expect(result90.confidenceLevel, 'high');
      expect(result90.possibleInterpretation, isNotNull);
    });
  });
}
