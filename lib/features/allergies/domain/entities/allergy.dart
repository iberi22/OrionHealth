import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

part 'allergy.g.dart';

enum AllergySeverity {
  mild,
  moderate,
  severe,
}

@collection
class Allergy {
  Id id = Isar.autoIncrement;

  String? allergen;

  @Enumerated(EnumType.name)
  late AllergySeverity severity;

  String? notes;

  Allergy({
    this.id = Isar.autoIncrement,
    this.allergen,
    this.severity = AllergySeverity.mild,
    this.notes,
  });

  bool get isValid => allergen != null && allergen!.trim().isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Allergy &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          allergen == other.allergen &&
          severity == other.severity &&
          notes == other.notes;

  @override
  int get hashCode =>
      id.hashCode ^ allergen.hashCode ^ severity.hashCode ^ notes.hashCode;

  Allergy copyWith({
    Id? id,
    String? allergen,
    AllergySeverity? severity,
    String? notes,
  }) {
    return Allergy(
      id: id ?? this.id,
      allergen: allergen ?? this.allergen,
      severity: severity ?? this.severity,
      notes: notes ?? this.notes,
    );
  }
}
