import 'package:medical_standards/medical_standards.dart';
import '../../entities/medical_insight.dart';
import '../../entities/analysis_response.dart';

class VitalAnalysisStrategy {
  Future<SafeAnalysisResponse> analyze({
    required String vitalType,
    required double value,
    String? unit,
    Map<String, double>? relatedVitals,
  }) async {
    final insights = <MedicalInsight>[];

    String explanation = '';
    String? possibleInterpretation;
    List<String> suggestedExams = [];
    List<String> lifestyleRecs = [];
    double confidence = 0.40;
    String disclaimer =
        'Esta información es solo educativa. No sustituye la evaluación '
        'de un profesional de salud.';
    String doctorRec =
        'Te recomiendo consultar con tu médico para una evaluación completa '
        'de tus signos vitales.';

    if (vitalType.toLowerCase() == 'systolic' || vitalType.toLowerCase() == 'diastolic') {
      final systolic = relatedVitals?['systolic'] ?? (vitalType.toLowerCase() == 'systolic' ? value : 0);
      final diastolic = relatedVitals?['diastolic'] ?? (vitalType.toLowerCase() == 'diastolic' ? value : 0);

      explanation = 'PRESIÓN ARTERIAL: $systolic/$diastolic mmHg\n\n';

      final bpGuideline = await ClinicalGuidelines.findByCode('AHA-2017');

      if (systolic >= 180 || diastolic >= 120) {
        explanation += '⚠️ Esta presión arterial está en rango de HIPERTENSIÓN CRISIS.\n';
        confidence = 0.95;
        possibleInterpretation =
            'INTERPRETACIÓN (con alta confianza):\n'
            'Tu presión arterial indica una CRISIS HIPERTENSIVA que requiere '
            'atención médica inmediata.\n\n'
            'ACCIÓN REQUERIDA:\n'
            '• Busca atención médica de emergencia ahora mismo\n'
            '• Si tienes medicación antihipertensiva, tómala según indicado\n'
            '• No ignores estos valores';
        suggestedExams = ['Atención médica de emergencia INMEDIATA'];
        doctorRec = '⚠️ BUSCA ATENCIÓN MÉDICA DE EMERGENCIA AHORA MISMO';

        insights.add(MedicalInsight(
          id: 'bp-critical-${DateTime.now().millisecondsSinceEpoch}',
          title: 'Presión Arterial - CRISIS',
          description: 'BP: $systolic/$diastolic mmHg',
          severity: InsightSeverity.critical,
          category: InsightCategory.vitalSignAnalysis,
          guidelineReference: bpGuideline?.code ?? 'AHA-2017',
          recommendations: ['Atención médica inmediata'],
          generatedAt: DateTime.now(),
        ));
      } else if (systolic >= 140 || diastolic >= 90) {
        explanation += '• Tu presión arterial está por encima del rango normal.\n'
            '• Rango normal: <120/80 mmHg (según AHA 2017)\n'
            '• Esto podría indicar hipertensión.\n';
        confidence = 0.75;
        possibleInterpretation =
            'PODRÍA ESTAR RELACIONADO CON:\n'
            '• Hipertensión arterial (presión alta)\n'
            '• Estrés o ansiedad\n'
            '• Actividad física reciente\n\n'
            'INFORMACIÓN ADICIONAL NECESARIA:\n'
            '• Mediciones repetidas en diferentes momentos\n'
            '• Historial de presión arterial\n'
            '• Nivel de estrés actual\n';
        suggestedExams = ['Monitoreo de presión arterial 24 horas', 'Electrocardiograma'];
        lifestyleRecs = [
          'Reducir consumo de sal',
          'Ejercicio regular moderado',
          'Managejar el estrés',
          'Evitar alcohol y tabaco',
        ];

        insights.add(MedicalInsight(
          id: 'bp-alert-${DateTime.now().millisecondsSinceEpoch}',
          title: 'Presión Arterial - Elevada',
          description: 'BP: $systolic/$diastolic mmHg',
          severity: InsightSeverity.alert,
          category: InsightCategory.vitalSignAnalysis,
          guidelineReference: bpGuideline?.code ?? 'AHA-2017',
          recommendations: suggestedExams,
          generatedAt: DateTime.now(),
        ));
      } else if (systolic >= 130 || diastolic >= 80) {
        explanation += '• Tu presión arterial está elevada (pero no en rango de crisis).\n'
            '• Rango normal: <120/80 mmHg\n';
        confidence = 0.60;
        possibleInterpretation =
            'Tu presión está en rango de ELEVADA según las guías AHA.\n'
            'Esto podría indicar riesgo de desarrollar hipertensión.\n\n'
            'RECOMENDACIONES:\n'
            '• Continuar monitoreo regular\n'
            '• Considerar cambios en estilo de vida\n';
        lifestyleRecs = [
          'Mantener peso saludable',
          'Dieta balanceada baja en sal',
          'Ejercicio regular',
        ];

        insights.add(MedicalInsight(
          id: 'bp-warning-${DateTime.now().millisecondsSinceEpoch}',
          title: 'Presión Arterial - Elevada',
          description: 'BP: $systolic/$diastolic mmHg',
          severity: InsightSeverity.warning,
          category: InsightCategory.vitalSignAnalysis,
          guidelineReference: bpGuideline?.code ?? 'AHA-2017',
          recommendations: lifestyleRecs,
          generatedAt: DateTime.now(),
        ));
      } else {
        explanation += '• Tu presión arterial está dentro de rangos normales.\n'
            '• Rango normal: <120/80 mmHg\n';
        confidence = 0.85;
        possibleInterpretation =
            'INTERPRETACIÓN:\n'
            'Tu presión arterial de $systolic/$diastolic mmHg está dentro '
            'de los valores normales según las guías AHA.\n\n'
            'Continúa manteniendo un estilo de vida saludable.';
      }
    } else {
      explanation = 'No tengo información específica para analizar: $vitalType ($value ${unit ?? ""}).\n\n'
          'MIS RECOMENDACIONES:\n'
          '• Consulta con tu médico para interpretar este valor\n'
          '• Lleva un registro de tus mediciones\n'
          '• Incluye este valor en tu próxima revisión médica';
      confidence = 0.25;
    }

    return SafeAnalysisResponse(
      explanation: explanation,
      possibleInterpretation: possibleInterpretation,
      disclaimer: disclaimer,
      suggestedExams: suggestedExams,
      lifestyleRecommendations: lifestyleRecs,
      doctorRecommendation: doctorRec,
      confidence: confidence,
      confidenceLevel: ConfidenceThreshold.getLevel(confidence),
      insights: insights,
    );
  }

