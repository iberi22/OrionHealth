import '../entities/report.dart';

abstract class ReportGenerationService {
  Future<Report> generateReport({
    required String prompt,
    required List<String> contextData, // e.g., medical record summaries
  });
}
