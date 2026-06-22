// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'health_import_event.dart';
import '../health_import_state.dart';
import '../../domain/services/health_data_import_service.dart';
import '../../../vitals/domain/repositories/vital_sign_repository.dart';
import '../../domain/usecases/health_import_usecases.dart';

@injectable
class HealthImportBloc extends Bloc<HealthImportEvent, HealthImportState> {
  final GetAvailableSourcesUseCase _getAvailableSourcesUseCase;
  final RequestHealthAuthUseCase _requestHealthAuthUseCase;
  final HealthDataImportService _importService;
  final VitalSignRepository _vitalSignRepository;

  HealthImportBloc(
    this._getAvailableSourcesUseCase,
    this._requestHealthAuthUseCase,
    this._importService,
    this._vitalSignRepository,
  ) : super(HealthImportInitial()) {
    on<CheckAvailableSources>(_onCheckAvailableSources);
    on<ImportFromSource>(_onImportFromSource);
    on<ResetImport>(_onResetImport);
  }

  Future<void> _onCheckAvailableSources(
    CheckAvailableSources event,
    Emitter<HealthImportState> emit,
  ) async {
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

  Future<void> _onImportFromSource(
    ImportFromSource event,
    Emitter<HealthImportState> emit,
  ) async {
    final source = event.source;
    emit(HealthImportAuthenticating(source));
    try {
      final isAuthenticated = await _requestHealthAuthUseCase(source);
      if (!isAuthenticated) {
        emit(const HealthImportError(
          'Authorization denied. Please grant permission to access health data.',
        ));
        return;
      }

      int totalImported = 0;
      final steps = [
        ('Importing steps...', _importService.fetchSteps),
        ('Importing distance...', _importService.fetchDistance),
        ('Importing heart rate...', _importService.fetchHeartRate),
        ('Importing sleep data...', _importService.fetchSleep),
        ('Importing blood glucose...', _importService.fetchBloodGlucose),
        ('Importing blood pressure...', _importService.fetchBloodPressure),
        ('Importing height...', _importService.fetchHeight),
        ('Importing weight...', _importService.fetchWeight),
        ('Importing oxygen saturation...', _importService.fetchOxygenSaturation),
      ];

      for (int i = 0; i < steps.length; i++) {
        emit(HealthImportImporting(
          source: source,
          currentStep: steps[i].$1,
          totalSteps: steps.length,
          currentStepNum: i + 1,
          importedCount: totalImported,
        ));

        final data = await steps[i].$2();
        final vitals = await _importService.convertToVitalSigns(data, source);
        await _vitalSignRepository.saveVitalSigns(vitals);
        totalImported += vitals.length;
      }

      emit(HealthImportSuccess(
        importedCount: totalImported,
        source: source,
      ));
    } catch (e) {
      emit(HealthImportError('Import failed: $e'));
    }
  }

  void _onResetImport(ResetImport event, Emitter<HealthImportState> emit) {
    emit(HealthImportInitial());
  }
}