  /// Original analyzeVitals logic moved to strategy
  Future<List<MedicalInsight>> analyzeBatch({
    required Map<String, double> vitals,
    required List<Icd10Code> chronicConditions,
  }) async {
    final insights = <MedicalInsight>[];

    if (vitals.containsKey('systolic') && vitals.containsKey('diastolic')) {
      final systolic = vitals['systolic']!;
      final diastolic = vitals['diastolic']!;

      InsightSeverity severity = InsightSeverity.info;
      if (systolic >= 180 || diastolic >= 120) {
        severity = InsightSeverity.critical;
      } else if (systolic >= 140 || diastolic >= 90) {
        severity = InsightSeverity.alert;
      } else if (systolic >= 130 || diastolic >= 80) {
        severity = InsightSeverity.warning;
      }

      final bpGuideline = await ClinicalGuidelines.findByCode('AHA-2017');

      insights.add(MedicalInsight(
        id: 'bp-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Blood Pressure Assessment',
        description: 'BP: $systolic/$diastolic mmHg',
        severity: severity,
        category: InsightCategory.vitalSignAnalysis,
        guidelineReference: bpGuideline?.code ?? 'AHA-2017',
        recommendations: ['Monitor blood pressure regularly'],
        generatedAt: DateTime.now(),
      ));
    }

    return insights;
  }

  /// Original calculateRisks logic moved to strategy
  Future<List<MedicalInsight>> calculateRisks({
    required Map<String, double> labValues,
    required Map<String, double> vitals,
    required List<Icd10Code> conditions,
  }) async {
    final insights = <MedicalInsight>[];

    final riskGuideline =
        await ClinicalGuidelines.findByCode('ACC-AHA-PRIMARY-2019');

    insights.add(MedicalInsight(
      id: 'ascvd-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Cardiovascular Risk',
      description: 'ASCVD risk assessment based on available data',
      severity: InsightSeverity.info,
      category: InsightCategory.riskAssessment,
      guidelineReference: riskGuideline?.code ?? 'ACC-AHA-PRIMARY-2019',
      recommendations: ['Complete lipid panel for accurate assessment'],
      generatedAt: DateTime.now(),
    ));

    return insights;
  }
}
