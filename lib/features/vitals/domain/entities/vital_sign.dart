import 'package:isar/isar.dart';

part 'vital_sign.g.dart';

enum VitalSignType {
  heartRate,
  temperature,
  bloodPressureSystolic,
  bloodPressureDiastolic,
  spO2,
  steps,
  sleep,
  bloodGlucose,
  oxygenSaturation,
}

@collection
class VitalSign {
  Id id = Isar.autoIncrement;

  @Enumerated(EnumType.name)
  late VitalSignType type;

  @ignore
  late double value;

  String? encryptedValue;

  late DateTime dateTime;

  String? unit;
  String? source;

  @ignore
  String? notes;

  String? encryptedNotes;

  VitalSign({
    required this.type,
    required this.dateTime,
    this.value = 0.0,
    this.unit,
    this.source,
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
      case VitalSignType.oxygenSaturation:
        return '${value.toInt()}%';
      case VitalSignType.steps:
        return '${value.toInt()} steps';
      case VitalSignType.sleep:
        return '${value.toInt()} min';
      case VitalSignType.bloodGlucose:
        return '${value.toInt()} mg/dL';
    }
  }
}
