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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Medication &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          dosage == other.dosage &&
          frequency == other.frequency &&
          startDate == other.startDate &&
          isActive == other.isActive &&
          notes == other.notes;

  @override
  int get hashCode =>
      Object.hash(id, name, dosage, frequency, startDate, isActive, notes);
}
