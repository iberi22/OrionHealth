import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/report.dart';

@lazySingleton
class ReportLocalDataSource {
  final Isar _isar;
  ReportLocalDataSource(this._isar);

  Future<List<Report>> getAllReports() =>
      _isar.reports.where().sortByGeneratedAtDesc().findAll();

  Future<void> saveReport(Report r) =>
      _isar.writeTxn(() async => _isar.reports.put(r));

  Future<void> deleteReport(int id) =>
      _isar.writeTxn(() async => _isar.reports.delete(id));

  Future<Report?> getReportById(int id) =>
      _isar.reports.get(id);
}
