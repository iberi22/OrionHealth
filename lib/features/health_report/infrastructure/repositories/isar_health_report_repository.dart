import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/health_report.dart';
import '../../domain/repositories/health_report_repository.dart';

@LazySingleton(as: HealthReportRepository)
class IsarHealthReportRepository implements HealthReportRepository {
  final Isar _isar;

  IsarHealthReportRepository(this._isar);

  @override
  Future<void> saveReport(HealthReport report) async {
    await _isar.writeTxn(() async {
      await _isar.healthReports.put(report);
    });
  }

  @override
  Future<List<HealthReport>> getReports() async {
    return await _isar.healthReports.where().sortByGeneratedAtDesc().findAll();
  }

  @override
  Future<void> deleteReport(int id) async {
    await _isar.writeTxn(() async {
      await _isar.healthReports.delete(id);
    });
  }

  @override
  Future<HealthReport?> getReportById(int id) async {
    return await _isar.healthReports.get(id);
  }
}
