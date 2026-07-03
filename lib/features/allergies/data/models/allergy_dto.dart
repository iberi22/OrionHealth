import '../../domain/entities/allergy.dart';

class AllergyDto {
  final int? id;
  final String? allergen;
  final String severity;
  final String? notes;

  const AllergyDto({
    this.id,
    this.allergen,
    required this.severity,
    this.notes,
  });

  factory AllergyDto.fromEntity(Allergy entity) {
    return AllergyDto(
      id: entity.id,
      allergen: entity.allergen,
      severity: entity.severity.name,
      notes: entity.notes,
    );
  }

  Allergy toEntity() {
    return Allergy(
      id: id ?? 0,
      allergen: allergen,
      severity: AllergySeverity.values.firstWhere(
        (e) => e.name == severity,
        orElse: () => AllergySeverity.mild,
      ),
      notes: notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'allergen': allergen,
      'severity': severity,
      'notes': notes,
    };
  }

  factory AllergyDto.fromJson(Map<String, dynamic> json) {
    return AllergyDto(
      id: json['id'] as int?,
      allergen: json['allergen'] as String?,
      severity: json['severity'] as String? ?? 'mild',
      notes: json['notes'] as String?,
    );
  }
}
