import 'package:isar/isar.dart';

part 'medication.g.dart';

@collection
class Medication {
  Id id = Isar.autoIncrement;

  late String name;

  late String dosage;

  late String frequency;

  late DateTime startDate;

  DateTime? endDate;

  bool isActive = true;

  String? notes;

  Medication({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.notes,
  });
}
