import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/vital_sign.dart';
import '../../domain/repositories/vital_sign_repository.dart';

part 'vital_sign_event.dart';
part 'vital_sign_state.dart';
part 'vital_sign_bloc.freezed.dart';

@injectable
class VitalSignBloc extends Bloc<VitalSignEvent, VitalSignState> {
  final VitalSignRepository _repository;

  VitalSignBloc(this._repository) : super(const VitalSignInitial()) {
    on<LoadVitalSigns>(_onLoadVitalSigns);
    on<LoadLatestVitals>(_onLoadLatestVitals);
    on<SaveVitalSign>(_onSaveVitalSign);
    on<SaveVitalSigns>(_onSaveVitalSigns);
  }

  Future<void> _onLoadVitalSigns(
    LoadVitalSigns event,
    Emitter<VitalSignState> emit,
  ) async {
    emit(const VitalSignLoading());
    try {
      final vitals = await _repository.getAllVitalSigns();
      emit(VitalSignLoaded(vitals));
    } catch (e) {
      emit(VitalSignError(e.toString()));
    }
  }

  Future<void> _onLoadLatestVitals(
    LoadLatestVitals event,
    Emitter<VitalSignState> emit,
  ) async {
    emit(const VitalSignLoading());
    try {
      final latest = await _repository.getLatestVitals();
      emit(VitalSignLatestLoaded(latest));
    } catch (e) {
      emit(VitalSignError(e.toString()));
    }
  }

  Future<void> _onSaveVitalSign(
    SaveVitalSign event,
    Emitter<VitalSignState> emit,
  ) async {
    try {
      await _repository.saveVitalSign(event.vitalSign);
      add(LoadVitalSigns());
    } catch (e) {
      emit(VitalSignError(e.toString()));
    }
  }

  Future<void> _onSaveVitalSigns(
    SaveVitalSigns event,
    Emitter<VitalSignState> emit,
  ) async {
    try {
      await _repository.saveVitalSigns(event.vitalSigns);
      add(LoadVitalSigns());
    } catch (e) {
      emit(VitalSignError(e.toString()));
    }
  }
}
