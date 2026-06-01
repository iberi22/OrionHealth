import 'package:json_annotation/json_annotation.dart';
import 'package:isar/isar.dart';

part 'lab_result.g.dart';

/// Source of the health data entry.
enum DataSource {
  @JsonValue('manual')
  manual,
  @JsonValue('external')
  external,
  @JsonValue('device')
  device,
}

/// Sync status for local-remote coordination.
enum SyncStatus {
  @JsonValue('synced')
  synced,
  @JsonValue('pending')
  pending,
  @JsonValue('conflict')
  conflict,
}

/// Lab result with LOINC code reference.
/// Sensitive: result value may be encrypted.
@collection
@JsonSerializable()
class LabResult  {
  LabResult({
    this.id = Isar.autoIncrement,
    required this.remoteId,
    required this.loincCode,
    required this.testName,
    required this.resultValue,
    required this.unit,
    required this.referenceRangeLow,
    required this.referenceRangeHigh,
    required this.collectedAt,
    required this.createdAt,
    required this.updatedAt,
    this.source = DataSource.manual,
    this.syncStatus = SyncStatus.pending,
    this.encryptedValue,
  });

  @Index(unique: true)
  Id id;
  final String remoteId;

  /// LOINC code for the lab test (e.g. "2339-0" for Glucose).
  @Index()
  final String loincCode;

  final String testName;

  /// Raw result value — stored encrypted if sensitive.
  /// Use encryptedValue for the encrypted form.
  final String resultValue;

  final String unit;
  final double referenceRangeLow;
  final double referenceRangeHigh;

  @Index()
  final DateTime collectedAt;

  final DateTime createdAt;
  final DateTime updatedAt;

  @Enumerated(EnumType.name)
  final DataSource source;

  @Enumerated(EnumType.name)
  @Index()
  final SyncStatus syncStatus;

  /// AES-256-GCM encrypted result value (base64).
  /// Populated by EncryptionService when resultValue contains sensitive data.
  final String? encryptedValue;

  /// Whether this lab result contains sensitive data requiring encryption.
  bool get isSensitive => loincCode.isNotEmpty; // extend with sensitive code list

  /// Returns true if result is outside reference range.
  bool get isAbnormal {
    final value = double.tryParse(resultValue);
    if (value == null) return false;
    return value < referenceRangeLow || value > referenceRangeHigh;
  }

  LabResult copyWith({
    Id? id,
    String? remoteId,
    String? loincCode,
    String? testName,
    String? resultValue,
    String? unit,
    double? referenceRangeLow,
    double? referenceRangeHigh,
    DateTime? collectedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DataSource? source,
    SyncStatus? syncStatus,
    String? encryptedValue,
  }) {
    return LabResult(
      remoteId: remoteId ?? this.remoteId,
      id: id ?? this.id,
      loincCode: loincCode ?? this.loincCode,
      testName: testName ?? this.testName,
      resultValue: resultValue ?? this.resultValue,
      unit: unit ?? this.unit,
      referenceRangeLow: referenceRangeLow ?? this.referenceRangeLow,
      referenceRangeHigh: referenceRangeHigh ?? this.referenceRangeHigh,
      collectedAt: collectedAt ?? this.collectedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      source: source ?? this.source,
      syncStatus: syncStatus ?? this.syncStatus,
      encryptedValue: encryptedValue ?? this.encryptedValue,
    );
  }

  factory LabResult.fromJson(Map<String, dynamic> json) => _$LabResultFromJson(json);
  Map<String, dynamic> toJson() => _$LabResultToJson(this);

}
