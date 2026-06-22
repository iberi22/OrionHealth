part of 'allergy_bloc.dart';

abstract class AllergyEvent {}

class LoadAllergies extends AllergyEvent {}

class SaveAllergy extends AllergyEvent {
  final Allergy allergy;
  SaveAllergy(this.allergy);
}

class DeleteAllergy extends AllergyEvent {
  final Id id;
  DeleteAllergy(this.id);
}
