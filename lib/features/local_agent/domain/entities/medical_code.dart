import 'package:equatable/equatable.dart';

/// Represents a single medical code/standard entry (ICD-10, LOINC, RxNorm, SNOMED).
///
/// Designed for the vector store indexing pipeline: displayName (English)
/// and searchTerms (mostly Spanish) are both indexed for multi-lingual search.
class MedicalCode extends Equatable {
  final String code;
  final String displayName;
  final String category;
  final String standard;
  final List<String> searchTerms;

  /// Clinical definition or description
  final String? definition;

  /// Connection to mental health (for physical codes)
  final String? mentalHealthImpact;

  /// Connection to physical health (for mental codes)
  final String? physicalHealthImpact;

  /// Reference ranges or values (mostly for LOINC)
  final Map<String, dynamic>? referenceValues;

  /// Hierarchical relationships
  final String? parentCode;
  final List<String> childCodes;

  const MedicalCode({
    required this.code,
    required this.displayName,
    required this.category,
    required this.standard,
    this.searchTerms = const [],
    this.definition,
    this.mentalHealthImpact,
    this.physicalHealthImpact,
    this.referenceValues,
    this.parentCode,
    this.childCodes = const [],
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
      definition: json['definition'] as String?,
      mentalHealthImpact: json['mentalHealthImpact'] as String?,
      physicalHealthImpact: json['physicalHealthImpact'] as String?,
      referenceValues: json['referenceValues'] as Map<String, dynamic>?,
      parentCode: json['parentCode'] as String?,
      childCodes: (json['childCodes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// All searchable text strings for embedding.
  List<String> get allSearchableTerms =>
      [displayName, ...searchTerms, if (definition != null) definition!];

  /// Single text block for vector embedding.
  String get embeddingText {
    final terms = searchTerms.isNotEmpty ? searchTerms.join(', ') : '';
    final def = definition != null ? '\nDefinition: $definition' : '';
    final mental = mentalHealthImpact != null ? '\nMental Health: $mentalHealthImpact' : '';
    final physical = physicalHealthImpact != null ? '\nPhysical Health: $physicalHealthImpact' : '';
    
    return '$displayName [$standard] - $category\n$terms$def$mental$physical'.trim();
  }

  @override
  List<Object?> get props => [code, standard];

  @override
  String toString() => 'MedicalCode($standard: $code - $displayName)';
}
