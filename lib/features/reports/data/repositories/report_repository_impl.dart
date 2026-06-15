import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_local_datasource.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportLocalDataSource _localDataSource;
  ReportRepositoryImpl(this._localDataSource);

  @override
  Future<void> saveReport(Report report) => _localDataSource.saveReport(report);
  @override
  Future<List<Report>> getReports() => _localDataSource.getAllReports();
  @override
  Future<void> deleteReport(int id) => _localDataSource.deleteReport(id);
  @override
  Future<Report?> getReportById(int id) => _localDataSource.getReportById(id);
}
