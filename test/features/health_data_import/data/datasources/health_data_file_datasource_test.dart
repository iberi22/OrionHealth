import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/health_data_import/data/datasources/health_data_file_datasource.dart';
import 'package:orionhealth_health/features/health_record/infrastructure/services/file_picker_service.dart';
import 'package:orionhealth_health/features/health_record/infrastructure/services/ocr_service.dart';

class MockFilePickerService extends Mock implements FilePickerService {}
class MockOcrService extends Mock implements OcrService {}

void main() {
  late HealthDataFileDataSource datasource;
  late MockFilePickerService mockFilePicker;
  late MockOcrService mockOcr;

  setUp(() {
    mockFilePicker = MockFilePickerService();
    mockOcr = MockOcrService();
    datasource = HealthDataFileDataSource(mockFilePicker, mockOcr);
  });

  group('HealthDataFileDataSource', () {
    test('pickAndExtractText returns text when file picked and OCR successful', () async {
      when(() => mockFilePicker.pickPdf()).thenAnswer((_) async => 'path/to/file.pdf');
      when(() => mockOcr.extractText(any())).thenAnswer((_) async => 'extracted text');

      final result = await datasource.pickAndExtractText();

      expect(result, 'extracted text');
    });

    test('pickAndExtractText returns null when no file picked', () async {
      when(() => mockFilePicker.pickPdf()).thenAnswer((_) async => null);

      final result = await datasource.pickAndExtractText();

      expect(result, isNull);
    });
  });
}
