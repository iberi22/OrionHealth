import '../entities/health_report.dart';

abstract class HealthReportRepository {
  Future<void> saveReport(HealthReport report);
  Future<List<HealthReport>> getReports();
  Future<void> deleteReport(int id);
  Future<HealthReport?> getReportById(int id);
}
