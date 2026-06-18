import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/health_data_import/data/datasources/health_data_file_datasource.dart';
import 'package:orionhealth_health/features/health_record/infrastructure/services/file_picker_service.dart';
import 'package:orionhealth_health/features/health_record/infrastructure/services/ocr_service.dart';

class MockFilePickerService extends Mock implements FilePickerService {}
class MockOcrService extends Mock implements OcrService {}

void main() {
  late HealthDataFileDataSource dataSource;
  late MockFilePickerService mockFilePickerService;
  late MockOcrService mockOcrService;

  setUp(() {
    mockFilePickerService = MockFilePickerService();
    mockOcrService = MockOcrService();
    dataSource = HealthDataFileDataSource(
      mockFilePickerService,
      mockOcrService,
    );
  });

  group('HealthDataFileDataSource', () {
    test('pickAndExtractText returns null if no file is picked', () async {
      when(() => mockFilePickerService.pickPdf()).thenAnswer((_) async => null);

      final result = await dataSource.pickAndExtractText();

      expect(result, isNull);
      verify(() => mockFilePickerService.pickPdf()).called(1);
      verifyNever(() => mockOcrService.extractText(any()));
    });

    test('pickAndExtractText returns extracted text if file is picked', () async {
      const path = 'path/to/file.pdf';
      const extractedText = 'extracted text';
      when(() => mockFilePickerService.pickPdf()).thenAnswer((_) async => path);
      when(() => mockOcrService.extractText(path)).thenAnswer((_) async => extractedText);

      final result = await dataSource.pickAndExtractText();

      expect(result, extractedText);
      verify(() => mockFilePickerService.pickPdf()).called(1);
      verify(() => mockOcrService.extractText(path)).called(1);
    });
  });
}
