import 'package:medical_standards/medical_standards.dart' hide VitalSign;
import '../../../vitals/domain/entities/vital_sign.dart';
import '../../../medical_assistant/domain/entities/medical_insight.dart';

/// Repository interface for Home dashboard data orchestration.
abstract class HomeRepository {
  /// Whether the medical standards indexing has completed.
  bool get hasIndexed;

  /// Stream of indexing status updates.
  Stream<bool> get indexingStatusStream;

  /// Retries the indexing process.
  Future<bool> retryIndexing();

  /// Retrieves the latest recorded vital signs.
  Future<Map<VitalSignType, VitalSign?>> getLatestVitals();

  /// Retrieves recent medical insights based on vitals and conditions.
  Future<List<MedicalInsight>> getRecentInsights();
}
