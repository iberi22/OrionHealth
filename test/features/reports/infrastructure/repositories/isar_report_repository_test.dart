import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/reports/domain/entities/report.dart';
import 'package:orionhealth_health/features/reports/infrastructure/repositories/isar_report_repository.dart';

class MockIsar extends Mock implements Isar {
  @override
  Future<T> writeTxn<T>(Future<T> Function() callback, {bool silent = false}) {
    return callback();
  }
}
abstract class IsarCollectionReport extends IsarCollection<Report> {}
class MockIsarCollection extends Mock implements IsarCollectionReport {}
class FakeReport extends Fake implements Report {}

void main() {
  late MockIsar mockIsar;
  late MockIsarCollection mockCollection;
  late IsarReportRepository repository;

  setUpAll(() {
    registerFallbackValue(FakeReport());
  });

  setUp(() {
    mockIsar = MockIsar();
    mockCollection = MockIsarCollection();
    repository = IsarReportRepository(mockIsar);

    when(() => mockIsar.reports).thenReturn(mockCollection);
  });

  group('IsarReportRepository', () {
    test('saveReport puts report in collection within transaction', () async {
      final report = Report(title: 'Test');
      when(() => mockCollection.put(any())).thenAnswer((_) async => 1);

      await repository.saveReport(report);

      verify(() => mockCollection.put(report)).called(1);
    });

    test('deleteReport deletes from collection within transaction', () async {
      when(() => mockCollection.delete(any())).thenAnswer((_) async => true);

      await repository.deleteReport(1);

      verify(() => mockCollection.delete(1)).called(1);
    });

    test('getReportById gets from collection', () async {
      final report = Report(title: 'Test');
      when(() => mockCollection.get(any())).thenAnswer((_) async => report);

      final result = await repository.getReportById(1);

      expect(result, report);
      verify(() => mockCollection.get(1)).called(1);
    });
  });
}
