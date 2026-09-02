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
    required this.startDate,
    this.isActive = true,
    this.name = 'Unknown',
    this.dosage,
    this.frequency,
    this.notes,
    this.genericName,
    this.rxNormCode,
    this.drugClass,
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'encryptedName': encryptedName,
        'dosage': dosage,
        'encryptedDosage': encryptedDosage,
        'frequency': frequency,
        'encryptedFrequency': encryptedFrequency,
        'startDate': startDate.toIso8601String(),
        'isActive': isActive,
        'notes': notes,
        'encryptedNotes': encryptedNotes,
        'rxNormCode': rxNormCode,
        'drugClass': drugClass,
        'genericName': genericName,
        'encryptedGenericName': encryptedGenericName,
      };

}
