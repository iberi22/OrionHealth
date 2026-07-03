import 'package:equatable/equatable.dart';
import 'health_data_source.dart';

class HealthImportResult extends Equatable {
  final HealthDataSource source;
  final int importedCount;

  const HealthImportResult({
    required this.source,
    required this.importedCount,
  });

  @override
  List<Object?> get props => [source, importedCount];
}
