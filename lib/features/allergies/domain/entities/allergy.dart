import 'package:isar/isar.dart';

part 'allergy.g.dart';

enum AllergySeverity { mild, moderate, severe, lifeThreatening }

@collection
class Allergy {
  Id id = Isar.autoIncrement;

  String? name;

  @enumerated
  AllergySeverity severity = AllergySeverity.moderate;

  String? reaction; // Description of the allergic reaction

  DateTime? confirmedDate;

  String? notes;

  bool isCritical = false;

  Allergy({
    this.name,
    this.severity = AllergySeverity.moderate,
    this.reaction,
    this.confirmedDate,
    this.notes,
    this.isCritical = false,
  });

  Allergy copyWith({
    String? name,
    AllergySeverity? severity,
    String? reaction,
    DateTime? confirmedDate,
    String? notes,
    bool? isCritical,
  }) {
    return Allergy(
      name: name ?? this.name,
      severity: severity ?? this.severity,
      reaction: reaction ?? this.reaction,
      confirmedDate: confirmedDate ?? this.confirmedDate,
      notes: notes ?? this.notes,
      isCritical: isCritical ?? this.isCritical,
    )..id = this.id;
  }

  @override
  String toString() {
    return 'Allergy(id: $id, name: $name, severity: $severity, isCritical: $isCritical)';
  }
}
