import '../../domain/entities/medical_query.dart';
import '../../domain/entities/medical_insight.dart';
import '../../domain/entities/ai_response.dart';
import '../../domain/services/medical_analysis_service.dart';
import '../../../../core/services/privacy_anonymizer.dart';
import 'medical_response_generator.dart';

/// Adapter for medical LLM API integration.
///
/// Enforces strict confidence-based responses:
/// - AI NEVER diagnoses below 90% confidence
/// - AI ALWAYS explains what symptoms COULD mean
/// - AI ALWAYS recommends consulting a doctor
class MedicalLlmAdapter {
  final PromptScrubber? _scrubber;

  MedicalLlmAdapter({PromptScrubber? scrubber}) : _scrubber = scrubber;

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

    // Scrub prompt if scrubber is available
    final scrubbedQuestion = _scrubber != null
        ? await _scrubber.scrub(query.question, apiName: 'medical-llm-adapter')
        : query.question;

    // Build lab/vital context for the response generator
    final context = _buildContext(userContext, insights);

    // Generate structured response respecting confidence thresholds
    final analysisResponse = MedicalResponseGenerator.generate(
      question: scrubbedQuestion,
      userContext: context,
      confidence: confidence,
    );

    // If we have lab-specific insights, override with per-lab analysis
    final labInsights = insights.where((i) => i.category == InsightCategory.labInterpretation);
    if (labInsights.isNotEmpty) {
      final refined = _refineWithLabInsights(
        query,
        labInsights.toList(),
        userContext,
        confidence,
      );
      return refined;
    }

    // Format the response string
    final answer = MedicalResponseGenerator.formatResponse(
      analysisResponse,
      scrubbedQuestion,
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

  /// Refine response when we have lab insights.
  AiMedicalResponse _refineWithLabInsights(
    MedicalQuery query,
    List<MedicalInsight> labInsights,
    Map<String, dynamic> userContext,
    double baseConfidence,
  ) {
    final responseId = 'resp-${DateTime.now().millisecondsSinceEpoch}';

    final buffer = StringBuffer();
    buffer.writeln('Respecto a tu pregunta sobre "${_scrubber != null ? "[PROTECTED]" : query.question}":');
    buffer.writeln();

    // Build explanation from lab insights
    final labExplanation = _buildLabExplanation(labInsights, userContext);
    buffer.writeln(labExplanation);

    // Build interpretation based on confidence
    if (baseConfidence >= ConfidenceThreshold.highConfidence) {
      buffer.writeln();
      buffer.writeln('INTERPRETACIÓN (con alta confianza):');
      for (final insight in labInsights) {
        buffer.writeln('• ${insight.description}');
      }
    } else if (baseConfidence >= ConfidenceThreshold.mediumConfidence) {
      buffer.writeln();
      buffer.writeln('PODRÍA ESTAR RELACIONADO CON:');
      for (final insight in labInsights) {
        buffer.writeln('• ${insight.title}: ${insight.description}');
      }
      buffer.writeln('Sin embargo, no tengo certeza suficiente para afirmarlo.');
    } else {
      buffer.writeln();
      buffer.writeln('POSIBLE EXPLICACIÓN:');
      buffer.writeln('Según los datos disponibles, existen varias posibilidades. '
          'No tengo suficiente información para determinar una causa específica.');
    }

    // Collect recommendations
    final exams = <String>{};
    for (final insight in labInsights) {
      exams.addAll(insight.recommendations);
    }
    if (exams.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('EXÁMENES SUGERIDOS:');
      for (final exam in exams.take(5)) {
        buffer.writeln('• $exam');
      }
    }

    buffer.writeln();
    buffer.writeln(
        'MI RECOMENDACIÓN: Es importante que consultes con tu médico de cabecera '
        'o especialista para una evaluación personalizada.');
    buffer.writeln();
    buffer.writeln('CONFIDENCE: ${(baseConfidence * 100).toInt()}%');
    buffer.writeln();
    buffer.writeln(
        '⚠️ Esta información es solo educativa y no sustituye la evaluación '
        'de un profesional de salud. Siempre consulta con tu médico.');

    return AiMedicalResponse(
      id: responseId,
      queryId: query.id,
      answer: buffer.toString(),
      insights: labInsights,
      generatedAt: DateTime.now(),
      model: 'medical-llm-adapter',
      confidence: baseConfidence,
      metadata: {
        'confidenceLevel': ConfidenceThreshold.getLevel(baseConfidence),
        'canDiagnose': ConfidenceThreshold.canDiagnose(baseConfidence),
        'needsMoreData': baseConfidence < ConfidenceThreshold.mediumConfidence,
        'insightsCount': labInsights.length,
      },
    );
  }

  String _buildLabExplanation(
    List<MedicalInsight> insights,
    Map<String, dynamic> userContext,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('TUS DATOS DE LABORATORIO:');
    for (final insight in insights) {
      buffer.writeln('• ${insight.title}: ${insight.description}');
    }
    return buffer.toString();
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
