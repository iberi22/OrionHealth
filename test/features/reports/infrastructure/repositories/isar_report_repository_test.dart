import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:orionhealth_health/features/reports/domain/entities/report.dart';
import 'package:orionhealth_health/features/reports/infrastructure/repositories/isar_report_repository.dart';
import 'package:path/path.dart' as p;

void main() {
  late Isar isar;
  late IsarReportRepository repository;
  late String testDir;

  setUpAll(() async {
    testDir = p.join(Directory.current.path, 'test_db_reports');
    await Directory(testDir).create(recursive: true);

    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open(
      [ReportSchema],
      directory: testDir,
    );
    repository = IsarReportRepository(isar);
  });

  tearDownAll(() async {
    await isar.close();
    if (await Directory(testDir).exists()) {
      await Directory(testDir).delete(recursive: true);
    }
  });

  setUp(() async {
    await isar.writeTxn(() => isar.reports.clear());
  });

  group('IsarReportRepository', () {
    test('saveReport and getReportById', () async {
      final report = Report(
        title: 'Test Report',
        content: 'Content',
        generatedAt: DateTime.now(),
      );

      await repository.saveReport(report);

      expect(report.id, isNot(Isar.autoIncrement));

      final retrieved = await repository.getReportById(report.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.title, 'Test Report');
    });

    test('deleteReport removes the report', () async {
      final report = Report(title: 'To Delete');
      await repository.saveReport(report);

      await repository.deleteReport(report.id);

      final retrieved = await repository.getReportById(report.id);
      expect(retrieved, isNull);
    });

    test('getReports returns all reports sorted by generatedAt desc', () async {
      final now = DateTime.now();
      final r1 = Report(title: 'Old', generatedAt: now.subtract(const Duration(days: 1)));
      final r2 = Report(title: 'New', generatedAt: now);

      await repository.saveReport(r1);
      await repository.saveReport(r2);

      final results = await repository.getReports();

      expect(results.length, 2);
      expect(results.first.title, 'New');
      expect(results.last.title, 'Old');
    });
  });
}
