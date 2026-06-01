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

  /// Formatted value string for display purposes.
  String get formattedValue {
    switch (type) {
      case VitalSignType.heartRate:
        return '${value.toInt()} bpm';
      case VitalSignType.temperature:
        return '${value.toStringAsFixed(1)}°C';
      case VitalSignType.bloodPressureSystolic:
      case VitalSignType.bloodPressureDiastolic:
        return '${value.toInt()} mmHg';
      case VitalSignType.spO2:
        return '${value.toInt()}%';
    }
  }
}
