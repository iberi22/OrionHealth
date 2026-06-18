/// Medical context provider for AI inference.
///
/// Provides full local context from cached medical standards datasets.
/// All lookups are local — NO network calls during inference.
///
/// This is the key to accurate AI medical inference:
/// - Full ICD-10 code lookups
/// - LOINC lab code context
/// - SNOMED CT concept resolution
/// - Clinical guideline retrieval
/// - Medication information
///
/// Usage:
/// ```dart
/// final provider = MedicalContextProvider();
/// await provider.initialize();
///
/// // AI inference-time lookups (all local)
/// final icd10 = provider.getIcd10ForCode('E11');
/// final loinc = provider.getLoincForCode('4548-4');
/// final guidelines = provider.getGuidelinesForCondition('E11');
/// final medications = provider.getMedicationsForCondition('E11');
/// ```
library;

import 'dart:convert';
import 'dart:io';

import '../medical_standards.dart';

/// Represents a loaded ICD-10 entry from local data.
class LocalIcd10Entry {
  final String code;
  final String displayName;
  final String category;
  final List<String> synonyms;

  const LocalIcd10Entry({
    required this.code,
    required this.displayName,
    required this.category,
    this.synonyms = const [],
  });

  factory LocalIcd10Entry.fromJson(Map<String, dynamic> json) {
    return LocalIcd10Entry(
      code: json['code'] as String,
      displayName: json['displayName'] as String,
      category: json['category'] as String,
      synonyms: (json['synonyms'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }
}

/// Represents a loaded LOINC entry from local data.
class LocalLoincEntry {
  final String code;
  final String displayName;
  final String component;
  final String property;
  final String unit;
  final String? description;

  const LocalLoincEntry({
    required this.code,
    required this.displayName,
    required this.component,
    required this.property,
    required this.unit,
    this.description,
  });

  factory LocalLoincEntry.fromJson(Map<String, dynamic> json) {
    return LocalLoincEntry(
      code: json['code'] as String,
      displayName: json['displayName'] as String,
      component: json['component'] as String,
      property: json['property'] as String,
      unit: json['unit'] as String,
      description: json['description'] as String?,
    );
  }
}

/// Represents a loaded SNOMED CT concept from local data.
class LocalSnomedEntry {
  final String code;
  final String displayName;
  final String? fullySpecifiedName;
  final String? semanticTag;
  final List<String> icd10Mappings;
  final List<String> loincMappings;
  final String? description;

  const LocalSnomedEntry({
    required this.code,
    required this.displayName,
    this.fullySpecifiedName,
    this.semanticTag,
    this.icd10Mappings = const [],
    this.loincMappings = const [],
    this.description,
  });

  factory LocalSnomedEntry.fromJson(Map<String, dynamic> json) {
    return LocalSnomedEntry(
      code: json['code'] as String,
      displayName: json['displayName'] as String,
      fullySpecifiedName: json['fullySpecifiedName'] as String?,
      semanticTag: json['semanticTag'] as String?,
      icd10Mappings: (json['icd10Mappings'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      loincMappings: (json['loincMappings'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      description: json['description'] as String?,
    );
  }
}

/// Represents a loaded RxNorm medication entry from local data.
class LocalRxnormEntry {
  final String code;
  final String displayName;
  final String? genericName;
  final String? drugClass;
  final List<String> routes;
  final List<String> commonDosages;
  final String? description;

  const LocalRxnormEntry({
    required this.code,
    required this.displayName,
    this.genericName,
    this.drugClass,
    this.routes = const [],
    this.commonDosages = const [],
    this.description,
  });

  factory LocalRxnormEntry.fromJson(Map<String, dynamic> json) {
    return LocalRxnormEntry(
      code: json['code'] as String,
      displayName: json['displayName'] as String,
      genericName: json['genericName'] as String?,
      drugClass: json['drugClass'] as String?,
      routes: (json['routes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      commonDosages: (json['commonDosages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      description: json['description'] as String?,
    );
  }
}

/// Medical context provider - all local, no network calls during inference.
class MedicalContextProvider {
  /// Loaded ICD-10 entries keyed by code.
  Map<String, LocalIcd10Entry> _icd10Map = {};

  /// Loaded LOINC entries keyed by code.
  Map<String, LocalLoincEntry> _loincMap = {};

  /// Loaded SNOMED entries keyed by code.
  Map<String, LocalSnomedEntry> _snomedMap = {};

  /// Loaded RxNorm entries keyed by code.
  Map<String, LocalRxnormEntry> _rxnormMap = {};

  /// All loaded ICD-10 entries.
  List<LocalIcd10Entry> _icd10Entries = [];

  /// All loaded LOINC entries.
  List<LocalLoincEntry> _loincEntries = [];

  /// All loaded SNOMED entries.
  List<LocalSnomedEntry> _snomedEntries = [];

  /// All loaded RxNorm entries.
  List<LocalRxnormEntry> _rxnormEntries = [];

  /// Loaded guideline entries.
  List<ClinicalGuidelineReference> _guidelines = [];

  /// Whether the provider has been initialized.
  bool _isInitialized = false;

  /// Dataset version info.
  Map<String, String> _versions = {};

  bool get isInitialized => _isInitialized;

  /// Get the directory containing the data files.
  String get _dataDir {
    // For package usage, data is in the package's data/ directory.
    // This uses the running script's location to find the package root.
    final scriptPath = File(Platform.script.toFilePath()).parent.path;
    return scriptPath;
  }

  /// Initialize the provider by loading all local data.
  ///
  /// This is the ONLY time file I/O happens. After initialization,
  /// all lookups are purely in-memory.
  Future<void> initialize() async {
    if (_isInitialized) return;

    _loadVersions();

    await Future.wait<void>([
      _loadIcd10(),
      _loadLoinc(),
      _loadSnomed(),
      _loadRxnorm(),
    ]);
    _loadGuidelines();

    _buildIndexes();

    _isInitialized = true;
  }

  void _loadVersions() {
    _versions = {
      'icd10': '2024-1',
      'loinc': '2.72',
      'snomed': '2024-01-31',
      'rxnorm': '2024-03-04',
    };
  }

  /// Load ICD-10 data from local JSON.
  Future<void> _loadIcd10() async {
    try {
      final file = File('$_dataDir/data/full_icd10.json');
      if (!await file.exists()) return;

      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;

      _versions['icd10'] = json['metadata']?['version'] ?? 'unknown';

      final dataList = json['data'] as List<dynamic>;
      _icd10Entries = dataList
          .map((e) => LocalIcd10Entry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {}
  }

  /// Load LOINC data from local JSON.
  Future<void> _loadLoinc() async {
    try {
      final file = File('$_dataDir/data/full_loinc.json');
      if (!await file.exists()) return;

      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;

      _versions['loinc'] = json['metadata']?['version'] ?? 'unknown';

      final dataList = json['data'] as List<dynamic>;
      _loincEntries = dataList
          .map((e) => LocalLoincEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {}
  }

  /// Load SNOMED CT data from local JSON.
  Future<void> _loadSnomed() async {
    try {
      final file = File('$_dataDir/data/full_snomed.json');
      if (!await file.exists()) return;

      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;

      _versions['snomed'] = json['metadata']?['version'] ?? 'unknown';

      final dataList = json['data'] as List<dynamic>;
      _snomedEntries = dataList
          .map((e) => LocalSnomedEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {}
  }

  /// Load RxNorm data from local JSON.
  Future<void> _loadRxnorm() async {
    try {
      final file = File('$_dataDir/data/full_rxnorm.json');
      if (!await file.exists()) return;

      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;

      _versions['rxnorm'] = json['metadata']?['version'] ?? 'unknown';

      final dataList = json['data'] as List<dynamic>;
      _rxnormEntries = dataList
          .map((e) => LocalRxnormEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {}
  }

  /// Load clinical guidelines from the Dart library.
  Future<void> _loadGuidelines() async {
    _guidelines = ClinicalGuidelines.all;
  }

  /// Build in-memory indexes for fast lookups.
  void _buildIndexes() {
    _icd10Map = {for (final e in _icd10Entries) e.code: e};
    _loincMap = {for (final e in _loincEntries) e.code: e};
    _snomedMap = {for (final e in _snomedEntries) e.code: e};
    _rxnormMap = {for (final e in _rxnormEntries) e.code: e};
  }

  // ============================================================
  // ICD-10 Lookups (NO network calls)
  // ============================================================

  /// Get ICD-10 entry by code.
  ///
  /// Example: `getIcd10ForCode('E11')` returns Type 2 diabetes info.
  LocalIcd10Entry? getIcd10ForCode(String code) {
    return _icd10Map[code];
  }

  /// Search ICD-10 entries by keyword (in code, name, or synonyms).
  ///
  /// Example: `searchIcd10('diabetes')` returns all diabetes codes.
  List<LocalIcd10Entry> searchIcd10(String keyword) {
    final kw = keyword.toLowerCase();
    return _icd10Entries.where((e) {
      return e.code.toLowerCase().contains(kw) ||
          e.displayName.toLowerCase().contains(kw) ||
          e.synonyms.any((s) => s.toLowerCase().contains(kw));
    }).toList();
  }

  /// Get all ICD-10 entries in a category.
  List<LocalIcd10Entry> getIcd10ByCategory(String category) {
    return _icd10Entries
        .where((e) => e.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  /// All ICD-10 entries (for AI context).
  List<LocalIcd10Entry> get allIcd10 => _icd10Entries;

  // ============================================================
  // LOINC Lookups (NO network calls)
  // ============================================================

  /// Get LOINC entry by code.
  ///
  /// Example: `getLoincForCode('4548-4')` returns HbA1c info.
  LocalLoincEntry? getLoincForCode(String code) {
    return _loincMap[code];
  }

  /// Search LOINC entries by component name.
  ///
  /// Example: `searchLoinc('glucose')` returns glucose-related lab codes.
  List<LocalLoincEntry> searchLoinc(String keyword) {
    final kw = keyword.toLowerCase();
    return _loincEntries.where((e) {
      return e.code.toLowerCase().contains(kw) ||
          e.displayName.toLowerCase().contains(kw) ||
          e.component.toLowerCase().contains(kw);
    }).toList();
  }

  /// All LOINC entries (for AI context).
  List<LocalLoincEntry> get allLoinc => _loincEntries;

  // ============================================================
  // SNOMED CT Lookups (NO network calls)
  // ============================================================

  /// Get SNOMED CT concept by code.
  ///
  /// Example: `getSnomedForCode('44054006')` returns Type 2 diabetes.
  LocalSnomedEntry? getSnomedForCode(String code) {
    return _snomedMap[code];
  }

  /// Get SNOMED CT concept by ICD-10 mapping.
  ///
  /// Example: `getSnomedForIcd10('E11')` returns Type 2 diabetes SNOMED concept.
  LocalSnomedEntry? getSnomedForIcd10(String icd10Code) {
    try {
      return _snomedEntries.firstWhere(
        (e) => e.icd10Mappings.contains(icd10Code),
      );
    } catch (_) {
      return null;
    }
  }

  /// Search SNOMED CT concepts by keyword.
  List<LocalSnomedEntry> searchSnomed(String keyword) {
    final kw = keyword.toLowerCase();
    return _snomedEntries.where((e) {
      return e.code.toLowerCase().contains(kw) ||
          e.displayName.toLowerCase().contains(kw) ||
          (e.fullySpecifiedName?.toLowerCase().contains(kw) ?? false);
    }).toList();
  }

  /// All SNOMED CT entries (for AI context).
  List<LocalSnomedEntry> get allSnomed => _snomedEntries;

  // ============================================================
  // RxNorm Medication Lookups (NO network calls)
  // ============================================================

  /// Get RxNorm medication by code.
  LocalRxnormEntry? getRxnormForCode(String code) {
    return _rxnormMap[code];
  }

  /// Get medications by drug class.
  ///
  /// Example: `getMedicationsByClass('Statin')` returns all statins.
  List<LocalRxnormEntry> getMedicationsByClass(String drugClass) {
    final dc = drugClass.toLowerCase();
    return _rxnormEntries
        .where((m) => m.drugClass?.toLowerCase().contains(dc) ?? false)
        .toList();
  }

  /// Search medications by keyword.
  List<LocalRxnormEntry> searchMedications(String keyword) {
    final kw = keyword.toLowerCase();
    return _rxnormEntries.where((m) {
      return m.code.toLowerCase().contains(kw) ||
          m.displayName.toLowerCase().contains(kw) ||
          (m.genericName?.toLowerCase().contains(kw) ?? false) ||
          (m.drugClass?.toLowerCase().contains(kw) ?? false);
    }).toList();
  }

  /// All RxNorm entries (for AI context).
  List<LocalRxnormEntry> get allMedications => _rxnormEntries;

  // ============================================================
  // Clinical Guidelines Lookups (NO network calls)
  // ============================================================

  /// Get clinical guidelines applicable to an ICD-10 code.
  ///
  /// Example: `getGuidelinesForCondition('E11')` returns ADA guidelines
  /// for Type 2 diabetes.
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
  ///
  /// Returns a map with ICD-10 details, SNOMED mapping, applicable
  /// LOINC labs, relevant medications, and clinical guidelines.
  Map<String, dynamic> getFullContextForDiagnosis(String icd10Code) {
    final icd10 = getIcd10ForCode(icd10Code);
    final snomed = getSnomedForIcd10(icd10Code);

    if (icd10 == null) return {'found': false};

    // Find relevant labs from SNOMED mappings
    final relevantLoinc = <LocalLoincEntry>[];
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
