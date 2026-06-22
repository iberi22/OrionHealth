import 'package:injectable/injectable.dart';
import '../services/health_data_import_service.dart';
import '../../application/health_import_state.dart';

@injectable
class GetAvailableSourcesUseCase {
  final HealthDataImportService _service;
  GetAvailableSourcesUseCase(this._service);

  Future<List<HealthDataSource>> call() => _service.getAvailableSources();
}

@injectable
class RequestHealthAuthUseCase {
  final HealthDataImportService _service;
  RequestHealthAuthUseCase(this._service);

  Future<bool> call(HealthDataSource source) => _service.requestAuthorization(source);
}
