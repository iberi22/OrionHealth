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

  /// Guideline specific fields
  final String? firstLineTreatment;
  final String? alternatives;
  final String? redFlags;
  final String? followUp;

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
    this.firstLineTreatment,
    this.alternatives,
    this.redFlags,
    this.followUp,
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
      firstLineTreatment: json['firstLineTreatment'] as String?,
      alternatives: json['alternatives'] as String?,
      redFlags: json['redFlags'] as String?,
      followUp: json['followUp'] as String?,
    );
  }

  /// All searchable text strings for embedding.
  List<String> get allSearchableTerms {
    final list = [
      displayName,
      ...searchTerms,
    ];
    if (definition != null) list.add(definition!);
    if (firstLineTreatment != null) list.add(firstLineTreatment!);
    if (alternatives != null) list.add(alternatives!);
    if (redFlags != null) list.add(redFlags!);
    if (followUp != null) list.add(followUp!);
    return list;
  }

  /// Single text block for vector embedding.
  String get embeddingText {
    final terms = searchTerms.isNotEmpty ? searchTerms.join(', ') : '';
    final def = definition != null ? '\nDefinition: $definition' : '';
    final mental = mentalHealthImpact != null ? '\nMental Health: $mentalHealthImpact' : '';
    final physical = physicalHealthImpact != null ? '\nPhysical Health: $physicalHealthImpact' : '';
    final firstLine = firstLineTreatment != null ? '\nFirst-line Treatment: $firstLineTreatment' : '';
    final alt = alternatives != null ? '\nAlternatives: $alternatives' : '';
    final flags = redFlags != null ? '\nRed Flags: $redFlags' : '';
    final fup = followUp != null ? '\nFollow-up: $followUp' : '';

    return '$displayName [$standard] - $category\n$terms$def$mental$physical$firstLine$alt$flags$fup'
        .trim();
  }

  @override
  List<Object?> get props => [
        code,
        standard,
        displayName,
        category,
        searchTerms,
        definition,
        mentalHealthImpact,
        physicalHealthImpact,
        referenceValues,
        parentCode,
        childCodes,
        firstLineTreatment,
        alternatives,
        redFlags,
        followUp,
      ];

  @override
  String toString() => 'MedicalCode($standard: $code - $displayName)';
}
