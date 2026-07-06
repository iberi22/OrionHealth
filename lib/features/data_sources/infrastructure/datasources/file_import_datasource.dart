import 'package:injectable/injectable.dart';
import '../../../health_record/infrastructure/services/file_picker_service.dart';
import '../../../health_record/infrastructure/services/ocr_service.dart';

abstract class FileImportDataSource {
  Future<String?> pickAndProcessFile();
}

@LazySingleton(as: FileImportDataSource)
class FileImportDataSourceImpl implements FileImportDataSource {
  final FilePickerService _filePickerService;
  final OcrService _ocrService;

  FileImportDataSourceImpl(this._filePickerService, this._ocrService);

  @override
  Future<String?> pickAndProcessFile() async {
    final path = await _filePickerService.pickPdf();
    if (path == null) return null;
    return await _ocrService.extractText(path);
  }
}
