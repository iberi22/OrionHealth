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
  activeEnergy,
}

// Renamed: the health_wallet package already registers a collection named
// "VitalSign", and Isar rejects duplicate collection names.
@Name('VitalSignReading')
@collection
class VitalSign {
  Id id = Isar.autoIncrement;

  @Enumerated(EnumType.name)
  late VitalSignType type;

  @ignore
  double get value =>
      encryptedValue != null ? double.parse(encryptedValue!) : 0.0;
  set value(double val) => encryptedValue = val.toString();

  String? encryptedValue;

  late DateTime dateTime;

  String? unit;
  String? source;

  @ignore
  String? get notes => encryptedNotes;
  set notes(String? val) => encryptedNotes = val;

  String? encryptedNotes;

  VitalSign({
    required this.type,
    required this.dateTime,
    double value = 0.0,
    this.unit,
    this.source,
    String? notes,
  }) {
    this.value = value;
    this.notes = notes;
  }

  /// Formatted value string for display purposes.
  String get formattedValue {
    switch (type) {
      case VitalSignType.activeEnergy:
        return '${value.toStringAsFixed(1)} kcal';
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'value': value,
    'encryptedValue': encryptedValue,
    'dateTime': dateTime.toIso8601String(),
    'unit': unit,
    'source': source,
    'notes': notes,
    'encryptedNotes': encryptedNotes,
  };
}
