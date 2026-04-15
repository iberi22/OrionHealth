import 'package:medical_standards/medical_standards.dart';
import '../entities/user_profile.dart';

/// Service to analyze user profile and determine relevant medical context
class ProfileAnalysisService {
  /// Analyze user profile and return relevant standards
  RelevantStandards analyzeProfile(UserProfile profile) {
    final analyzer = ProfileAnalyzer();
    
    return analyzer.analyzeProfile(
      age: profile.age ?? 30, // Default age if not provided
      sex: profile.sex ?? 'M',
      currentConditions: profile.conditions,
      familyHistory: profile.familyHistory,
      currentMedications: profile.medications,
      symptoms: const [], // Symptoms collected separately in health record
    );
  }

  /// Get ICD-10 codes relevant to this profile
  List<Icd10Code> getRelevantIcd10Codes(UserProfile profile) {
    final standards = analyzeProfile(profile);
    final codes = <Icd10Code>[];
    
    for (final prefix in standards.icd10Codes) {
      // Find codes matching this prefix
      final found = Icd10ChronicConditions.all
          .where((c) => c.code.startsWith(prefix))
          .toList();
      codes.addAll(found);
    }
    
    return codes;
  }

  /// Get LOINC codes relevant to this profile
  List<LoincCode> getRelevantLoincCodes(UserProfile profile) {
    final standards = analyzeProfile(profile);
    final codes = <LoincCode>[];
    
    for (final code in standards.loincCodes) {
      final found = LoincCommonLabs.findByCode(code);
      if (found != null) {
        codes.add(found);
      }
    }
    
    return codes;
  }

  /// Get clinical guidelines relevant to this profile
  List<ClinicalGuidelineReference> getRelevantGuidelines(UserProfile profile) {
    final standards = analyzeProfile(profile);
    final guidelines = <ClinicalGuidelineReference>[];
    
    for (final id in standards.guidelineIds) {
      final found = ClinicalGuidelines.all
          .where((g) => g.code == id)
          .toList();
      guidelines.addAll(found);
    }
    
    return guidelines;
  }

  /// Get medication classes relevant to this profile
  List<String> getRelevantMedicationClasses(UserProfile profile) {
    final standards = analyzeProfile(profile);
    return standards.medicationClasses;
  }

  /// Estimate local storage size for this profile
  int estimateStorageSizeMb(UserProfile profile) {
    final standards = analyzeProfile(profile);
    return standards.estimatedSizeMB;
  }
}
