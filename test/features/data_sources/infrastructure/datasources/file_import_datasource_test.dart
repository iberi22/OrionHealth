import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/data_sources/infrastructure/datasources/file_import_datasource.dart';

void main() {
  late FileImportDataSource dataSource;

  setUp(() {
    dataSource = FileImportDataSource();
  });

  group('FileImportDataSource', () {
    test('supports CSV files', () {
      final supported = dataSource.supportedFormats;
      expect(supported, contains('csv'));
    });

    test('supports JSON files', () {
      final supported = dataSource.supportedFormats;
      expect(supported, contains('json'));
    });

    test('supports XML files', () {
      final supported = dataSource.supportedFormats;
      expect(supported, contains('xml'));
    });

    test('returns null for empty input', () async {
      final result = await dataSource.importFromFile(null);
      expect(result, isNull);
    });
  });
}
