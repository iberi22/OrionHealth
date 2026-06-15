import 'package:health/health.dart';

/// Repository interface for health data import operations.
///
/// Abstracts away sensor (Apple Health / Google Fit) and file-based
/// (PDF, OCR) data sources behind a single unified interface.
abstract class HealthDataImportRepository {
  /// Check if the app already has permission to read the given [types].
  Future<bool> hasPermissions(List<HealthDataType> types);

  /// Request authorization to read the given [types].
  Future<bool> requestAuthorization(
    List<HealthDataType> types, {
    List<HealthDataAccess>? permissions,
  });

  /// Fetch health data points of [type] within the given time range.
  Future<List<HealthDataPoint>> fetchHealthData(
    HealthDataType type,
    DateTime startTime,
    DateTime endTime,
  );

  /// Pick a file (PDF/image) and extract its text content.
  Future<String?> pickAndExtractFromFile();
}
