import 'package:isar/isar.dart';

part 'medication.g.dart';

@collection
class Medication {
  Id id = Isar.autoIncrement;

  @ignore
  late String name;

  String? encryptedName;

  @ignore
  String? dosage;

  String? encryptedDosage;

  @ignore
  String? frequency;

  String? encryptedFrequency;

  late DateTime startDate;

  bool isActive = true;

  @ignore
  String? notes;

  String? encryptedNotes;

  String? rxNormCode;

  String? drugClass;

  @ignore
  String? genericName;

  String? encryptedGenericName;

  Medication({
    this.id = Isar.autoIncrement,
    this.name = '',
    required this.startDate,
    this.isActive = true,
    this.rxNormCode,
    this.drugClass,
    this.genericName,
    this.notes,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Medication &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          encryptedName == other.encryptedName &&
          dosage == other.dosage &&
          encryptedDosage == other.encryptedDosage &&
          frequency == other.frequency &&
          encryptedFrequency == other.encryptedFrequency &&
          startDate == other.startDate &&
          isActive == other.isActive &&
          notes == other.notes &&
          encryptedNotes == other.encryptedNotes &&
          rxNormCode == other.rxNormCode &&
          drugClass == other.drugClass &&
          genericName == other.genericName &&
          encryptedGenericName == other.encryptedGenericName;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        encryptedName,
        dosage,
        encryptedDosage,
        frequency,
        encryptedFrequency,
        startDate,
        isActive,
        notes,
        encryptedNotes,
        rxNormCode,
        drugClass,
        genericName,
        encryptedGenericName,
      );
}
