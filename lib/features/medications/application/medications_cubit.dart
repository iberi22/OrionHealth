import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:orionhealth_health/features/medications/domain/repositories/medication_repository.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';
import 'medications_state.dart';

@injectable
class MedicationsCubit extends Cubit<MedicationsState> {
  final MedicationRepository _repository;

  MedicationsCubit(this._repository) : super(MedicationsInitial());

  Future<void> loadMedications() async {
    emit(MedicationsLoading());
    try {
      final medications = await _repository.getAllMedications();
      emit(MedicationsLoaded(medications));
    } catch (e) {
      emit(MedicationsError(e.toString()));
    }
  }

  Future<void> saveMedication(Medication medication) async {
    emit(MedicationsLoading());
    try {
      await _repository.saveMedication(medication);
      await loadMedications();
    } catch (e) {
      emit(MedicationsError(e.toString()));
    }
  }

  Future<void> deleteMedication(int id) async {
    emit(MedicationsLoading());
    try {
      await _repository.deleteMedication(id);
      await loadMedications();
    } catch (e) {
      emit(MedicationsError(e.toString()));
    }
  }
}
