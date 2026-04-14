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

  late String name;

  String? allergenType;

  @Enumerated(EnumType.name)
  late AllergySeverity severity;

  String? notes;

  DateTime? createdAt;

  Allergy({
    required this.name,
    this.allergenType,
    required this.severity,
    this.notes,
    this.createdAt,
  });
}
