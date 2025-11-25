import '../entities/health_report.dart';

abstract class ReportGenerationService {
  Future<HealthReport> generateReport({
    required String prompt,
    required List<String> contextData, // e.g., medical record summaries
  });
}
