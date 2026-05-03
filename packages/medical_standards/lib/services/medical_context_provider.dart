// Medical context provider for AI inference.
//
// Provides full local context from cached medical standards datasets.
// All lookups are local — NO network calls during inference.
//
// This is the key to accurate AI medical inference:
// - Full ICD-10 code lookups
// - LOINC lab code context
// - SNOMED CT concept resolution
// - Clinical guideline retrieval
// - Medication information
//
// Usage:
// ```dart
// final provider = MedicalContextProvider();
// await provider.initialize();
//
// // AI inference-time lookups (all local)
// final icd10 = provider.getIcd10ForCode('E11');
// final loinc = provider.getLoincForCode('4548-4');
// final guidelines = provider.getGuidelinesForCondition('E11');
// final medications = provider.getMedicationsForCondition('E11');
// ```

import '../medical_standards.dart';

/// Medical context provider - all local, no network calls during inference.
class MedicalContextProvider {
  /// Loaded ICD-10 entries.
  List<Icd10Code> _icd10Entries = [];

  /// Loaded LOINC entries.
  List<LoincCode> _loincEntries = [];

  /// Loaded SNOMED entries.
  List<SnomedConcept> _snomedEntries = [];

  /// Loaded RxNorm entries.
  List<MedicationReference> _rxnormEntries = [];

  /// Loaded guideline entries.
  List<ClinicalGuidelineReference> _guidelines = [];

  /// Whether the provider has been initialized.
  bool _isInitialized = false;

  /// Dataset version info.
  final Map<String, String> _versions = {};

  bool get isInitialized => _isInitialized;

  /// Initialize the provider by loading all local data.
  ///
  /// This uses the specialized Catalog loaders in each standard.
  Future<void> initialize() async {
    if (_isInitialized) return;

    _loadVersions();

    final results = await Future.wait([
      Icd10Catalog.load(),
      LoincCatalog.load(),
      SnomedCatalog.load(),
      MedicationCatalog.load(),
      ClinicalGuidelines.load(),
    ]);

    _icd10Entries = results[0] as List<Icd10Code>;
    _loincEntries = results[1] as List<LoincCode>;
    _snomedEntries = results[2] as List<SnomedConcept>;
    _rxnormEntries = results[3] as List<MedicationReference>;
    _guidelines = results[4] as List<ClinicalGuidelineReference>;

    _isInitialized = true;
  }

  void _loadVersions() {
    // These could be potentially loaded from standards_manifest.json if needed
    _versions.addAll({
      'icd10': '2024-1',
      'loinc': '2.72',
      'snomed': '2024-01-31',
      'rxnorm': '2024-03-04',
      'guidelines': '1.0.0',
    });
  }

  // ============================================================
  // ICD-10 Lookups (NO network calls)
  // ============================================================

  /// Get ICD-10 entry by code.
  Icd10Code? getIcd10ForCode(String code) {
    try {
      return _icd10Entries.firstWhere((e) => e.code == code);
    } catch (_) {
      return null;
    }
  }

  /// Search ICD-10 entries by keyword (in code, name, or synonyms).
  List<Icd10Code> searchIcd10(String keyword) {
    final kw = keyword.toLowerCase();
    return _icd10Entries.where((e) {
      return e.code.toLowerCase().contains(kw) ||
          e.displayName.toLowerCase().contains(kw) ||
          e.synonyms.any((s) => s.toLowerCase().contains(kw));
    }).toList();
  }

