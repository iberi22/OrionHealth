import 'package:health/health.dart';
import 'package:injectable/injectable.dart';
import '../../../core/utils/health_helper.dart';
import '../../health_record/infrastructure/services/file_picker_service.dart';
import '../../health_record/infrastructure/services/ocr_service.dart';

abstract class SensorHealthDataSource {
  Future<bool> requestAuthorization(List<HealthDataType> types, List<HealthDataAccess> permissions);
  Future<List<HealthDataPoint>> fetchData(HealthDataType type, DateTime start, DateTime end);
  Future<bool> hasPermissions(List<HealthDataType> types);
}

@LazySingleton(as: SensorHealthDataSource)
class SensorHealthDataSourceImpl implements SensorHealthDataSource {
  final Health? _health = HealthHelper.createClient();

  @override
  Future<bool> requestAuthorization(List<HealthDataType> types, List<HealthDataAccess> permissions) async {
    if (_health == null) return false;
    try {
      return await _health!.requestAuthorization(types, permissions: permissions);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<HealthDataPoint>> fetchData(HealthDataType type, DateTime start, DateTime end) async {
    if (_health == null) return [];
    try {
      return await _health!.getHealthDataFromTypes(
        types: [type],
        startTime: start,
        endTime: end,
      );
    } catch (_) {
      return [];
    }
  }

  @override
  Future<bool> hasPermissions(List<HealthDataType> types) async {
    if (_health == null) return false;
    try {
      final result = await _health!.hasPermissions(types);
      return result ?? false;
    } catch (_) {
      return false;
    }
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
