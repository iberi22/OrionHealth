part of 'medication_bloc.dart';

@freezed
class MedicationState with _$MedicationState {
  const factory MedicationState.initial() = MedicationInitial;
  const factory MedicationState.loading() = MedicationLoading;
  const factory MedicationState.loaded(List<Medication> medications) = MedicationLoaded;
  const factory MedicationState.error(String message) = MedicationError;
}
