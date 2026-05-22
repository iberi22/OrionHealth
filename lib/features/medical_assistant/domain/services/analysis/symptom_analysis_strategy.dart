import 'package:medical_standards/medical_standards.dart';
import '../../entities/medical_insight.dart';
import '../../entities/analysis_response.dart';

class SymptomAnalysisStrategy {
  Future<SafeAnalysisResponse> analyze({
    required List<String> symptoms,
    required List<String> currentMedications,
    List<String>? recentLabResults,
    String? knownCondition,
  }) async {
    String explanation = '';
    String? possibleInterpretation;
    List<String> suggestedExams = [];
    List<String> lifestyleRecs = [];
    double confidence = 0.35;
    final insights = <MedicalInsight>[];

    explanation = 'SÍNTOMAS REPORTADOS:\n';
    for (final symptom in symptoms) {
      explanation += '• $symptom\n';
    }
    explanation += '\n';

    // Analyze fatigue specifically (common symptom)
    if (symptoms.any((s) => s.toLowerCase().contains('fatiga') ||
                           s.toLowerCase().contains('cansancio') ||
                           s.toLowerCase().contains('tired'))) {
      explanation += 'PODRÍA ESTAR RELACIONADO CON:\n';

      final causes = <String>[];

      if (knownCondition != null && knownCondition.toLowerCase().contains('diabetes')) {
        causes.add('• Control glucémico subóptimo (relacionado con diabetes)');
        confidence = 0.55;
      }

      causes.add('• Deficiencia de hierro (anemia)');
      causes.add('• Hipotiroidismo (tiroides baja)');
      causes.add('• Deficiencia de vitamina B12 o ácido fólico');
      causes.add('• Falta de sueño o poor sleep quality');
      causes.add('• Estrés o depresión');
      causes.add('• Deshidratación');
      causes.add('• Efectos secundarios de medicamentos');

      for (final cause in causes) {
        explanation += '$cause\n';
      }

      confidence = 0.40;
      possibleInterpretation =
          'El cansancio persistente tiene muchas causas posibles.\n\n'
          'MIS RECOMENDACIONES:\n'
          '1. Consulta con tu médico para una evaluación completa\n'
          '2. Considera hacerte los siguientes exámenes:\n'
          '   • Hemograma completo (descartar anemia)\n'
          '   • TSH y T4 libre (tiroides)\n'
          '   • Vitamina B12 y ácido fólico\n'
          '   • Ferritina y hierro sérico\n'
          '3. Lleva un registro de cuándo ocurre el cansancio\n'
          '4. Evalúa calidad y cantidad de sueño\n\n'
          'NOTA IMPORTANTE:\n'
          'Solo un médico puede determinar la causa exacta basándose '
          'en tu historial médico completo y exámenes de laboratorio.';

      suggestedExams = [
        'Hemograma completo',
        'TSH y T4 libre (función tiroidea)',
        'Ferritina y hierro sérico',
        'Vitamina B12 y ácido fólico',
        'Glucosa en ayunas',
      ];

      lifestyleRecs = [
        'Asegurar 7-9 horas de sueño',
        'Hidratarse adecuadamente (2L/día)',
        'Dieta balanceada rica en hierro',
        'Ejercicio moderado regular',
      ];

      final guideline = await ClinicalGuidelines.findByCode('CLSI-2017');

      insights.add(MedicalInsight(
        id: 'fatigue-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Análisis de Cansancio/Fatiga',
        description: 'Múltiples causas posibles identificadas',
        severity: InsightSeverity.info,
        category: InsightCategory.symptomAnalysis,
        guidelineReference: guideline?.code ?? 'CLSI-2017',
        recommendations: suggestedExams,
        generatedAt: DateTime.now(),
      ));
    } else {
      explanation += 'No puedo determinar la causa específica de tus síntomas '
          'con la información disponible.\n\n'
          'MIS RECOMENDACIONES:\n'
          '• Consulta con tu médico para una evaluación completa\n'
          '• Lleva un registro detallado de tus síntomas\n'
          '• Incluye: cuándo empiezan, duración, factores que empeoran o mejoran\n';

      suggestedExams = ['Consulta médica para evaluación completa'];
    }

    return SafeAnalysisResponse(
      explanation: explanation,
      possibleInterpretation: possibleInterpretation,
      disclaimer: 'Esta información es solo educativa. '
          'No sustituye la evaluación de un profesional de salud. '
          'Consulta siempre a tu médico.',
      suggestedExams: suggestedExams,
      lifestyleRecommendations: lifestyleRecs,
      doctorRecommendation:
          'Te recomiendo agendar una cita con tu médico de cabecera '
          'para una evaluación completa de tus síntomas.',
      confidence: confidence,
      confidenceLevel: ConfidenceThreshold.getLevel(confidence),
      insights: insights,
    );
  }
}
