/// FEAT-022: Medical condition (chronic)
library;

class MedicalCondition {
  final String name; // "Type 2 Diabetes"
  final String? icd10Code; // "E11.9"
  final String? snomedCode; // "44054006"
  final ConditionSeverity severity;
  final String? notes;

  const MedicalCondition({
    required this.name,
    this.icd10Code,
    this.snomedCode,
    this.severity = ConditionSeverity.moderate,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'icd10_code': icd10Code,
        'snomed_code': snomedCode,
        'severity': severity.name,
        'notes': notes,
      };

  factory MedicalCondition.fromJson(Map<String, dynamic> json) =>
      MedicalCondition(
        name: json['name'] as String,
        icd10Code: json['icd10_code'] as String?,
        snomedCode: json['snomed_code'] as String?,
        severity: ConditionSeverity.values.firstWhere(
          (e) => e.name == json['severity'],
          orElse: () => ConditionSeverity.moderate,
        ),
        notes: json['notes'] as String?,
      );
}

enum ConditionSeverity {
  mild('Leve'),
  moderate('Moderada'),
  severe('Severa'),
  critical('Crítica');

  final String displayName;
  const ConditionSeverity(this.displayName);
}
