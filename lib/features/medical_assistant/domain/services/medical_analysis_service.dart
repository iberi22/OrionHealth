import 'package:equatable/equatable.dart';

/// Thresholds for confidence-based medical response generation.
/// The AI should NEVER diagnose — only explain symptoms and suggest next steps.
class ConfidenceThreshold {
  /// Minimum confidence (90%) required before offering any interpretation.
  /// Below this, we only explain what symptoms COULD mean.
  static const double diagnosisThreshold = 0.90;

  /// High confidence: ≥90% — interpretation allowed but still no diagnosis.
  static const double highConfidence = 0.90;

  /// Medium confidence: 70-89% — possible interpretation with caveats.
  static const double mediumConfidence = 0.70;

  /// Low confidence: 50-69% — explanation of possibilities only.
  static const double lowConfidence = 0.50;

  /// Returns true only if confidence meets the threshold for any interpretation.
  static bool canDiagnose(double confidence) => confidence >= diagnosisThreshold;

  /// Returns the confidence level label.
  static String getLevel(double confidence) {
    if (confidence >= highConfidence) return 'high';
    if (confidence >= mediumConfidence) return 'medium';
    return 'low';
  }
}

/// Structured response from medical analysis.
/// All fields are designed to enforce: EXPLAIN symptoms, don't diagnose.
class AnalysisResponse extends Equatable {
  /// ALWAYS provided — explains what symptoms could mean.
  final String explanation;

  /// Only provided if confidence >= 90%.
  /// Never phrased as a diagnosis — always as a possible interpretation.
  final String? possibleInterpretation;

  /// ALWAYS provided — disclaimer that this is not medical advice.
  final String? disclaimer;

  /// Suggested if confidence < 90%.
  final List<String> suggestedExams;

  final List<String> lifestyleRecommendations;

  /// ALWAYS — recommendation to see a real doctor.
  final String doctorRecommendation;

  final double confidence;

  /// "high", "medium", or "low".
  final String confidenceLevel;

  const AnalysisResponse({
    required this.explanation,
    this.possibleInterpretation,
    this.disclaimer,
    this.suggestedExams = const [],
    this.lifestyleRecommendations = const [],
    required this.doctorRecommendation,
    required this.confidence,
    required this.confidenceLevel,
  });

  @override
  List<Object?> get props => [
        explanation,
        possibleInterpretation,
        disclaimer,
        suggestedExams,
        lifestyleRecommendations,
        doctorRecommendation,
        confidence,
        confidenceLevel,
      ];

  /// Returns true if confidence is high enough to offer an interpretation.
  bool get canOfferInterpretation => confidence >= ConfidenceThreshold.diagnosisThreshold;

  /// Returns true if additional data should be requested.
  bool get needsMoreData => confidence < ConfidenceThreshold.mediumConfidence;
}
