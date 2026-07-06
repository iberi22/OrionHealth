import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../domain/usecases/health_import_usecases.dart';
import '../domain/entities/health_data_source.dart';
import '../domain/entities/health_import_result.dart';
import 'health_import_state.dart';

@injectable
class HealthImportCubit extends Cubit<HealthImportState> {
  final GetAvailableSourcesUseCase _getAvailableSourcesUseCase;
  final RequestHealthAuthUseCase _requestHealthAuthUseCase;
  final ImportHealthDataUseCase _importHealthDataUseCase;

  HealthImportCubit(
    this._getAvailableSourcesUseCase,
    this._requestHealthAuthUseCase,
    this._importHealthDataUseCase,
  ) : super(HealthImportInitial());

  Future<void> checkAvailableSources() async {
    emit(HealthImportLoading());
    try {
      final availableSources = await _getAvailableSourcesUseCase();
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
      final isAuthenticated = await _requestHealthAuthUseCase(source);
      if (!isAuthenticated) {
        emit(const HealthImportError(
          'Authorization denied. Please grant permission to access health data.',
        ));
        return;
      }

      final importStream = _importHealthDataUseCase(source);
      
      await for (final progress in importStream) {
        if (progress.isCompleted) {
          emit(HealthImportSuccess(
            HealthImportResult(
              source: source,
              importedCount: progress.importedCount,
            ),
          ));
        } else {
          emit(HealthImportImporting(
            source: source,
            currentStep: progress.currentStep,
            totalSteps: progress.totalSteps,
            currentStepNum: progress.currentStepNum,
            importedCount: progress.importedCount,
          ));
        }
      }
    } catch (e) {
      emit(HealthImportError('Import failed: $e'));
    }
  }

  void reset() {
    emit(HealthImportInitial());
  }
}
