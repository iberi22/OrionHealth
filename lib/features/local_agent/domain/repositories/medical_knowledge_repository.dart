import '../entities/medical_code.dart';

/// Repository interface for querying medical knowledge (standards).
///
/// Provides search by code, term, and category across all 4 standards
/// (ICD-10, LOINC, RxNorm, SNOMED) with multi-lingual support.
/// Searches displayName (English) and searchTerms (Spanish/abbreviations)
/// simultaneously.
abstract class MedicalKnowledgeRepository {
  /// Load all medical codes from all standards into memory.
  /// Called once at startup (or on-demand).
  Future<void> initialize({bool force = false});

  /// Checks for interactions between a list of RxNorm drug codes.
  Future<List<Map<String, dynamic>>> checkInteractions(List<String> drugCodes);

  /// Whether the repository has been initialized.
  bool get isInitialized;

  /// Find a single code by its exact code string (e.g. "E10", "718-7").
  /// Searches across ALL standards. Returns the first match or null.
  Future<MedicalCode?> searchByCode(String code);

  /// Find codes in a specific standard by exact code string.
  Future<MedicalCode?> searchByCodeInStandard(String code, String standard);

  /// Search all searchable text (displayName + searchTerms) for a term.
  /// Multi-lingual: queries "diabetes" will find "Diabetes tipo 1" (Spanish)
  /// and "Type 1 diabetes" (English).
  Future<List<MedicalCode>> searchByTerm(String searchTerm);

  /// Search within a specific standard by term.
  Future<List<MedicalCode>> searchByTermInStandard(
    String searchTerm,
    String standard,
  );

  /// Get all codes in a given category (e.g. "Endocrine", "Hematology").
  Future<List<MedicalCode>> searchByCategory(String category);

  /// Get all codes, optionally filtered by standard.
  Future<List<MedicalCode>> getAllCodes({String? standard});

  /// Get statistics — count per standard, total, initialization state.
  Map<String, dynamic> getStats();
}
