import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../domain/entities/allergy.dart';
import '../domain/repositories/allergy_repository.dart';
import 'allergies_state.dart';

@injectable
class AllergiesCubit extends Cubit<AllergiesState> {
  final AllergyRepository _repository;

  AllergiesCubit(this._repository) : super(AllergiesInitial());

  Future<void> loadAllergies() async {
    emit(AllergiesLoading());
    try {
      final allergies = await _repository.getAllergies();
      emit(AllergiesLoaded(allergies));
    } catch (e) {
      emit(AllergiesError(e.toString()));
    }
  }

  Future<void> saveAllergy(Allergy allergy) async {
    try {
      await _repository.saveAllergy(allergy);
      await loadAllergies();
    } catch (e) {
      emit(AllergiesError(e.toString()));
    }
  }

  Future<void> deleteAllergy(Id id) async {
    try {
      await _repository.deleteAllergy(id);
      await loadAllergies();
    } catch (e) {
      emit(AllergiesError(e.toString()));
    }
  }
}
