import '../entities/user_profile.dart';

/// Result of analyzing a user profile for relevant medical standards.
class RelevantStandards {
  final List<String> icd10Codes;
  final List<String> loincCodes;
  final List<String> guidelineIds;
  final List<String> medicationClasses;
  final int estimatedSizeMB;

  const RelevantStandards({
    this.icd10Codes = const [],
    this.loincCodes = const [],
    this.guidelineIds = const [],
    this.medicationClasses = const [],
    this.estimatedSizeMB = 0,
  });
}

/// Service to analyze user profile and determine relevant medical context
class ProfileAnalysisService {
  /// Analyze user profile and return relevant standards
  RelevantStandards analyzeProfile(UserProfile profile) {
    // Analyze profile based on conditions, medications, etc.
    final icd10Codes = <String>[];
    final loincCodes = <String>[];
    final guidelineIds = <String>[];
    final medicationClasses = <String>[];

    // Map known conditions to ICD-10 codes
    for (final condition in profile.conditions) {
      final lower = condition.toLowerCase();
      if (lower.contains('diabetes')) {
        icd10Codes.add('E10');
        icd10Codes.add('E11');
        loincCodes.add('2345-7'); // Glucose
        loincCodes.add('4548-4'); // HbA1c
        guidelineIds.add('ADA-2024');
        medicationClasses.add('insulin');
        medicationClasses.add('metformin');
      } else if (lower.contains('hypertension') || lower.contains('hta')) {
        icd10Codes.add('I10');
        icd10Codes.add('I11');
        loincCodes.add('8480-6'); // Systolic BP
        loincCodes.add('8462-4'); // Diastolic BP
        guidelineIds.add('JNC-8');
        medicationClasses.add('ace_inhibitors');
        medicationClasses.add('beta_blockers');
      } else if (lower.contains('thyroid')) {
        icd10Codes.add('E03');
        icd10Codes.add('E05');
        loincCodes.add('3024-0'); // TSH
        loincCodes.add('3051-3'); // T4
        guidelineIds.add('ATA-2023');
      }
    }

    // Map medications to classes
    for (final med in profile.medications) {
      final lower = med.toLowerCase();
      if (lower.contains('insulin') || lower.contains('metformin') || lower.contains('glipizide')) {
        if (!medicationClasses.contains('diabetes_medications')) {
          medicationClasses.add('diabetes_medications');
        }
      } else if (lower.contains('lisinopril') || lower.contains('enalapril')) {
        if (!medicationClasses.contains('ace_inhibitors')) {
          medicationClasses.add('ace_inhibitors');
        }
      }
    }

    // Estimate size based on number of codes
    final estimatedSizeMB = (icd10Codes.length * 5) + (loincCodes.length * 3) + (guidelineIds.length * 10);

    return RelevantStandards(
      icd10Codes: icd10Codes,
      loincCodes: loincCodes,
      guidelineIds: guidelineIds,
      medicationClasses: medicationClasses,
      estimatedSizeMB: estimatedSizeMB,
    );
  }

  /// Estimate local storage size for this profile
  int estimateStorageSizeMb(UserProfile profile) {
    final standards = analyzeProfile(profile);
    return standards.estimatedSizeMB;
  }
}
