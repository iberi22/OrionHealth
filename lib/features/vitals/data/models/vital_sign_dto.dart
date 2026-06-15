import '../../domain/entities/vital_sign.dart';

class VitalSignDto {
  final int? id;
  final VitalSignType type;
  final double value;
  final String? unit;
  final DateTime dateTime;
  final String? notes;

  const VitalSignDto({
    this.id, required this.type, required this.value, this.unit,
    required this.dateTime, this.notes,
  });

  factory VitalSignDto.fromEntity(VitalSign e) => VitalSignDto(
    id: e.id, type: e.type, value: e.value, unit: e.unit,
    dateTime: e.dateTime, notes: e.notes,
  );

  VitalSign toEntity() => VitalSign(
    id: id, type: type, value: value, unit: unit,
    dateTime: dateTime, notes: notes,
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id, 'type': type.name, 'value': value,
    if (unit != null) 'unit': unit, 'dateTime': dateTime.toIso8601String(),
    if (notes != null) 'notes': notes,
  };

  factory VitalSignDto.fromJson(Map<String, dynamic> j) => VitalSignDto(
    id: j['id'] as int?,
    type: VitalSignType.values.firstWhere((t) => t.name == j['type']),
    value: (j['value'] as num).toDouble(),
    unit: j['unit'] as String?,
    dateTime: DateTime.parse(j['dateTime'] as String),
    notes: j['notes'] as String?,
  );
}
