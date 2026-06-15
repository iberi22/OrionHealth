import 'package:health/health.dart';

class HealthDataPointDto {
  final HealthDataType type;
  final num value;
  final DateTime dateFrom;
  final DateTime dateTo;
  final HealthDataUnit? unit;
  final String? source;

  const HealthDataPointDto({
    required this.type, required this.value, required this.dateFrom,
    required this.dateTo, this.unit, this.source,
  });

  Map<String, dynamic> toJson() => {
    'type': type.toString(), 'value': value,
    'dateFrom': dateFrom.toIso8601String(), 'dateTo': dateTo.toIso8601String(),
    if (unit != null) 'unit': unit.toString(), if (source != null) 'source': source,
  };
}
