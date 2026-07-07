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

  @ignore
  String? allergen;

  /// Encrypted version of allergen for persistence
  String? encryptedAllergen;

  @Enumerated(EnumType.name)
  late AllergySeverity severity;

  @ignore
  String? notes;

  /// Encrypted version of notes for persistence
  String? encryptedNotes;

  Allergy({
    this.id = Isar.autoIncrement,
    this.severity = AllergySeverity.mild,
  });

  bool get isValid => allergen != null && allergen!.trim().isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Allergy &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          allergen == other.allergen &&
          encryptedAllergen == other.encryptedAllergen &&
          severity == other.severity &&
          notes == other.notes &&
          encryptedNotes == other.encryptedNotes;

  @override
  int get hashCode =>
      id.hashCode ^
      allergen.hashCode ^
      encryptedAllergen.hashCode ^
      severity.hashCode ^
      notes.hashCode ^
      encryptedNotes.hashCode;

  Allergy copyWith({
    Id? id,
    String? allergen,
    String? encryptedAllergen,
    AllergySeverity? severity,
    String? notes,
    String? encryptedNotes,
  }) {
    return Allergy(
      id: id ?? this.id,
      allergen: allergen ?? this.allergen,
      severity: severity ?? this.severity,
      notes: notes ?? this.notes,
    )
      ..encryptedAllergen = encryptedAllergen ?? this.encryptedAllergen
      ..encryptedNotes = encryptedNotes ?? this.encryptedNotes;
  }
}
