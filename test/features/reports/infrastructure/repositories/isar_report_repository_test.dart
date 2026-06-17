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
    testDir = p.join(Directory.systemTemp.path, 'test_db_reports_${DateTime.now().millisecondsSinceEpoch}');
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
    test('getReports returns an empty list initially', () async {
      final results = await repository.getReports();
      expect(results, isEmpty);
    });

    test('saveReport and getReports', () async {
      final report = Report(
        title: 'Monthly Health Summary',
        content: 'All good',
        generatedAt: DateTime(2023, 6, 1),
        status: ReportStatus.finalized,
      );

      await repository.saveReport(report);

      final results = await repository.getReports();
      expect(results.length, 1);
      expect(results.first.title, 'Monthly Health Summary');
      expect(results.first.status, ReportStatus.finalized);
    });

    test('getReports returns reports sorted by generatedAt descending', () async {
      final oldReport = Report(
        title: 'Old Report',
        generatedAt: DateTime(2023, 1, 1),
      );
      final newReport = Report(
        title: 'New Report',
        generatedAt: DateTime(2023, 12, 1),
      );

      await repository.saveReport(oldReport);
      await repository.saveReport(newReport);

      final results = await repository.getReports();
      expect(results.length, 2);
      expect(results.first.title, 'New Report');
      expect(results.last.title, 'Old Report');
    });

    test('deleteReport removes the report', () async {
      final report = Report(
        title: 'To Delete',
        generatedAt: DateTime.now(),
      );

      await repository.saveReport(report);

      final savedReports = await repository.getReports();
      expect(savedReports.length, 1);
      final idToDelete = savedReports.first.id;

      await repository.deleteReport(idToDelete);

      final resultsAfterDelete = await repository.getReports();
      expect(resultsAfterDelete, isEmpty);
    });

    test('getReportById returns correct report', () async {
      final report = Report(
        title: 'Target Report',
        generatedAt: DateTime.now(),
      );

      await repository.saveReport(report);
      final savedReports = await repository.getReports();
      final id = savedReports.first.id;

      final result = await repository.getReportById(id);
      expect(result, isNotNull);
      expect(result!.title, 'Target Report');
    });

    test('getReportById returns null for non-existent ID', () async {
      final result = await repository.getReportById(999);
      expect(result, isNull);
    });
  });
}
