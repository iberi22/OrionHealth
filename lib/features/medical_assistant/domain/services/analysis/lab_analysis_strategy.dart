import 'package:medical_standards/medical_standards.dart';
import '../../entities/medical_insight.dart';
import '../../entities/analysis_response.dart';

class LabAnalysisStrategy {
  Future<SafeAnalysisResponse> analyze({
    required String labCode,
    required double value,
    String? unit,
    String? patientCondition,
  }) async {
    final loinc = await LoincCommonLabs.findByCode(labCode);
    final insights = <MedicalInsight>[];

    String explanation = '';
    String? possibleInterpretation;
    List<String> suggestedExams = [];
    List<String> lifestyleRecs = [];
    double confidence = 0.30; // Default: low confidence
    String disclaimer =
        'Esta información es solo educativa. No sustituye la evaluación '
        'de un profesional de salud. Consulta siempre a tu médico.';
    String doctorRec =
        'Te recomiendo consultar con tu médico de cabecera para una '
        'evaluación completa basada en tu historial clínico.';

    if (loinc != null) {
      explanation = 'VALOR DE LABORATORIO: ${loinc.component}\n'
          'Tu resultado: $value ${unit ?? loinc.unit}\n'
          'Rango de referencia: ${loinc.normalRange ?? "consultar laboratorio"}\n\n'
          '¿Qué podría significar este valor?\n';

      // Check if value is abnormal
      final isAbnormal = _isValueAbnormal(loinc, value);

      if (isAbnormal != null) {
        if (isAbnormal) {
          explanation += '• Tu valor está ${loinc.component.toLowerCase().contains("hemo") || loinc.component.toLowerCase().contains("glucosa") ? "fuera" : "por encima"} del rango normal.\n';

          // Try to calculate confidence based on how much it's out of range
          confidence = _calculateLabConfidence(loinc, value);

          if (confidence >= ConfidenceThreshold.highConfidence) {
            possibleInterpretation =
                'INTERPRETACIÓN (con alta confianza):\n'
                'Este valor elevado podría estar relacionado con ${_getPossibleCondition(loinc, patientCondition)}.\n\n'
                'BASADO EN:\n'
                '• Tu resultado: $value ${unit ?? loinc.unit}\n'
                '• Guideline de referencia: ${loinc.component}\n'
                '• Condición conocida: ${patientCondition ?? "no especificada"}\n\n'
                'NOTA: Esta interpretación se basa en datos objetivos y guías clínicas, '
                'pero solo tu médico puede confirmar un diagnóstico.';

            suggestedExams = _getSuggestedExamsForLab(loinc);
            lifestyleRecs = _getLifestyleRecs(loinc);
          } else if (confidence >= ConfidenceThreshold.mediumConfidence) {
            possibleInterpretation =
                'PODRÍA ESTAR RELACIONADO CON:\n'
                'Según el valor elevado, podría haber una relación con ${_getPossibleCondition(loinc, patientCondition)}.\n'
                'Sin embargo, no tengo certeza suficiente para afirmarlo.\n\n'
                'INFORMACIÓN ADICIONAL NECESARIA:\n';

            suggestedExams = _getSuggestedExamsForLab(loinc);
            lifestyleRecs = ['Lleva un registro de tus síntomas', 'Mantén una dieta equilibrada'];
          } else {
            possibleInterpretation =
                'Este valor elevado tiene múltiples causas posibles.\n'
                'No tengo suficiente información para determinar la causa específica.';

            suggestedExams = [
              'Consulta con tu médico para interpretar este resultado',
              ..._getSuggestedExamsForLab(loinc),
            ];
            lifestyleRecs = ['Lleva un registro de tus síntomas', 'Mantén una dieta equilibrada'];
          }
        } else {
          explanation += '• Tu valor está dentro del rango normal.\n';
          confidence = 0.85; // High confidence it's normal
          possibleInterpretation =
              'INTERPRETACIÓN:\n'
              'Tu valor de ${loinc.component} ($value ${unit ?? loinc.unit}) está dentro '
              'de los rangos normales de referencia.\n\n'
              'Continúa con tus chequeos regulares.';
        }
      } else {
        explanation += '• No tengo información suficiente para interpretar este valor.\n';
        suggestedExams = ['Consulta con tu médico para interpretar este resultado'];
      }

      final guideline = await ClinicalGuidelines.findByCode('CLSI-2017');

      insights.add(MedicalInsight(
        id: 'lab-$labCode-${DateTime.now().millisecondsSinceEpoch}',
        title: '${loinc.component} Analysis',
        description: 'Value: $value ${unit ?? loinc.unit}',
        severity: _getSeverityForConfidence(confidence),
        category: InsightCategory.labInterpretation,
        guidelineReference: guideline?.code ?? 'CLSI-2017',
        recommendations: suggestedExams.isNotEmpty
            ? suggestedExams
            : ['Revisión con proveedor de salud'],
        generatedAt: DateTime.now(),
        evidence: {'loinc': loinc.code, 'value': value},
      ));
    } else {
      explanation = 'No tengo información específica para el código de laboratorio: $labCode.\n\n'
          'MIS RECOMENDACIONES:\n'
          '1. Consulta con tu médico para interpretar este resultado\n'
          '2. Busca el código LOINC en tu informe de laboratorio\n'
          '3. Lleva todos tus resultados a tu próxima cita médica\n\n'
          'Siempre es importante que un profesional de salud interprete '
          'tus resultados en el contexto de tu historial médico completo.';

      confidence = 0.20;
      suggestedExams = ['Consulta médica para interpretación'];
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

  bool? _isValueAbnormal(LoincCode loinc, double value) {
    // Parse normal range if available
    final range = loinc.normalRange;
    if (range == null) return null;

    if (range.toLowerCase().contains('less than')) {
      final max = double.tryParse(range.replaceAll(RegExp(r'[^0-9.]'), ''));
      if (max != null) return value >= max;
    } else if (range.contains('-')) {
      final parts = range.split('-');
      if (parts.length == 2) {
        final min = double.tryParse(parts[0].replaceAll(RegExp(r'[^0-9.]'), ''));
        final max = double.tryParse(parts[1].replaceAll(RegExp(r'[^0-9.]'), ''));
        if (min != null && max != null) {
          return value < min || value > max;
        }
      }
    }

    return null;
  }

  double _calculateLabConfidence(LoincCode loinc, double value) {
    final range = loinc.normalRange;
    if (range == null) return 0.50;

    if (range.contains('-')) {
      final parts = range.split('-');
      if (parts.length == 2) {
        final min = double.tryParse(parts[0].replaceAll(RegExp(r'[^0-9.]'), ''));
        final max = double.tryParse(parts[1].replaceAll(RegExp(r'[^0-9.]'), ''));

        if (min != null && max != null) {
          final midpoint = (min + max) / 2;
          final deviation = (value - midpoint).abs() / midpoint;

          if (deviation > 2.0) return 0.92; // 90%+ confidence
          if (deviation > 1.5) return 0.80; // 70-89%
          if (deviation > 1.0) return 0.65; // 50-69%
          return 0.45; // <50%
        }
      }
    }

    return 0.50;
  }

  String _getPossibleCondition(LoincCode loinc, String? condition) {
    if (condition != null) return condition;

    final code = loinc.code;
    if (code.contains('4548') || code.contains('hba1c')) {
      return 'diabetes o prediabetes';
    }
    if (code.contains('2345') || code.contains('glucose')) {
      return 'niveles alterados de glucosa';
    }
    if (code.contains('2160') || code.contains('creatinine')) {
      return 'función renal alterada';
    }
    if (code.contains('3094') || code.contains('bun')) {
      return 'función renal o hidratación';
    }
    if (code.contains('3016') || code.contains('tsh')) {
      return 'hipotiroidismo o hipertiroidismo';
    }

    return 'una condición que requiere evaluación médica';
  }

  List<String> _getSuggestedExamsForLab(LoincCode loinc) {
    final code = loinc.code;

    if (code.contains('4548') || code.contains('hba1c')) {
      return [
        'Glucosa en ayunas',
        'Perfil lipídico completo',
        'Función renal (creatinina, BUN)',
      ];
    }
    if (code.contains('2345') || code.contains('glucose')) {
      return [
        'Hemoglobina A1c',
        'Perfil metabólico completo',
      ];
    }
    if (code.contains('2160') || code.contains('creatinine')) {
      return [
        'Tasa de filtración glomerular (eGFR)',
        'Relación albúmina/creatinina en orina',
      ];
    }
    if (code.contains('3016') || code.contains('tsh')) {
      return [
        'T4 libre',
        'T3 total',
        'Anticuerpos antitiroideos',
      ];
    }

    return ['Consulta con médico para más exámenes'];
  }

  List<String> _getLifestyleRecs(LoincCode loinc) {
    final code = loinc.code;

    if (code.contains('4548') || code.contains('hba1c') || code.contains('glucose')) {
      return [
        'Dieta baja en azúcares refinados',
        'Ejercicio regular (150 min/semana)',
        'Mantener peso saludable',
        'Monitoreo de glucosa regular',
      ];
    }

    return [
      'Dieta balanceada',
      'Ejercicio regular',
      'Chequeos médicos periódicos',
    ];
  }

  InsightSeverity _getSeverityForConfidence(double confidence) {
    if (confidence >= 0.90) return InsightSeverity.alert;
    if (confidence >= 0.70) return InsightSeverity.warning;
    if (confidence >= 0.50) return InsightSeverity.info;
    return InsightSeverity.info;
  }
}
