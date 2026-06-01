import 'package:medical_standards/medical_standards.dart';
import '../entities/medical_insight.dart';
import '../entities/ai_response.dart';
import '../entities/analysis_response.dart';

/// Domain service for medical analysis orchestration
/// 
/// IMPORTANT: All analysis follows strict confidence rules:
/// - AI NEVER says "you have X" unless 90%+ confidence
/// - AI ALWAYS explains what symptoms COULD mean
/// - AI ALWAYS recommends consulting a doctor
/// - AI ALWAYS provides normal ranges for labs
class MedicalAnalysisService {
  /// Analyze lab results with confidence-based responses
  /// 
  /// Returns a SafeAnalysisResponse that ALWAYS includes:
  /// - Explanation of what values COULD indicate
  /// - Normal ranges from guidelines
  /// - Suggested additional tests if confidence < 90%
  /// - Doctor recommendation
  SafeAnalysisResponse analyzeLabWithConfidence({
    required String labCode,
    required double value,
    String? unit,
    String? patientCondition,
  }) {
    final loinc = LoincCommonLabs.findByCode(labCode);
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
                '• Tu resultado: $value ${unit}\n'
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
          }
        } else {
          explanation += '• Tu valor está dentro del rango normal.\n';
          confidence = 0.85; // High confidence it's normal
          possibleInterpretation = 
              'INTERPRETACIÓN:\n'
              'Tu valor de ${loinc.component} ($value ${unit}) está dentro '
              'de los rangos normales de referencia.\n\n'
              'Continúa con tus chequeos regulares.';
        }
      } else {
        explanation += '• No tengo información suficiente para interpretar este valor.\n';
        suggestedExams = ['Consulta con tu médico para interpretar este resultado'];
      }
      
      insights.add(MedicalInsight(
        id: 'lab-$labCode-${DateTime.now().millisecondsSinceEpoch}',
        title: '${loinc.component} Analysis',
        description: 'Value: $value ${unit ?? loinc.unit}',
        severity: _getSeverityForConfidence(confidence),
        category: InsightCategory.labInterpretation,
        guidelineReference: ClinicalGuidelines.labReferenceRanges.code,
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

  /// Analyze vital signs with confidence-based responses
  SafeAnalysisResponse analyzeVitalWithConfidence({
    required String vitalType,
    required double value,
    String? unit,
    Map<String, double>? relatedVitals,
  }) {
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
          guidelineReference: ClinicalGuidelines.ahaHypertension.code,
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
          guidelineReference: ClinicalGuidelines.ahaHypertension.code,
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
          guidelineReference: ClinicalGuidelines.ahaHypertension.code,
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

  /// Analyze symptoms with confidence-based responses
  /// 
  /// IMPORTANT: This NEVER diagnoses. It explains what symptoms COULD mean.
  SafeAnalysisResponse analyzeSymptomsWithConfidence({
    required List<String> symptoms,
    required List<String> currentMedications,
    List<String>? recentLabResults,
    String? knownCondition,
  }) {
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
      
      insights.add(MedicalInsight(
        id: 'fatigue-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Análisis de Cansancio/Fatiga',
        description: 'Múltiples causas posibles identificadas',
        severity: InsightSeverity.info,
        category: InsightCategory.symptomAnalysis,
        guidelineReference: ClinicalGuidelines.labReferenceRanges.code,
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

  // ============ Helper Methods ============

  bool? _isValueAbnormal(LoincCode loinc, double value) {
    // Parse normal range if available
    if (loinc.normalRange == null) return null;
    
    final range = loinc.normalRange!;
    // Handle formats like "70-100" or "less than 100"
    
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
    // Calculate confidence based on how much the value deviates
    if (loinc.normalRange == null) return 0.50;
    
    final range = loinc.normalRange!;
    
    if (range.contains('-')) {
      final parts = range.split('-');
      if (parts.length == 2) {
        final min = double.tryParse(parts[0].replaceAll(RegExp(r'[^0-9.]'), ''));
        final max = double.tryParse(parts[1].replaceAll(RegExp(r'[^0-9.]'), ''));
        
        if (min != null && max != null) {
          final midpoint = (min + max) / 2;
          final deviation = (value - midpoint).abs() / midpoint;
          
          // Higher deviation = higher confidence it's truly abnormal
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
    
    // Map labs to possible conditions
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

  // ============ Original Methods (kept for compatibility) ============

  /// Analyze lab results and generate insights (original method)
  Future<List<MedicalInsight>> analyzeLabs({
    required Map<String, double> labValues,
    required List<Icd10Code> chronicConditions,
  }) async {
    final insights = <MedicalInsight>[];
    
    for (final entry in labValues.entries) {
      final loinc = LoincCommonLabs.findByCode(entry.key);
      if (loinc != null) {
        insights.add(MedicalInsight(
          id: 'lab-${entry.key}',
          title: '${loinc.component} Analysis',
          description: loinc.description ?? 'Lab value: ${entry.value} ${loinc.unit}',
          severity: InsightSeverity.info,
          category: InsightCategory.labInterpretation,
          guidelineReference: ClinicalGuidelines.labReferenceRanges.code,
          recommendations: ['Review with healthcare provider'],
          generatedAt: DateTime.now(),
          evidence: {'loinc': loinc.code, 'value': entry.value},
        ));
      }
    }
    
    return insights;
  }

  /// Analyze vital signs and generate insights (original method)
  Future<List<MedicalInsight>> analyzeVitals({
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
      
      insights.add(MedicalInsight(
        id: 'bp-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Blood Pressure Assessment',
        description: 'BP: $systolic/$diastolic mmHg',
        severity: severity,
        category: InsightCategory.vitalSignAnalysis,
        guidelineReference: ClinicalGuidelines.ahaHypertension.code,
        recommendations: ['Monitor blood pressure regularly'],
        generatedAt: DateTime.now(),
      ));
    }
    
    return insights;
  }

  /// Calculate health risk scores (original method)
  Future<List<MedicalInsight>> calculateRisks({
    required Map<String, double> labValues,
    required Map<String, double> vitals,
    required List<Icd10Code> conditions,
  }) async {
    final insights = <MedicalInsight>[];
    
    insights.add(MedicalInsight(
      id: 'ascvd-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Cardiovascular Risk',
      description: 'ASCVD risk assessment based on available data',
      severity: InsightSeverity.info,
      category: InsightCategory.riskAssessment,
      guidelineReference: ClinicalGuidelines.accAhaRiskCalculator.code,
      recommendations: ['Complete lipid panel for accurate assessment'],
      generatedAt: DateTime.now(),
    ));
    
    return insights;
  }

  /// Get guidelines relevant to patient's conditions
  List<ClinicalGuidelineReference> getRelevantGuidelines(List<Icd10Code> conditions) {
    final guidelines = <ClinicalGuidelineReference>[];
    for (final condition in conditions) {
      guidelines.addAll(ClinicalGuidelines.findForCondition(condition.code));
    }
    return guidelines;
  }
}
