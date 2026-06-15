import 'package:injectable/injectable.dart';
import '../../../health_record/infrastructure/services/file_picker_service.dart';
import '../../../health_record/infrastructure/services/ocr_service.dart';

@lazySingleton
class HealthDataFileDataSource {
  final FilePickerService _filePickerService;
  final OcrService _ocrService;

  HealthDataFileDataSource(this._filePickerService, this._ocrService);

  Future<String?> pickAndExtractText() async {
    final path = await _filePickerService.pickPdf();
    if (path == null) return null;
    return await _ocrService.extractText(path);
  }
}
