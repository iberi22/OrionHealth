import 'package:isar/isar.dart';

part 'vital_sign.g.dart';

enum VitalType {
  heartRate,
  bodyTemperature,
  bloodPressure,
  bloodOxygen,
  weight,
  height,
}

@collection
class VitalSign {
  Id id = Isar.autoIncrement;

  @Enumerated(EnumType.name)
  late VitalType type;

  late double value;

  // Optional secondary value (e.g., diastolic for BP)
  double? valueSecondary;

  late DateTime timestamp;

  String? unit;

  VitalSign({
    required this.type,
    required this.value,
    this.valueSecondary,
    required this.timestamp,
    this.unit,
  });
}
