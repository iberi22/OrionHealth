import 'package:medical_standards/medical_standards.dart';
import '../entities/medical_insight.dart';

/// Domain service for medical analysis orchestration
class MedicalAnalysisService {
  /// Analyze lab results and generate insights
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

  /// Analyze vital signs and generate insights
  Future<List<MedicalInsight>> analyzeVitals({
    required Map<String, double> vitals,
    required List<Icd10Code> chronicConditions,
  }) async {
    final insights = <MedicalInsight>[];
    
    // Blood pressure analysis
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

  /// Calculate health risk scores
  Future<List<MedicalInsight>> calculateRisks({
    required Map<String, double> labValues,
    required Map<String, double> vitals,
    required List<Icd10Code> conditions,
  }) async {
    final insights = <MedicalInsight>[];
    
    // ASCVD risk placeholder
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
