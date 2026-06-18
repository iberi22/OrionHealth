import 'package:isar/isar.dart';

part 'medication.g.dart';

@collection
class Medication {
  Id id = Isar.autoIncrement;

  late String name;

  String? dosage;

  String? frequency;

  late DateTime startDate;

  bool isActive = true;

  String? notes;

  Medication({
    this.id = Isar.autoIncrement,
    required this.name,
    this.dosage,
    this.frequency,
    required this.startDate,
    this.isActive = true,
    this.notes,
  });
}
