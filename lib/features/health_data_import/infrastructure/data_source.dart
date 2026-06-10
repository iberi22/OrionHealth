import 'package:health/health.dart';
import 'package:injectable/injectable.dart';
import '../../health_record/infrastructure/services/file_picker_service.dart';
import '../../health_record/infrastructure/services/ocr_service.dart';

abstract class SensorHealthDataSource {
  Future<bool> requestAuthorization(List<HealthDataType> types, List<HealthDataAccess> permissions);
  Future<List<HealthDataPoint>> fetchData(HealthDataType type, DateTime start, DateTime end);
  Future<bool> hasPermissions(List<HealthDataType> types);
}

@LazySingleton(as: SensorHealthDataSource)
class SensorHealthDataSourceImpl implements SensorHealthDataSource {
  final Health _health = Health();

  @override
  Future<bool> requestAuthorization(List<HealthDataType> types, List<HealthDataAccess> permissions) async {
    return await _health.requestAuthorization(types, permissions: permissions);
  }

  @override
  Future<List<HealthDataPoint>> fetchData(HealthDataType type, DateTime start, DateTime end) async {
    return await _health.getHealthDataFromTypes(
      types: [type],
      startTime: start,
      endTime: end,
    );
  }

  @override
  Future<bool> hasPermissions(List<HealthDataType> types) async {
    final result = await _health.hasPermissions(types);
    return result ?? false;
  }
}

abstract class FileHealthDataSource {
  Future<String?> pickAndExtractText();
}

@LazySingleton(as: FileHealthDataSource)
class FileHealthDataSourceImpl implements FileHealthDataSource {
  final FilePickerService _filePickerService;
  final OcrService _ocrService;

  FileHealthDataSourceImpl(this._filePickerService, this._ocrService);

  @override
  Future<String?> pickAndExtractText() async {
    final path = await _filePickerService.pickPdf();
    if (path == null) return null;
    return await _ocrService.extractText(path);
  }
}
