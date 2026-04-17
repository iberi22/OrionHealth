import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../domain/services/health_data_import_service.dart';
import '../../vitals/domain/repositories/vital_sign_repository.dart';
import 'health_import_state.dart';

@injectable
class HealthImportCubit extends Cubit<HealthImportState> {
  final HealthDataImportService _importService;
  final VitalSignRepository _vitalSignRepository;

  HealthImportCubit(
    this._importService,
    this._vitalSignRepository,
  ) : super(HealthImportInitial());

  Future<void> checkAvailableSources() async {
    emit(HealthImportLoading());
    try {
      final availableSources = await _importService.getAvailableSources();
      final availability = <HealthDataSource, bool>{};
      
      for (final source in HealthDataSource.values) {
        availability[source] = availableSources.contains(source);
      }

      emit(HealthImportReady(
        availableSources: availableSources,
        availability: availability,
      ));
    } catch (e) {
      emit(HealthImportError('Failed to check available sources: $e'));
    }
  }

  Future<void> importFromSource(HealthDataSource source) async {
    emit(HealthImportAuthenticating(source));
    try {
      final isAuthenticated = await _importService.requestAuthorization(source);
      if (!isAuthenticated) {
        emit(const HealthImportError(
          'Authorization denied. Please grant permission to access health data.',
        ));
        return;
      }

      // Import steps
      emit(HealthImportImporting(
        source: source,
        currentStep: 'Importing steps...',
        totalSteps: 8,
        currentStepNum: 1,
        importedCount: 0,
      ));
      
      final stepsData = await _importService.fetchSteps();
      final stepsVitalSigns = await _importService.convertToVitalSigns(stepsData, source);
      await _vitalSignRepository.saveVitalSigns(stepsVitalSigns);
      
      // Import distance
      emit(HealthImportImporting(
        source: source,
        currentStep: 'Importing distance...',
        totalSteps: 8,
        currentStepNum: 2,
        importedCount: stepsVitalSigns.length,
      ));
      
      final distanceData = await _importService.fetchDistance();
      final distanceVitalSigns = await _importService.convertToVitalSigns(distanceData, source);
      await _vitalSignRepository.saveVitalSigns(distanceVitalSigns);

      // Import heart rate
      emit(HealthImportImporting(
        source: source,
        currentStep: 'Importing heart rate...',
        totalSteps: 8,
        currentStepNum: 3,
        importedCount: stepsVitalSigns.length + distanceVitalSigns.length,
      ));
      
      final heartRateData = await _importService.fetchHeartRate();
      final heartRateVitalSigns = await _importService.convertToVitalSigns(heartRateData, source);
      await _vitalSignRepository.saveVitalSigns(heartRateVitalSigns);

      // Import sleep
      emit(HealthImportImporting(
        source: source,
        currentStep: 'Importing sleep data...',
        totalSteps: 8,
        currentStepNum: 4,
        importedCount: stepsVitalSigns.length + distanceVitalSigns.length + heartRateVitalSigns.length,
      ));
      
      final sleepData = await _importService.fetchSleep();
      final sleepVitalSigns = await _importService.convertToVitalSigns(sleepData, source);
      await _vitalSignRepository.saveVitalSigns(sleepVitalSigns);

      // Import blood glucose
      emit(HealthImportImporting(
        source: source,
        currentStep: 'Importing blood glucose...',
        totalSteps: 8,
        currentStepNum: 5,
        importedCount: stepsVitalSigns.length + distanceVitalSigns.length + heartRateVitalSigns.length + sleepVitalSigns.length,
      ));
      
      final bloodGlucoseData = await _importService.fetchBloodGlucose();
      final bloodGlucoseVitalSigns = await _importService.convertToVitalSigns(bloodGlucoseData, source);
      await _vitalSignRepository.saveVitalSigns(bloodGlucoseVitalSigns);

      // Import blood pressure
      emit(HealthImportImporting(
        source: source,
        currentStep: 'Importing blood pressure...',
        totalSteps: 8,
        currentStepNum: 6,
        importedCount: stepsVitalSigns.length + distanceVitalSigns.length + heartRateVitalSigns.length + sleepVitalSigns.length + bloodGlucoseVitalSigns.length,
      ));
      
      final bloodPressureData = await _importService.fetchBloodPressure();
      final bloodPressureVitalSigns = await _importService.convertToVitalSigns(bloodPressureData, source);
      await _vitalSignRepository.saveVitalSigns(bloodPressureVitalSigns);

      // Import height and weight
      emit(HealthImportImporting(
        source: source,
        currentStep: 'Importing height and weight...',
        totalSteps: 8,
        currentStepNum: 7,
        importedCount: stepsVitalSigns.length + distanceVitalSigns.length + heartRateVitalSigns.length + sleepVitalSigns.length + bloodGlucoseVitalSigns.length + bloodPressureVitalSigns.length,
      ));
      
      final heightData = await _importService.fetchHeight();
      final heightVitalSigns = await _importService.convertToVitalSigns(heightData, source);
      await _vitalSignRepository.saveVitalSigns(heightVitalSigns);
      
      final weightData = await _importService.fetchWeight();
      final weightVitalSigns = await _importService.convertToVitalSigns(weightData, source);
      await _vitalSignRepository.saveVitalSigns(weightVitalSigns);

      // Import oxygen saturation
      emit(HealthImportImporting(
        source: source,
        currentStep: 'Importing oxygen saturation...',
        totalSteps: 8,
        currentStepNum: 8,
        importedCount: stepsVitalSigns.length + distanceVitalSigns.length + heartRateVitalSigns.length + sleepVitalSigns.length + bloodGlucoseVitalSigns.length + bloodPressureVitalSigns.length + heightVitalSigns.length + weightVitalSigns.length,
      ));
      
      final oxygenData = await _importService.fetchOxygenSaturation();
      final oxygenVitalSigns = await _importService.convertToVitalSigns(oxygenData, source);
      await _vitalSignRepository.saveVitalSigns(oxygenVitalSigns);

      final totalImported = stepsVitalSigns.length +
          distanceVitalSigns.length +
          heartRateVitalSigns.length +
          sleepVitalSigns.length +
          bloodGlucoseVitalSigns.length +
          bloodPressureVitalSigns.length +
          heightVitalSigns.length +
          weightVitalSigns.length +
          oxygenVitalSigns.length;

      emit(HealthImportSuccess(
        importedCount: totalImported,
        source: source,
      ));
    } catch (e) {
      emit(HealthImportError('Import failed: $e'));
    }
  }

  void reset() {
    emit(HealthImportInitial());
  }
}
