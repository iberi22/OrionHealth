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
}
