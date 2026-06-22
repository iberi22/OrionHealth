part of 'medication_bloc.dart';

abstract class MedicationEvent {}

class LoadMedications extends MedicationEvent {}

class SaveMedication extends MedicationEvent {
  final Medication medication;
  SaveMedication(this.medication);
}

class DeleteMedication extends MedicationEvent {
  final int id;
  DeleteMedication(this.id);
}
