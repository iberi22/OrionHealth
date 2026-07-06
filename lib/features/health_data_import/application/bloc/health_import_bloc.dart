// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'health_import_event.dart';
import '../../domain/entities/health_data_source.dart';
import '../../domain/entities/health_import_result.dart';
import '../health_import_state.dart';
import '../../domain/usecases/health_import_usecases.dart';

@injectable
class HealthImportBloc extends Bloc<HealthImportEvent, HealthImportState> {
  final GetAvailableSourcesUseCase _getAvailableSourcesUseCase;
  final RequestHealthAuthUseCase _requestHealthAuthUseCase;
  final ImportHealthDataUseCase _importHealthDataUseCase;

  HealthImportBloc(
    this._getAvailableSourcesUseCase,
    this._requestHealthAuthUseCase,
    this._importHealthDataUseCase,
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

      final importStream = _importHealthDataUseCase(source);

      await emit.forEach<ImportProgress>(
        importStream,
        onData: (progress) {
          if (progress.isCompleted) {
            return HealthImportSuccess(
              HealthImportResult(
                source: source,
                importedCount: progress.importedCount,
              ),
            );
          } else {
            return HealthImportImporting(
              source: source,
              currentStep: progress.currentStep,
              totalSteps: progress.totalSteps,
              currentStepNum: progress.currentStepNum,
              importedCount: progress.importedCount,
            );
          }
        },
      );
    } catch (e) {
      emit(HealthImportError('Import failed: $e'));
    }
  }

  void _onResetImport(ResetImport event, Emitter<HealthImportState> emit) {
    emit(HealthImportInitial());
  }
}
