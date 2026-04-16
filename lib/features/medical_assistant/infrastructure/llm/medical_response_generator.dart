import '../../domain/entities/medical_insight.dart';

class MedicalResponseGenerator {
  static MedicalAnalysisResult generate({
    required String question,
    required Map<String, dynamic> userContext,
    required double confidence,
  }) {
    // This is a simplified implementation of what an LLM would do
    // based on the gathered insights and user context.

    final confidenceLevel = _getLevel(confidence);
    final needsMoreData = confidence < 0.70;

    String explanation = 'He analizado tu consulta sobre "$question". ';
    String? interpretation;

    if (confidence >= 0.90) {
      interpretation = 'Basado en los datos analizados, existe una alta probabilidad de que tus síntomas estén relacionados con una condición específica.';
    } else if (confidence >= 0.70) {
      explanation += 'Tengo una confianza moderada en los datos, pero se requiere más información para una interpretación clara.';
    } else {
      explanation += 'Actualmente no cuento con suficientes datos médicos para proporcionar una interpretación específica.';
    }

    return MedicalAnalysisResult(
      explanation: explanation,
      possibleInterpretation: interpretation,
      confidence: confidence,
      confidenceLevel: confidenceLevel,
      needsMoreData: needsMoreData,
    );
  }

  static String formatResponse(MedicalAnalysisResult result, String question) {
    final buffer = StringBuffer();
    buffer.writeln('Respuesta a tu consulta: "$question"');
    buffer.writeln();
    buffer.writeln(result.explanation);

    if (result.possibleInterpretation != null) {
      buffer.writeln();
      buffer.writeln('INTERPRETACIÓN:');
      buffer.writeln(result.possibleInterpretation);
    }

    buffer.writeln();
    buffer.writeln('Nivel de confianza: ${(result.confidence * 100).toInt()}%');

    if (result.needsMoreData) {
      buffer.writeln();
      buffer.writeln('⚠️ Se recomienda proporcionar más datos (laboratorios, síntomas detallados) para mejorar la precisión.');
    }

    return buffer.toString();
  }

  static String _getLevel(double confidence) {
    if (confidence >= 0.90) return 'high';
    if (confidence >= 0.70) return 'medium';
    if (confidence >= 0.50) return 'low';
    return 'very_low';
  }
}

class MedicalAnalysisResult {
  final String explanation;
  final String? possibleInterpretation;
  final double confidence;
  final String confidenceLevel;
  final bool needsMoreData;

  MedicalAnalysisResult({
    required this.explanation,
    this.possibleInterpretation,
    required this.confidence,
    required this.confidenceLevel,
    required this.needsMoreData,
  });
}
