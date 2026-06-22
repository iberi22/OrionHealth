import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/medication.dart';
import '../../domain/repositories/medication_repository.dart';

part 'medication_event.dart';
part 'medication_state.dart';
part 'medication_bloc.freezed.dart';

@injectable
class MedicationBloc extends Bloc<MedicationEvent, MedicationState> {
  final MedicationRepository _repository;

  MedicationBloc(this._repository) : super(const MedicationInitial()) {
    on<LoadMedications>(_onLoadMedications);
    on<SaveMedication>(_onSaveMedication);
    on<DeleteMedication>(_onDeleteMedication);
  }

  Future<void> _onLoadMedications(
    LoadMedications event,
    Emitter<MedicationState> emit,
  ) async {
    emit(const MedicationLoading());
    try {
      final medications = await _repository.getAllMedications();
      emit(MedicationLoaded(medications));
    } catch (e) {
      emit(MedicationError(e.toString()));
    }
  }

  Future<void> _onSaveMedication(
    SaveMedication event,
    Emitter<MedicationState> emit,
  ) async {
    try {
      await _repository.saveMedication(event.medication);
      add(LoadMedications());
    } catch (e) {
      emit(MedicationError(e.toString()));
    }
  }

  Future<void> _onDeleteMedication(
    DeleteMedication event,
    Emitter<MedicationState> emit,
  ) async {
    try {
      await _repository.deleteMedication(event.id);
      add(LoadMedications());
    } catch (e) {
      emit(MedicationError(e.toString()));
    }
  }
}
