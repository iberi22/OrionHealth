import 'package:isar/isar.dart';

part 'medication.g.dart';

@collection
class Medication {
  Id id = Isar.autoIncrement;

  @ignore
  String get name => encryptedName ?? 'Unknown';
  set name(String val) => encryptedName = val;

  String? encryptedName;

  @ignore
  String? get dosage => encryptedDosage;
  set dosage(String? val) => encryptedDosage = val;

  String? encryptedDosage;

  @ignore
  String? get frequency => encryptedFrequency;
  set frequency(String? val) => encryptedFrequency = val;

  String? encryptedFrequency;

  late DateTime startDate;

  bool isActive = true;

  @ignore
  String? get notes => encryptedNotes;
  set notes(String? val) => encryptedNotes = val;

  String? encryptedNotes;

  String? rxNormCode;

  String? drugClass;

  @ignore
  String? get genericName => encryptedGenericName;
  set genericName(String? val) => encryptedGenericName = val;

  String? encryptedGenericName;

  Medication({
    this.id = Isar.autoIncrement,
    required this.startDate,
    this.isActive = true,
    String name = 'Unknown',
    String? dosage,
    String? frequency,
    String? notes,
    String? genericName,
    this.rxNormCode,
    this.drugClass,
  }) {
    this.name = name;
    this.dosage = dosage;
    this.frequency = frequency;
    this.notes = notes;
    this.genericName = genericName;
  }

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