  /// Get all ICD-10 entries in a category.
  List<Icd10Code> getIcd10ByCategory(String category) {
    return _icd10Entries
        .where((e) => e.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  /// All ICD-10 entries (for AI context).
  List<Icd10Code> get allIcd10 => _icd10Entries;

  // ============================================================
  // LOINC Lookups (NO network calls)
  // ============================================================

  /// Get LOINC entry by code.
  LoincCode? getLoincForCode(String code) {
    try {
      return _loincEntries.firstWhere((e) => e.code == code);
    } catch (_) {
      return null;
    }
  }

  /// Search LOINC entries by component name.
  List<LoincCode> searchLoinc(String keyword) {
    final kw = keyword.toLowerCase();
    return _loincEntries.where((e) {
      return e.code.toLowerCase().contains(kw) ||
          e.displayName.toLowerCase().contains(kw) ||
          e.component.toLowerCase().contains(kw);
    }).toList();
  }

  /// All LOINC entries (for AI context).
  List<LoincCode> get allLoinc => _loincEntries;

  // ============================================================
  // SNOMED CT Lookups (NO network calls)
  // ============================================================

  /// Get SNOMED CT concept by code.
  SnomedConcept? getSnomedForCode(String code) {
    try {
      return _snomedEntries.firstWhere((e) => e.code == code);
    } catch (_) {
      return null;
    }
  }

  /// Get SNOMED CT concept by ICD-10 mapping.
  SnomedConcept? getSnomedForIcd10(String icd10Code) {
    try {
      return _snomedEntries.firstWhere(
        (e) => e.icd10Mappings.contains(icd10Code),
      );
    } catch (_) {
      return null;
    }
  }

  /// Search SNOMED CT concepts by keyword.
  List<SnomedConcept> searchSnomed(String keyword) {
    final kw = keyword.toLowerCase();
    return _snomedEntries.where((e) {
      return e.code.toLowerCase().contains(kw) ||
          e.displayName.toLowerCase().contains(kw) ||
          (e.fullySpecifiedName?.toLowerCase().contains(kw) ?? false);
    }).toList();
  }

  /// All SNOMED CT entries (for AI context).
  List<SnomedConcept> get allSnomed => _snomedEntries;

  // ============================================================
  // RxNorm Medication Lookups (NO network calls)
  // ============================================================

  /// Get RxNorm medication by code.
  MedicationReference? getRxnormForCode(String code) {
    try {
      return _rxnormEntries.firstWhere((e) => e.code == code);
    } catch (_) {
      return null;
    }
  }

  /// Get medications by drug class.
  List<MedicationReference> getMedicationsByClass(String drugClass) {
    final dc = drugClass.toLowerCase();
    return _rxnormEntries
        .where((m) => m.drugClass?.toLowerCase().contains(dc) ?? false)
        .toList();
  }

  /// Search medications by keyword.
  List<MedicationReference> searchMedications(String keyword) {
    final kw = keyword.toLowerCase();
    return _rxnormEntries.where((m) {
      return m.code.toLowerCase().contains(kw) ||
          m.displayName.toLowerCase().contains(kw) ||
          (m.genericName?.toLowerCase().contains(kw) ?? false) ||
          (m.drugClass?.toLowerCase().contains(kw) ?? false);
    }).toList();
  }

  /// All RxNorm entries (for AI context).
  List<MedicationReference> get allMedications => _rxnormEntries;

  // ============================================================
  // Clinical Guidelines Lookups (NO network calls)
  // ============================================================

  /// Get clinical guidelines applicable to an ICD-10 code.
  List<ClinicalGuidelineReference> getGuidelinesForCondition(String icd10Code) {
    return _guidelines
        .where((g) => g.applicableConditions.contains(icd10Code))
        .toList();
  }

  /// Get guidelines by organization.
  List<ClinicalGuidelineReference> getGuidelinesByOrganization(String org) {
    final o = org.toLowerCase();
    return _guidelines
        .where((g) => g.organization.toLowerCase().contains(o))
        .toList();
  }

  /// All guidelines (for AI context).
  List<ClinicalGuidelineReference> get allGuidelines => _guidelines;

  // ============================================================
  // Cross-Standard Lookups (NO network calls)
  // ============================================================

  /// Get full clinical context for an ICD-10 diagnosis code.
  Map<String, dynamic> getFullContextForDiagnosis(String icd10Code) {
    final icd10 = getIcd10ForCode(icd10Code);
    final snomed = getSnomedForIcd10(icd10Code);

    if (icd10 == null) return {'found': false};

    // Find relevant labs from SNOMED mappings
    final relevantLoinc = <LoincCode>[];
    if (snomed != null) {
      for (final loincCode in snomed.loincMappings) {
        final loinc = getLoincForCode(loincCode);
        if (loinc != null) relevantLoinc.add(loinc);
      }
    }

    // Find medications potentially related to this condition category
    final category = icd10.category.toLowerCase();
    final relevantMeds = _rxnormEntries.where((m) {
      final drugClass = m.drugClass?.toLowerCase() ?? '';
      // Map condition categories to drug classes
      if (category.contains('endocrine') || category.contains('diabetes')) {
        return drugClass.contains('biguanide') ||
            drugClass.contains('sulfonylurea') ||
            drugClass.contains('insulin') ||
            drugClass.contains('statin');
      }
      if (category.contains('mental')) {
        return drugClass.contains('ssri') ||
            drugClass.contains('benzodiazepine');
      }
      if (category.contains('respiratory')) {
        return drugClass.contains('bronchodilator') ||
            drugClass.contains('corticosteroid');
      }
      return false;
    }).toList();

    final guidelines = getGuidelinesForCondition(icd10Code);

    return {
      'found': true,
      'icd10': icd10,
      'snomed': snomed,
      'relevantLabs': relevantLoinc,
      'relevantMedications': relevantMeds,
      'guidelines': guidelines,
      'versions': _versions,
    };
  }

  /// Get full clinical context for a LOINC lab code.
  Map<String, dynamic> getFullContextForLab(String loincCode) {
    final loinc = getLoincForCode(loincCode);
    if (loinc == null) return {'found': false};

    // Find SNOMED concepts that reference this LOINC code
    final snomedConcepts = _snomedEntries
        .where((s) => s.loincMappings.contains(loincCode))
        .toList();

    // Find related LOINC tests
    final component = loinc.component.toLowerCase();
    final relatedLoinc = _loincEntries.where((l) {
      if (l.code == loincCode) return false;
      return l.component.toLowerCase().contains(component) ||
          l.displayName.toLowerCase().contains(component);
    }).toList();

    return {
      'found': true,
      'loinc': loinc,
      'snomedConcepts': snomedConcepts,
      'relatedLabs': relatedLoinc,
      'versions': _versions,
    };
  }

  /// Get all loaded versions for debugging/status.
  Map<String, String> get versions => Map.unmodifiable(_versions);

  /// Get dataset statistics.
  Map<String, int> get statistics => {
        'icd10': _icd10Entries.length,
        'loinc': _loincEntries.length,
        'snomed': _snomedEntries.length,
        'rxnorm': _rxnormEntries.length,
        'guidelines': _guidelines.length,
      };
}
