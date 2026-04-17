import 'package:medical_standards/medical_standards.dart';

abstract class MedicalStandardsService {
  /// ICD-10 codes lookup
  Future<Icd10Code?> lookupIcd10(String diagnosis);

  /// Drug interactions (DrugBank, RxNorm)
  Future<List<String>> checkDrugInteractions(List<String> rxnormCodes);

  /// SNOMED CT concepts
  Future<SnomedConcept?> lookupSnomed(String term);

  /// Clinical guidelines
  Future<List<ClinicalGuidelineReference>> searchGuidelines(String condition);
}
