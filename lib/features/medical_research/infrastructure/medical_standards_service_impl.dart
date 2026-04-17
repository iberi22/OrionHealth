import 'package:injectable/injectable.dart';
import 'package:medical_standards/medical_standards.dart';
import '../domain/services/medical_standards_service.dart';

@LazySingleton(as: MedicalStandardsService)
class MedicalStandardsServiceImpl implements MedicalStandardsService {
  final MedicalContextProvider _medicalContextProvider;

  MedicalStandardsServiceImpl(this._medicalContextProvider);

  @override
  Future<Icd10Code?> lookupIcd10(String diagnosis) async {
    if (!_medicalContextProvider.isInitialized) {
      await _medicalContextProvider.initialize();
    }
    final results = _medicalContextProvider.searchIcd10(diagnosis);
    return results.isNotEmpty ? results.first : null;
  }

  @override
  Future<SnomedConcept?> lookupSnomed(String term) async {
    if (!_medicalContextProvider.isInitialized) {
      await _medicalContextProvider.initialize();
    }
    final results = _medicalContextProvider.searchSnomed(term);
    return results.isNotEmpty ? results.first : null;
  }

  @override
  Future<List<ClinicalGuidelineReference>> searchGuidelines(String condition) async {
    if (!_medicalContextProvider.isInitialized) {
      await _medicalContextProvider.initialize();
    }
    // Search by keyword if it's not a direct code
    final icd10 = await lookupIcd10(condition);
    if (icd10 != null) {
      return _medicalContextProvider.getGuidelinesForCondition(icd10.code);
    }
    return [];
  }

  @override
  Future<List<String>> checkDrugInteractions(List<String> rxnormCodes) async {
    if (!_medicalContextProvider.isInitialized) {
      await _medicalContextProvider.initialize();
    }

    final interactions = <String>[];

    // Simple rule-based interaction engine for major medical standards
    // In a production app, this would call a dedicated Drug Interaction API (like DrugBank)
    // or use a local cross-reference table.

    final meds = rxnormCodes.map((code) => _medicalContextProvider.getRxnormForCode(code)).whereType<MedicationReference>().toList();

    for (int i = 0; i < meds.length; i++) {
      for (int j = i + 1; j < meds.length; j++) {
        final m1 = meds[i];
        final m2 = meds[j];

        final interaction = _getKnownInteraction(m1, m2);
        if (interaction != null) {
          interactions.add(interaction);
        }
      }
    }

    return interactions;
  }

  String? _getKnownInteraction(MedicationReference m1, MedicationReference m2) {
    final names = {m1.displayName.toLowerCase(), m2.displayName.toLowerCase()};

    if (names.contains('warfarin') && names.contains('aspirin')) {
      return 'Major Interaction: Warfarin + Aspirin. Increased risk of bleeding.';
    }
    if (names.contains('metformin') && names.contains('contrast medium')) {
      return 'Moderate Interaction: Metformin + Contrast. Risk of lactic acidosis.';
    }
    if (names.contains('lisinopril') && names.contains('spironolactone')) {
      return 'Moderate Interaction: ACE Inhibitor + Spironolactone. Risk of hyperkalemia.';
    }

    // Drug class based interactions
    final classes = {m1.drugClass?.toLowerCase() ?? '', m2.drugClass?.toLowerCase() ?? ''};
    if (classes.contains('ssri') && classes.contains('maoi')) {
      return 'Contraindicated: SSRI + MAOI. Risk of Serotonin Syndrome.';
    }
    if (classes.contains('nsaid') && classes.contains('anticoagulant')) {
      return 'Moderate Interaction: NSAID + Anticoagulant. Increased bleeding risk.';
    }

    return null;
  }
}
