import 'package:injectable/injectable.dart';
import 'package:medical_standards/medical_standards.dart';

/// Service for matching patient clinical data with medical guidelines.
@injectable
class MedicalGuidelinesService {
  /// Find guidelines relevant to a list of conditions (ICD-10 codes).
  ///
  /// Results are deduplicated.
  List<ClinicalGuidelineReference> getGuidelinesForConditions(List<String> conditionCodes) {
    if (conditionCodes.isEmpty) return [];

    // ClinicalGuidelines.findForConditions already filters from the full list
    final guidelines = ClinicalGuidelines.findForConditions(conditionCodes);

    // Ensure uniqueness based on guideline code
    final seen = <String>{};
    return guidelines.where((g) => seen.add(g.code)).toList();
  }

  /// Find guidelines that apply to a specific set of lab results.
  ///
  /// This can be used to suggest guidelines even without a formal diagnosis.
  List<ClinicalGuidelineReference> getGuidelinesForLabs(List<String> loincCodes) {
    if (loincCodes.isEmpty) return [];

    final guidelines = <ClinicalGuidelineReference>[];

    if (loincCodes.any((c) => c.contains('4548-4') || c.contains('2345-7'))) {
      guidelines.add(ClinicalGuidelines.adaStandards);
    }

    if (loincCodes.any((c) => c.contains('2093-3') || c.contains('13457-7'))) {
      guidelines.add(ClinicalGuidelines.ahaCholesterol);
    }

    // Add generic lab reference if any labs are present
    guidelines.add(ClinicalGuidelines.labReferenceRanges);

    final seen = <String>{};
    return guidelines.where((g) => seen.add(g.code)).toList();
  }

  /// Get a specific guideline by its unique code.
  ClinicalGuidelineReference? getGuidelineByCode(String code) {
    return ClinicalGuidelines.findByCode(code);
  }
}
