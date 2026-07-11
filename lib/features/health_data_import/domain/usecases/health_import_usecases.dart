import 'package:health/health.dart';
import 'package:injectable/injectable.dart';
import '../services/health_data_import_service.dart';
import '../entities/health_data_source.dart';
import '../../../vitals/domain/repositories/vital_sign_repository.dart';

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

class ImportProgress {
  final String currentStep;
  final int totalSteps;
  final int currentStepNum;
  final int importedCount;
  final bool isCompleted;

  const ImportProgress({
    required this.currentStep,
    required this.totalSteps,
    required this.currentStepNum,
    required this.importedCount,
    this.isCompleted = false,
  });
}

@injectable
class ImportHealthDataUseCase {
  final HealthDataImportService _service;
  final VitalSignRepository _vitalSignRepository;

  ImportHealthDataUseCase(this._service, this._vitalSignRepository);

  Stream<ImportProgress> call(HealthDataSource source) async* {
    int totalImported = 0;
    const int totalSteps = 8;

    final steps = [
      _ImportStep('Importing steps...', _service.fetchSteps),
      _ImportStep('Importing distance...', _service.fetchDistance),
      _ImportStep('Importing heart rate...', _service.fetchHeartRate),
      _ImportStep('Importing sleep data...', _service.fetchSleep),
      _ImportStep('Importing blood glucose...', _service.fetchBloodGlucose),
      _ImportStep('Importing blood pressure...', _service.fetchBloodPressure),
      _ImportStep('Importing height and weight...', () async {
        final height = await _service.fetchHeight();
        final weight = await _service.fetchWeight();
        return [...height, ...weight];
      }),
      _ImportStep('Importing oxygen saturation...', _service.fetchOxygenSaturation),
    ];

    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      yield ImportProgress(
        currentStep: step.name,
        totalSteps: totalSteps,
        currentStepNum: i + 1,
        importedCount: totalImported,
      );

      final data = await step.fetch();
      final vitalSigns = await _service.convertToVitalSigns(data, source);
      await _vitalSignRepository.saveVitalSigns(vitalSigns);
      totalImported += vitalSigns.length;
    }

    yield ImportProgress(
      currentStep: 'Completed',
      totalSteps: totalSteps,
      currentStepNum: totalSteps,
      importedCount: totalImported,
      isCompleted: true,
    );
  }
}

class _ImportStep {
  final String name;
  final Future<List<HealthDataPoint>> Function() fetch;

  _ImportStep(this.name, this.fetch);
}
