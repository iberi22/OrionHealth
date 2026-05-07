import '../entities/report.dart';

abstract class ReportRepository {
  Future<void> saveReport(Report report);
  Future<List<Report>> getReports();
  Future<void> deleteReport(int id);
  Future<Report?> getReportById(int id);
}
