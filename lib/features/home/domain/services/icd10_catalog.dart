import 'package:medical_standards/medical_standards.dart';

/// Local catalog for ICD-10 code lookups.
/// Bridges the Icd10ChronicConditions class with a findByCode API.
class Icd10Catalog {
  /// Find an Icd10Code by its code string (e.g., "E11", "I10").
  /// Returns null if not found.
  static Icd10Code? findByCode(String code) {
    try {
      return Icd10ChronicConditions.all.firstWhere(
        (c) => c.code == code,
      );
    } catch (_) {
      return null;
    }
  }

  /// Search for codes by display name or synonym (case-insensitive).
  static List<Icd10Code> search(String query) {
    final lower = query.toLowerCase();
    return Icd10ChronicConditions.all.where((c) {
      return c.displayName.toLowerCase().contains(lower) ||
          c.synonyms.any((s) => s.toLowerCase().contains(lower)) ||
          c.code.toLowerCase().contains(lower);
    }).toList();
  }
}
