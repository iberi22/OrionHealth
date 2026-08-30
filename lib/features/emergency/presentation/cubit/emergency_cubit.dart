/// FEAT-022: Emergency Cubit
///
/// Manages the current Medical ID state and provides actions for:
/// - load: read from repository
/// - update: save changes
/// - clear: delete Medical ID
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/medical_id.dart';
import '../../domain/usecases/get_medical_id_usecase.dart';
import '../../domain/usecases/update_medical_id_usecase.dart';

@injectable
class EmergencyCubit extends Cubit<EmergencyState> {
  final GetMedicalIdUseCase _getUseCase;
  final UpdateMedicalIdUseCase _updateUseCase;

  EmergencyCubit(this._getUseCase, this._updateUseCase)
      : super(const EmergencyState.initial());

  Future<void> load(String userId) async {
    emit(const EmergencyState.loading());
    try {
      final id = await _getUseCase(userId);
      if (id == null) {
        emit(const EmergencyState.notSet());
      } else {
        emit(EmergencyState.loaded(id));
      }
    } catch (e) {
      emit(EmergencyState.error(e.toString()));
    }
  }

  Future<void> save(MedicalIdEntity id) async {
    emit(const EmergencyState.saving());
    try {
      await _updateUseCase(id);
      emit(EmergencyState.loaded(id));
    } catch (e) {
      emit(EmergencyState.error(e.toString()));
    }
  }
}

class EmergencyState {
  final MedicalIdEntity? medicalId;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final bool notSet;

  const EmergencyState._({
    this.medicalId,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.notSet = false,
  });

  const EmergencyState.initial()
      : this._();

  const EmergencyState.loading()
      : this._(isLoading: true);

  const EmergencyState.notSet()
      : this._(notSet: true);

  const EmergencyState.loaded(MedicalIdEntity id)
      : this._(medicalId: id);

  const EmergencyState.saving()
      : this._(medicalId: null, isSaving: true);

  const EmergencyState.error(String message)
      : this._(error: message);
}
