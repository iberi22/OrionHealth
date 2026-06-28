// ignore_for_file: dangling_library_doc_comments
/// The local subset of medical knowledge relevant to a user.
///
/// This is the downloaded and cached context that the AI assistant
/// uses for inference. Instead of loading a full 3GB standards database,
/// only the categories relevant to the user are stored locally (~50-200MB).


import 'package:equatable/equatable.dart';

import '../icd10/icd10.dart';
import '../loinc/loinc.dart';
import '../medications/medications.dart';
import '../guidelines/guidelines.dart';
import 'medical_context_categories.dart';

/// Raw query match result
class MedicalContext extends Equatable {
  final List<Icd10Code> icd10Matches;
  final List<LoincCode> labMatches;
  final List<MedicationReference> medicationMatches;
  final List<ClinicalGuidelineReference> guidelineMatches;

  const MedicalContext({
    this.icd10Matches = const [],
    this.labMatches = const [],
    this.medicationMatches = const [],
    this.guidelineMatches = const [],
  });

  bool get isEmpty =>
      icd10Matches.isEmpty &&
      labMatches.isEmpty &&
      medicationMatches.isEmpty &&
      guidelineMatches.isEmpty;

  @override
  List<Object?> get props => [
        icd10Matches,
        labMatches,
        medicationMatches,
        guidelineMatches,
      ];
}

/// The local subset of medical knowledge relevant to a user
class LocalMedicalContext {
  /// ICD-10 codes loaded for this user (code → object)
  final Map<String, Icd10Code> icd10Codes;

  /// LOINC lab codes loaded for this user (code → object)
  final Map<String, LoincCode> loincCodes;

  /// Medications loaded for this user (rxnorm code → object)
  final Map<String, MedicationReference> medications;

  /// Guidelines loaded for this user (id → object)
  final Map<String, ClinicalGuidelineReference> guidelines;

  /// Categories that have been fully downloaded
  final Set<MedicalContextCategory> downloadedCategories;

  /// Inverted index for fast text search (lowercased term → code)
  final Map<String, List<String>> _searchIndex;

  LocalMedicalContext({
    required this.icd10Codes,
    required this.loincCodes,
    required this.medications,
    required this.guidelines,
    required this.downloadedCategories,
    Map<String, List<String>>? searchIndex,
  }) : _searchIndex = searchIndex ?? _buildSearchIndex(icd10Codes, loincCodes, medications);

  static Map<String, List<String>> _buildSearchIndex(
    Map<String, Icd10Code> icd10Codes,
    Map<String, LoincCode> loincCodes,
    Map<String, MedicationReference> medications,
  ) {
    final index = <String, List<String>>{};

    void addToIndex(String term, String code) {
      final key = term.toLowerCase();
      index.putIfAbsent(key, () => []).add(code);
      // Also index each word
      for (final word in key.split(RegExp(r'\s+'))) {
        if (word.length > 3) {
          index.putIfAbsent(word, () => []).add(code);
        }
      }
    }

    for (final code in icd10Codes.values) {
      addToIndex(code.displayName, code.code);
      addToIndex(code.category, code.code);
      for (final syn in code.synonyms) {
        addToIndex(syn, code.code);
      }
    }

    for (final code in loincCodes.values) {
      addToIndex(code.displayName, 'loinc:${code.code}');
      addToIndex(code.component, 'loinc:${code.code}');
    }

    for (final med in medications.values) {
      addToIndex(med.displayName, 'med:${med.code}');
      if (med.genericName != null) {
        addToIndex(med.genericName!, 'med:${med.code}');
      }
      if (med.drugClass != null) {
        addToIndex(med.drugClass!, 'med:${med.code}');
      }
    }

    return index;
  }

  /// Check if we have any context for a query string
  bool hasContextFor(String query) {
    final key = query.toLowerCase();
    if (_searchIndex.containsKey(key)) return true;
    // Partial match
    for (final term in _searchIndex.keys) {
      if (term.contains(key) || key.contains(term)) {
        return true;
      }
    }
    return false;
  }

  /// Get relevant context for AI inference from a query.
  ///
  /// Searches across ICD-10, LOINC, medications, and guidelines
  /// and returns all matching concepts.
  MedicalContext getContextFor(String query) {
    final lower = query.toLowerCase();
    final icd10Matches = <Icd10Code>[];
    final labMatches = <LoincCode>[];
    final medicationMatches = <MedicationReference>[];
    final guidelineMatches = <ClinicalGuidelineReference>[];

    final matchedCodes = <String>{};

    // Direct index lookup
    if (_searchIndex.containsKey(lower)) {
      for (final code in _searchIndex[lower]!) {
        if (!matchedCodes.contains(code)) {
          matchedCodes.add(code);
        }
      }
    }

    // Partial/contains search
    for (final entry in _searchIndex.entries) {
      if (entry.key != lower &&
          (entry.key.contains(lower) || lower.contains(entry.key))) {
        for (final code in entry.value) {
          if (!matchedCodes.contains(code)) {
            matchedCodes.add(code);
          }
        }
      }
    }

    // Resolve codes to objects
    for (final code in matchedCodes) {
      if (code.startsWith('loinc:')) {
        final loinc = loincCodes[code.substring(6)];
        if (loinc != null) labMatches.add(loinc);
      } else if (code.startsWith('med:')) {
        final med = medications[code.substring(4)];
        if (med != null) medicationMatches.add(med);
      } else {
        final icd = icd10Codes[code];
        if (icd != null) icd10Matches.add(icd);
      }
    }

    // Also search guidelines directly
    for (final g in guidelines.values) {
      if (g.displayName.toLowerCase().contains(lower) ||
          (g.description?.toLowerCase().contains(lower) ?? false) ||
          g.organization.toLowerCase().contains(lower)) {
        guidelineMatches.add(g);
      }
    }

    return MedicalContext(
      icd10Matches: icd10Matches,
      labMatches: labMatches,
      medicationMatches: medicationMatches,
      guidelineMatches: guidelineMatches,
    );
  }

  /// Get all ICD-10 codes for a category
  List<Icd10Code> icd10For(MedicalContextCategory cat) {
    final codes = CategoryIcd10.forCategory(cat);
    return codes
        .map((c) => icd10Codes[c])
        .whereType<Icd10Code>()
        .toList();
  }

  /// Get all LOINC codes for a category
  List<LoincCode> loincFor(MedicalContextCategory cat) {
    final codes = CategoryLoinc.forCategory(cat);
    return codes
        .map((c) => loincCodes[c])
        .whereType<LoincCode>()
        .toList();
  }

  /// Get all medications for a category
  List<MedicationReference> medicationsFor(MedicalContextCategory cat) {
    final classes = CategoryMedications.forCategory(cat);
    return medications.values
        .where((m) =>
            m.drugClass != null &&
            classes.any((c) => m.drugClass!.contains(c)))
        .toList();
  }

  /// Number of entries across all standards
  int get totalEntries =>
      icd10Codes.length + loincCodes.length + medications.length + guidelines.length;

  @override
  String toString() =>
      'LocalMedicalContext(${downloadedCategories.length} categories, '
      '$totalEntries entries)';
}
