import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';

@LazySingleton(as: ReportRepository)
class IsarReportRepository implements ReportRepository {
  final Isar _isar;

  IsarReportRepository(this._isar);

  @override
  Future<void> saveReport(Report report) async {
    await _isar.writeTxn(() async {
      await _isar.reports.put(report);
    });
  }

  @override
  Future<List<Report>> getReports() async {
    return await _isar.reports.where().sortByGeneratedAtDesc().findAll();
  }

  @override
  Future<void> deleteReport(int id) async {
    await _isar.writeTxn(() async {
      await _isar.reports.delete(id);
    });
  }

  @override
  Future<Report?> getReportById(int id) async {
    return await _isar.reports.get(id);
  }
}
