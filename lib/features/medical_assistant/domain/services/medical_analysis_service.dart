import 'package:medical_standards/medical_standards.dart';
import '../entities/medical_insight.dart';
import '../entities/analysis_response.dart';
import 'analysis/lab_analysis_strategy.dart';
import 'analysis/vital_analysis_strategy.dart';
import 'analysis/symptom_analysis_strategy.dart';

/// Domain service for medical analysis orchestration
///
/// IMPORTANT: All analysis follows strict confidence rules:
/// - AI NEVER says "you have X" unless 90%+ confidence
/// - AI ALWAYS explains what symptoms COULD mean
/// - AI ALWAYS recommends consulting a doctor
/// - AI ALWAYS provides normal ranges for labs
class MedicalAnalysisService {
  final LabAnalysisStrategy _labStrategy;
  final VitalAnalysisStrategy _vitalStrategy;
  final SymptomAnalysisStrategy _symptomStrategy;

  MedicalAnalysisService({
    LabAnalysisStrategy? labStrategy,
    VitalAnalysisStrategy? vitalStrategy,
    SymptomAnalysisStrategy? symptomStrategy,
  })  : _labStrategy = labStrategy ?? LabAnalysisStrategy(),
        _vitalStrategy = vitalStrategy ?? VitalAnalysisStrategy(),
        _symptomStrategy = symptomStrategy ?? SymptomAnalysisStrategy();

  /// Analyze lab results with confidence-based responses
  Future<SafeAnalysisResponse> analyzeLabWithConfidence({
    required String labCode,
    required double value,
    String? unit,
    String? patientCondition,
  }) {
    return _labStrategy.analyze(
      labCode: labCode,
      value: value,
      unit: unit,
      patientCondition: patientCondition,
    );
  }

  /// Analyze vital signs with confidence-based responses
  Future<SafeAnalysisResponse> analyzeVitalWithConfidence({
    required String vitalType,
    required double value,
    String? unit,
    Map<String, double>? relatedVitals,
  }) {
    return _vitalStrategy.analyze(
      vitalType: vitalType,
      value: value,
      unit: unit,
      relatedVitals: relatedVitals,
    );
  }

  /// Analyze symptoms with confidence-based responses
  Future<SafeAnalysisResponse> analyzeSymptomsWithConfidence({
    required List<String> symptoms,
    required List<String> currentMedications,
    List<String>? recentLabResults,
    String? knownCondition,
  }) {
    return _symptomStrategy.analyze(
      symptoms: symptoms,
      currentMedications: currentMedications,
      recentLabResults: recentLabResults,
      knownCondition: knownCondition,
    );
  }

  // ============ Original Methods (kept for compatibility) ============

  /// Analyze lab results and generate insights (original method)
  Future<List<MedicalInsight>> analyzeLabs({
    required Map<String, double> labValues,
    required List<Icd10Code> chronicConditions,
  }) async {
    final insights = <MedicalInsight>[];

    for (final entry in labValues.entries) {
      final loinc = await LoincCommonLabs.findByCode(entry.key);
      if (loinc != null) {
        final guideline = await ClinicalGuidelines.findByCode('CLSI-2017');
        insights.add(MedicalInsight(
          id: 'lab-${entry.key}',
          title: '${loinc.component} Analysis',
          description: loinc.description ?? 'Lab value: ${entry.value} ${loinc.unit}',
          severity: InsightSeverity.info,
          category: InsightCategory.labInterpretation,
          guidelineReference: guideline?.code ?? 'CLSI-2017',
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

  /// Calculate health risk scores (original method)
  Future<List<MedicalInsight>> calculateRisks({
    required Map<String, double> labValues,
    required Map<String, double> vitals,
    required List<Icd10Code> conditions,
  }) async {
    final insights = <MedicalInsight>[];

    final riskGuideline = await ClinicalGuidelines.findByCode('ACC-AHA-PRIMARY-2019');

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

  /// Get guidelines relevant to patient's conditions
  Future<List<ClinicalGuidelineReference>> getRelevantGuidelines(List<Icd10Code> conditions) async {
    final guidelines = <ClinicalGuidelineReference>[];
    for (final condition in conditions) {
      guidelines.addAll(await ClinicalGuidelines.findForCondition(condition.code));
    }
    return guidelines;
  }
}
