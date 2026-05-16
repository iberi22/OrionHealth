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

  // ============ Legacy methods delegated to strategies ============

  /// Analyze lab results and generate insights (delegated)
  Future<List<MedicalInsight>> analyzeLabs({
    required Map<String, double> labValues,
    required List<Icd10Code> chronicConditions,
  }) =>
      _labStrategy.analyzeBatch(
        labValues: labValues,
        chronicConditions: chronicConditions,
      );

  /// Analyze vital signs and generate insights (delegated)
  Future<List<MedicalInsight>> analyzeVitals({
    required Map<String, double> vitals,
    required List<Icd10Code> chronicConditions,
  }) =>
      _vitalStrategy.analyzeBatch(
        vitals: vitals,
        chronicConditions: chronicConditions,
      );

  /// Calculate health risk scores (delegated)
  Future<List<MedicalInsight>> calculateRisks({
    required Map<String, double> labValues,
    required Map<String, double> vitals,
    required List<Icd10Code> conditions,
  }) =>
      _vitalStrategy.calculateRisks(
        labValues: labValues,
        vitals: vitals,
        conditions: conditions,
      );

  /// Get guidelines relevant to patient's conditions
  Future<List<ClinicalGuidelineReference>> getRelevantGuidelines(List<Icd10Code> conditions) async {
    final guidelines = <ClinicalGuidelineReference>[];
    for (final condition in conditions) {
      guidelines.addAll(await ClinicalGuidelines.findForCondition(condition.code));
    }
    return guidelines;
  }
}
