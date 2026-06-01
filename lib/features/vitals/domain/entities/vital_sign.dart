import 'package:isar/isar.dart';

part 'vital_sign.g.dart';

enum VitalSignType {
  heartRate,
  temperature,
  bloodPressureSystolic,
  bloodPressureDiastolic,
  spO2,
}

@collection
class VitalSign {
  Id id = Isar.autoIncrement;

  @Enumerated(EnumType.name)
  late VitalSignType type;

  late double value;

  late DateTime dateTime;

  String? notes;

  VitalSign({
    required this.type,
    required this.value,
    required this.dateTime,
    this.notes,
  });
}
