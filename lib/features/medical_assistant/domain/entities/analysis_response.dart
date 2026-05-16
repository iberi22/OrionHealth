import 'medical_insight.dart';
import 'ai_response.dart';

/// Strict confidence thresholds for medical AI responses
///
/// RULE: AI NEVER diagnoses below 90% confidence.
/// AI ALWAYS explains what symptoms COULD mean, never what they ARE.
class ConfidenceThreshold {
  /// Minimum confidence required for any diagnosis/interpretation
  static const double diagnosisThreshold = 0.90;

  /// High confidence: 90%+ — can provide possible interpretation
  static const double highConfidence = 0.90;

  /// Medium confidence: 70-89% — suggests but needs more data
  static const double mediumConfidence = 0.70;

  /// Low confidence: 50-69% — lists possibilities, recommend tests
  static const double veryLowConfidence = 0.50;

  /// Below 50%: No interpretation, only general guidance
  static const double noInterpretation = 0.50;

  static bool canDiagnose(double confidence) => confidence >= diagnosisThreshold;

  static String getLevel(double confidence) {
    if (confidence >= highConfidence) return 'high';
    if (confidence >= mediumConfidence) return 'medium';
    if (confidence >= veryLowConfidence) return 'low';
    return 'very_low';
  }
}

/// Response with strict confidence-based formatting
class SafeAnalysisResponse {
  final String explanation; // ALWAYS provided
  final String? possibleInterpretation; // Only if confidence >= 90%
  final String disclaimer; // ALWAYS provided
  final List<String> suggestedExams; // If confidence < 90%
  final List<String> lifestyleRecommendations;
  final String doctorRecommendation; // ALWAYS
  final double confidence;
  final String confidenceLevel;
  final List<MedicalInsight> insights;

  const SafeAnalysisResponse({
    required this.explanation,
    this.possibleInterpretation,
    required this.disclaimer,
    required this.suggestedExams,
    required this.lifestyleRecommendations,
    required this.doctorRecommendation,
    required this.confidence,
    required this.confidenceLevel,
    required this.insights,
  });

  /// Convert to AI response format
  AiMedicalResponse toAiResponse(String queryId) {
    String answer = explanation;

    if (possibleInterpretation != null) {
      answer += '\n\n$possibleInterpretation';
    }

    if (suggestedExams.isNotEmpty) {
      answer += '\n\n📋 EXÁMENES SUGERIDOS:\n';
      for (final exam in suggestedExams) {
        answer += '• $exam\n';
      }
    }

    if (lifestyleRecommendations.isNotEmpty) {
      answer += '\n💡 RECOMENDACIONES:\n';
      for (final rec in lifestyleRecommendations) {
        answer += '• $rec\n';
      }
    }

    answer += '\n\n⚕️ $doctorRecommendation\n\n';
    answer += '─' * 50 + '\n';
    answer += '🔒 $disclaimer\n';
    answer += '📊 CONFIANZA: ${(confidence * 100).toStringAsFixed(0)}% ($confidenceLevel)';

    return AiMedicalResponse(
      id: 'analysis-${DateTime.now().millisecondsSinceEpoch}',
      queryId: queryId,
      answer: answer,
      insights: insights,
      generatedAt: DateTime.now(),
      confidence: confidence,
      metadata: {
        'confidenceLevel': confidenceLevel,
        'canDiagnose': ConfidenceThreshold.canDiagnose(confidence),
      },
    );
  }
}
