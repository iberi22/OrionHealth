import 'package:isar/isar.dart';

part 'vital_sign.g.dart';

enum VitalSignType {
  heartRate,
  bloodPressureSystolic,
  bloodPressureDiastolic,
  temperature,
  oxygenSaturation,
  respiratoryRate,
  bloodGlucose,
}

@collection
class VitalSign {
  Id id = Isar.autoIncrement;

  @enumerated
  VitalSignType type = VitalSignType.heartRate;

  double? value;

  String? unit;

  DateTime? recordedAt;

  String? source; // "manual", "health_connect", "apple_health", etc.

  String? notes;

  VitalSign({
    this.type = VitalSignType.heartRate,
    this.value,
    this.unit,
    this.recordedAt,
    this.source,
    this.notes,
  });

  VitalSign copyWith({
    VitalSignType? type,
    double? value,
    String? unit,
    DateTime? recordedAt,
    String? source,
    String? notes,
  }) {
    return VitalSign(
      type: type ?? this.type,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      recordedAt: recordedAt ?? this.recordedAt,
      source: source ?? this.source,
      notes: notes ?? this.notes,
    )..id = this.id;
  }

  /// Get display label for the vital sign type
  String get typeLabel {
    switch (type) {
      case VitalSignType.heartRate:
        return 'Pulso';
      case VitalSignType.bloodPressureSystolic:
        return 'Presión Sistólica';
      case VitalSignType.bloodPressureDiastolic:
        return 'Presión Diastólica';
      case VitalSignType.temperature:
        return 'Temperatura';
      case VitalSignType.oxygenSaturation:
        return 'Saturación O₂';
      case VitalSignType.respiratoryRate:
        return 'Frecuencia Respiratoria';
      case VitalSignType.bloodGlucose:
        return 'Glucosa';
    }
  }

  /// Get formatted value with unit
  String get formattedValue {
    if (value == null) return '--';
    final unitStr = unit ?? '';
    return '${value!.toStringAsFixed(value! == value!.roundToDouble() ? 0 : 1)} $unitStr'
        .trim();
  }

  @override
  String toString() {
    return 'VitalSign(id: $id, type: $type, value: $value, unit: $unit, recordedAt: $recordedAt)';
  }
}
