import 'package:health/health.dart';
import 'health_data_source.dart';

class HealthImportConfig {
  final HealthDataSource source;
  final List<HealthDataType> types;
  final DateTime startTime;
  final DateTime endTime;

  const HealthImportConfig({
    required this.source,
    required this.types,
    required this.startTime,
    required this.endTime,
  });
}
