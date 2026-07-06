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

  String? rxNormCode;

  String? drugClass;

  String? genericName;

  Medication({
    this.id = Isar.autoIncrement,
    required this.name,
    this.dosage,
    this.frequency,
    required this.startDate,
    this.isActive = true,
    this.notes,
    this.rxNormCode,
    this.drugClass,
    this.genericName,
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
          notes == other.notes &&
          rxNormCode == other.rxNormCode &&
          drugClass == other.drugClass &&
          genericName == other.genericName;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        dosage,
        frequency,
        startDate,
        isActive,
        notes,
        rxNormCode,
        drugClass,
        genericName,
      );
}
