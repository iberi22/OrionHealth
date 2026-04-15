import '../../domain/entities/medical_query.dart';
import '../../domain/entities/medical_insight.dart';
import '../../domain/entities/ai_response.dart';

/// Adapter for medical LLM API integration
class MedicalLlmAdapter {
  /// Generate AI response based on query and medical insights
  Future<AiMedicalResponse> generateResponse({
    required MedicalQuery query,
    required List<MedicalInsight> insights,
    required Map<String, dynamic> userContext,
  }) async {
    // Stub: would call actual LLM API
    // In production, this would:
    // 1. Build a prompt with query, insights, user context
    // 2. Call medical LLM (e.g., Claude Medical, GPT-4o with medical fine-tuning)
    // 3. Parse and structure the response
    
    final responseId = 'resp-${DateTime.now().millisecondsSinceEpoch}';
    
    // Generate contextual response based on insights
    final answer = _buildAnswer(query.question, insights);
    
    return AiMedicalResponse(
      id: responseId,
      queryId: query.id,
      answer: answer,
      insights: insights,
      generatedAt: DateTime.now(),
      model: 'medical-llm-adapter-stub',
      confidence: _calculateConfidence(insights),
      metadata: {
        'insightsCount': insights.length,
        'hasCritical': insights.any((i) => i.severity == InsightSeverity.critical),
        'hasAlerts': insights.any((i) => i.severity == InsightSeverity.alert),
      },
    );
  }

  String _buildAnswer(String question, List<MedicalInsight> insights) {
    if (insights.isEmpty) {
      return _genericResponse(question);
    }

    final criticalInsights = insights.where((i) => 
        i.severity == InsightSeverity.critical || i.severity == InsightSeverity.alert);
    final warnings = insights.where((i) => i.severity == InsightSeverity.warning);

    final buffer = StringBuffer();
    
    buffer.writeln('Based on your question about "$question", here is my analysis:\n');

    if (criticalInsights.isNotEmpty) {
      buffer.writeln('⚠️ **Important Findings:**\n');
      for (final insight in criticalInsights) {
        buffer.writeln('• ${insight.title}: ${insight.description}');
        if (insight.guidelineReference != null) {
          buffer.writeln('  Reference: ${insight.guidelineReference}');
        }
      }
      buffer.writeln();
    }

    if (warnings.isNotEmpty) {
      buffer.writeln('🔶 **Items to Discuss with Your Provider:**\n');
      for (final insight in warnings) {
        buffer.writeln('• ${insight.title}: ${insight.description}');
      }
      buffer.writeln();
    }

    buffer.writeln('📋 **Recommendations:**\n');
    final allRecs = insights.expand((i) => i.recommendations).toSet();
    for (final rec in allRecs.take(5)) {
      buffer.writeln('• $rec');
    }

    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln('⚕️ This information is for educational purposes only. '
        'Always consult your healthcare provider for medical advice.');

    return buffer.toString();
  }

  String _genericResponse(String question) {
    return '''Thank you for your question about "$question".

I am here to help provide health information based on your medical data.

**Important:** This assistant provides general health information and is not a substitute 
for professional medical advice, diagnosis, or treatment.

For personalized guidance, please:
- Schedule an appointment with your healthcare provider
- Call your local health line for urgent concerns
- In case of emergency, call 911 or your local emergency number

Is there anything specific about your health data you would like me to analyze?
''';
  }

  double _calculateConfidence(List<MedicalInsight> insights) {
    if (insights.isEmpty) return 0.3;
    
    double confidence = 0.7;
    
    // Increase confidence if we have specific lab interpretations
    final labInsights = insights.where((i) => i.category == InsightCategory.labInterpretation);
    if (labInsights.isNotEmpty) confidence += 0.1;
    
    // Decrease if all insights are just info level
    final hasWarnings = insights.any((i) => 
        i.severity == InsightSeverity.warning || 
        i.severity == InsightSeverity.alert ||
        i.severity == InsightSeverity.critical);
    if (!hasWarnings) confidence += 0.1;
    
    return confidence.clamp(0.0, 1.0);
  }

  /// Check if LLM service is available
  Future<bool> isAvailable() async {
    // Stub: would ping the LLM service
    return true;
  }
}
