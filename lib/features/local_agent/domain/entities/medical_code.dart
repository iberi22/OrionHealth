import 'package:equatable/equatable.dart';

/// Represents a single medical code/standard entry (ICD-10, LOINC, RxNorm, SNOMED).
///
/// Designed for the vector store indexing pipeline: displayName (English)
/// and searchTerms (mostly Spanish) are both indexed for multi-lingual search.
class MedicalCode extends Equatable {
  /// Unique identifier within its standard
  final String code;

  /// Human-readable name (typically English, from the source standard)
  final String displayName;

  /// Clinical category (e.g. "Endocrine", "Hematology", "ACE Inhibitors")
  final String category;

  /// Which medical standard this code belongs to
  /// One of: "ICD-10", "LOINC", "RxNorm", "SNOMED"
  final String standard;

  /// Alternative search terms (mostly Spanish, some abbreviations)
  final List<String> searchTerms;

  const MedicalCode({
    required this.code,
    required this.displayName,
    required this.category,
    required this.standard,
    this.searchTerms = const [],
  });

  factory MedicalCode.fromJson(Map<String, dynamic> json, String standard) {
    return MedicalCode(
      code: json['code'] as String,
      displayName: json['displayName'] as String,
      category: (json['category'] as String?) ?? '',
      standard: standard,
      searchTerms: (json['searchTerms'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// All searchable text strings for embedding.
  /// Includes displayName (English) and all searchTerms (mostly Spanish).
  List<String> get allSearchableTerms => [displayName, ...searchTerms];

  /// Single text block for vector embedding - combines English displayName
  /// with Spanish search terms so the embedding captures both languages.
  String get embeddingText {
    final terms = searchTerms.isNotEmpty ? searchTerms.join(', ') : '';
    return '$displayName [$standard] - $category\n$terms'.trim();
  }

  @override
  List<Object?> get props => [code, standard];

  @override
  String toString() => 'MedicalCode($standard: $code - $displayName)';
}
