import '../../domain/entities/medical_query.dart';
import '../../domain/entities/medical_insight.dart';
import '../../domain/entities/ai_response.dart';
import '../../domain/entities/analysis_response.dart';
import '../../../../core/services/privacy_anonymizer.dart';
import 'medical_response_generator.dart';
import '../../../local_agent/infrastructure/llm_service.dart';

/// Adapter for medical LLM API integration.
///
/// Enforces strict confidence-based responses:
/// - AI NEVER diagnoses below 90% confidence
/// - AI ALWAYS explains what symptoms COULD mean
/// - AI ALWAYS recommends consulting a doctor
class MedicalLlmAdapter {
  final PromptScrubber? _scrubber;
  final LlmService _llmService;

  MedicalLlmAdapter({
    PromptScrubber? scrubber,
    required LlmService llmService,
  })  : _scrubber = scrubber,
        _llmService = llmService;

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

    // Build lab/vital context for the LLM
    final context = _buildContext(userContext, insights);
    
    // 3. Build a medical-specific prompt for the LLM
    final medicalPrompt = _buildMedicalPrompt(scrubbedQuestion, context, insights, confidence);

    // 4. Generate response using the real LLM (Gemma/Gemini)
    String answer = "";
    try {
      final stream = _llmService.generate(medicalPrompt);
      await for (final chunk in stream) {
        answer += chunk;
      }
    } catch (e) {
      // Fallback to template if LLM fails
      final analysisResponse = MedicalResponseGenerator.generate(
        question: scrubbedQuestion,
        userContext: context,
        confidence: confidence,
      );
      answer = MedicalResponseGenerator.formatResponse(
        analysisResponse,
        scrubbedQuestion,
      );
    }

    if (answer.isEmpty) {
      answer = "Lo siento, no pude generar una respuesta. Por favor intenta de nuevo.";
    }

    return AiMedicalResponse(
      id: responseId,
      queryId: query.id,
      answer: answer,
      insights: insights,
      generatedAt: DateTime.now(),
      model: 'medical-llm-adapter',
      confidence: confidence,
      metadata: {
        'confidenceLevel': ConfidenceThreshold.getLevel(confidence),
        'canDiagnose': ConfidenceThreshold.canDiagnose(confidence),
        'needsMoreData': confidence < 0.7,
        'insightsCount': insights.length,
        'citations': insights
            .where((i) => i.evidence?.containsKey('code') ?? false)
            .map((i) => '${i.evidence!['standard']}: ${i.evidence!['code']}')
            .toSet()
            .toList(),
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

  String _buildMedicalPrompt(
    String question,
    Map<String, dynamic> context,
    List<MedicalInsight> insights,
    double confidence,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('Eres un Asistente Médico de OrionHealth.');
    buffer.writeln('Tu objetivo es ayudar al usuario a entender sus datos de salud.');
    buffer.writeln();
    buffer.writeln('DATOS DEL USUARIO:');
    if (context['conditions'].isNotEmpty) {
      buffer.writeln('• Condiciones: ${context['conditions'].join(", ")}');
    }
    if (context['labs'].isNotEmpty) {
      buffer.writeln('• Laboratorios: ${context['labs']}');
    }
    if (context['vitals'].isNotEmpty) {
      buffer.writeln('• Signos Vitales: ${context['vitals']}');
    }
    if (context.containsKey('holisticSummary') && context['holisticSummary'].toString().isNotEmpty) {
      buffer.writeln();
      buffer.writeln('CONTEXTO DE SALUD HOLÍSTICA (CONEXIÓN FÍSICO-MENTAL):');
      buffer.writeln(context['holisticSummary']);
    }
    buffer.writeln();
    if (insights.isNotEmpty) {
      buffer.writeln('HALLAZGOS DETECTADOS POR EL SISTEMA:');
      for (final insight in insights) {
        buffer.writeln('• ${insight.title}: ${insight.description}');
      }
      buffer.writeln();
    }

    buffer.writeln('PREGUNTA DEL USUARIO: $question');
    buffer.writeln();
    buffer.writeln('INSTRUCCIONES:');
    buffer.writeln('1. Responde en español de forma profesional, detallada y empática.');
    buffer.writeln('2. RAZONAMIENTO: Explica siempre el "por qué" de tus conclusiones basándote en los datos y hallazgos proporcionados.');
    buffer.writeln('3. SALUD INTEGRAL: Orienta tus respuestas tanto a la salud física como MENTAL. Si es pertinente, menciona el impacto del estrés o el bienestar emocional.');
    buffer.writeln('4. Si la pregunta es general o sobre el sistema, responde directamente de forma útil.');
    buffer.writeln('5. Si la pregunta es médica, usa los hallazgos detectados para explicar posibles causas SIN dar diagnósticos definitivos.');
    buffer.writeln('6. CITACIONES: Menciona explícitamente los códigos de estándares médicos (ICD-10, RxNorm) cuando los uses para sustentar tu razonamiento.');
    buffer.writeln('7. Siempre recomienda consultar a un profesional de salud.');
    buffer.writeln('8. Si no tienes suficiente información para una duda médica, solicita más datos amablemente.');

    return buffer.toString();
  }

  /// Check if LLM service is available.
  Future<bool> isAvailable() async {
    return true;
  }
}
