import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/data_sources/infrastructure/datasources/file_import_datasource.dart';
import 'package:orionhealth_health/features/health_record/infrastructure/services/file_picker_service.dart';
import 'package:orionhealth_health/features/health_record/infrastructure/services/ocr_service.dart';

class MockFilePickerService extends Mock implements FilePickerService {}
class MockOcrService extends Mock implements OcrService {}

void main() {
  late FileImportDataSourceImpl dataSource;
  late MockFilePickerService mockFilePicker;
  late MockOcrService mockOcr;

  setUp(() {
    mockFilePicker = MockFilePickerService();
    mockOcr = MockOcrService();
    dataSource = FileImportDataSourceImpl(mockFilePicker, mockOcr);
  });

  group('FileImportDataSourceImpl', () {
    test('pickAndProcessFile returns extracted text on success', () async {
      const testPath = 'path/to/file.pdf';
      const extractedText = 'Extracted health data';

      when(() => mockFilePicker.pickPdf()).thenAnswer((_) async => testPath);
      when(() => mockOcr.extractText(testPath)).thenAnswer((_) async => extractedText);

      final result = await dataSource.pickAndProcessFile();

      expect(result, extractedText);
      verify(() => mockFilePicker.pickPdf()).called(1);
      verify(() => mockOcr.extractText(testPath)).called(1);
    });

    test('pickAndProcessFile returns null if no file is picked', () async {
      when(() => mockFilePicker.pickPdf()).thenAnswer((_) async => null);

      final result = await dataSource.pickAndProcessFile();

      expect(result, isNull);
      verify(() => mockFilePicker.pickPdf()).called(1);
      verifyZeroInteractions(mockOcr);
    });

    test('pickAndProcessFile propagates exceptions from FilePickerService', () async {
      when(() => mockFilePicker.pickPdf()).thenThrow(Exception('Picker error'));

      expect(() => dataSource.pickAndProcessFile(), throwsException);
    });

    test('pickAndProcessFile propagates exceptions from OcrService', () async {
      const testPath = 'path/to/file.pdf';
      when(() => mockFilePicker.pickPdf()).thenAnswer((_) async => testPath);
      when(() => mockOcr.extractText(testPath)).thenThrow(Exception('OCR error'));

      expect(() => dataSource.pickAndProcessFile(), throwsException);
    });
  });
}
