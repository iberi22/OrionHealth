import 'package:json_annotation/json_annotation.dart';
import 'package:isar/isar.dart';
import 'lab_result.dart';

part 'vital_sign.g.dart';

/// Vital sign reading with timestamp.
/// Sensitive: vital values are encrypted at rest.
@collection
@JsonSerializable()
class VitalSign {
  VitalSign({
    required this.id,
    required this.loincCode,
    required this.componentName,
    required this.value,
    required this.unit,
    required this.recordedAt,
    required this.createdAt,
    required this.updatedAt,
    this.source = DataSource.manual,
    this.syncStatus = SyncStatus.pending,
    this.encryptedValue,
    this.notes,
  });

  @Index(unique: true)
  final String id;

  Id get isarId => fastHash(id);

  /// LOINC code for this vital sign (e.g. "8867-4" for Heart rate).
  @Index()
  final String loincCode;

  final String componentName;
  final String value; // store as string; parse based on vital type
  final String unit;

  @Index()
  final DateTime recordedAt;

  final DateTime createdAt;
  final DateTime updatedAt;

  @Enumerated(EnumType.name)
  final DataSource source;

  @Enumerated(EnumType.name)
  @Index()
  SyncStatus syncStatus;

  /// AES-256-GCM encrypted vital value (base64).
  String? encryptedValue;

  String? notes;

  /// Common vital LOINC codes for reference:
  /// - 8867-4: Heart rate
  /// - 8310-5: Body temperature
  /// - 8480-6: Systolic BP
  /// - 8462-4: Diastolic BP
  /// - 2708-6: SpO2
  /// - 29463-7: Body weight
  /// - 2710-2: Body height
  /// - 39156-5: BMI
  @ignore
  static const commonLoincCodes = {
    '8867-4': 'Heart rate',
    '8310-5': 'Body temperature',
    '8480-6': 'Systolic BP',
    '8462-4': 'Diastolic BP',
    '2708-6': 'SpO2',
    '29463-7': 'Body weight',
    '2710-2': 'Body height',
    '39156-5': 'BMI',
  };

  /// Check if this vital sign is in normal range (simplified).
  @ignore
  bool get isAbnormal {
    final v = double.tryParse(value);
    if (v == null) return false;
    switch (loincCode) {
      case '8867-4': return v < 60 || v > 100; // heart rate
      case '8310-5': return v < 36.1 || v > 37.2; // temp °C
      case '8480-6': return v > 140; // systolic BP
      case '8462-4': return v > 90; // diastolic BP
      case '2708-6': return v < 95; // SpO2
      default: return false;
    }
  }

  VitalSign copyWith({
    String? id,
    String? loincCode,
    String? componentName,
    String? value,
    String? unit,
    DateTime? recordedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DataSource? source,
    SyncStatus? syncStatus,
    String? encryptedValue,
    String? notes,
  }) {
    return VitalSign(
      id: id ?? this.id,
      loincCode: loincCode ?? this.loincCode,
      componentName: componentName ?? this.componentName,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      recordedAt: recordedAt ?? this.recordedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      source: source ?? this.source,
      syncStatus: syncStatus ?? this.syncStatus,
      encryptedValue: encryptedValue ?? this.encryptedValue,
      notes: notes ?? this.notes,
    );
  }

  factory VitalSign.fromJson(Map<String, dynamic> json) => _$VitalSignFromJson(json);
  Map<String, dynamic> toJson() => _$VitalSignToJson(this);
}
