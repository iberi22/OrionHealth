import '../../domain/entities/medical_query.dart';
import '../../domain/entities/medical_insight.dart';
import '../../domain/entities/ai_response.dart';
import '../../domain/entities/analysis_response.dart';
import 'medical_response_generator.dart';

/// Adapter for medical LLM API integration.
///
/// Enforces strict confidence-based responses:
/// - AI NEVER diagnoses below 90% confidence
/// - AI ALWAYS explains what symptoms COULD mean
/// - AI ALWAYS recommends consulting a doctor
class MedicalLlmAdapter {
  /// Generate AI response based on query and medical insights.
  ///
  /// Uses SafeAnalysisResponse to enforce:
  /// - Explanation of what values COULD indicate (never what they ARE)
  /// - Normal ranges from guidelines
  /// - Suggested additional tests if confidence < 90%
  /// - Doctor recommendation
  Future<AiMedicalResponse> generateResponse({
    required MedicalQuery query,
    required List<MedicalInsight> insights,
    required Map<String, dynamic> userContext,
  }) async {
    final responseId = 'resp-${DateTime.now().millisecondsSinceEpoch}';

    // Calculate confidence based on insights available
    final confidence = _calculateConfidence(insights);

    // Build lab/vital context for the response generator
    final context = _buildContext(userContext, insights);

    // Generate structured response respecting confidence thresholds
    final analysisResponse = MedicalResponseGenerator.generate(
      question: query.question,
      userContext: context,
      confidence: confidence,
    );

    // Format the response string
    final answer = MedicalResponseGenerator.formatResponse(
      analysisResponse,
      query.question,
    );

    return AiMedicalResponse(
      id: responseId,
      queryId: query.id,
      answer: answer,
      insights: insights,
      generatedAt: DateTime.now(),
      model: 'medical-llm-adapter',
      confidence: confidence,
      metadata: {
        'confidenceLevel': analysisResponse.confidenceLevel,
        'canDiagnose': ConfidenceThreshold.canDiagnose(confidence),
        'needsMoreData': analysisResponse.needsMoreData,
        'insightsCount': insights.length,
      },
    );
  }

  Map<String, dynamic> _buildContext(
    Map<String, dynamic> userContext,
    List<MedicalInsight> insights,
  ) {
    // Merge user context with insight data
    final conditions = userContext['conditions'] as List? ?? [];
    final labs = userContext['labs'] as Map<String, double>? ?? {};

    // Extract lab values from insights if not in context
    for (final insight in insights) {
      final evidence = insight.evidence;
      if (evidence != null && evidence.containsKey('value')) {
        final key = evidence['loinc'] as String? ?? 'unknown';
        if (!labs.containsKey(key)) {
          labs[key] = (evidence['value'] as num).toDouble();
        }
      }
    }

    return {
      'conditions': conditions,
      'labs': labs,
      'vitals': userContext['vitals'] as Map<String, double>? ?? {},
    };
  }

  double _calculateConfidence(List<MedicalInsight> insights) {
    if (insights.isEmpty) return 0.30;

    double confidence = 0.50;

    // High-confidence signal: critical/alert severity insights
    final hasCritical = insights.any((i) => i.severity == InsightSeverity.critical);
    if (hasCritical) return 0.95;

    final hasAlert = insights.any((i) => i.severity == InsightSeverity.alert);
    if (hasAlert) confidence = 0.80;

    // Increase for lab-specific insights with good evidence
    final labInsights = insights.where((i) => i.category == InsightCategory.labInterpretation);
    if (labInsights.isNotEmpty) {
      confidence += 0.15;
    }

    // Increase for vital sign analysis
    final vitalInsights =
        insights.where((i) => i.category == InsightCategory.vitalSignAnalysis);
    if (vitalInsights.isNotEmpty) {
      confidence += 0.10;
    }

    // All insights info-level: decrease confidence (need more data)
    final hasAnySignal = insights.any(
        (i) => i.severity != InsightSeverity.info);
    if (!hasAnySignal) confidence -= 0.15;

    return confidence.clamp(0.0, 1.0);
  }

  /// Check if LLM service is available.
  Future<bool> isAvailable() async {
    return true;
  }
}
