import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/allergy.dart';
import '../../domain/repositories/allergy_repository.dart';

part 'allergy_event.dart';
part 'allergy_state.dart';
part 'allergy_bloc.freezed.dart';

@injectable
class AllergyBloc extends Bloc<AllergyEvent, AllergyState> {
  final AllergyRepository _repository;

  AllergyBloc(this._repository) : super(const AllergyInitial()) {
    on<LoadAllergies>(_onLoadAllergies);
    on<SaveAllergy>(_onSaveAllergy);
    on<DeleteAllergy>(_onDeleteAllergy);
  }

  Future<void> _onLoadAllergies(
    LoadAllergies event,
    Emitter<AllergyState> emit,
  ) async {
    emit(const AllergyLoading());
    try {
      final allergies = await _repository.getAllergies();
      emit(AllergyLoaded(allergies));
    } catch (e) {
      emit(AllergyError(e.toString()));
    }
  }

  Future<void> _onSaveAllergy(
    SaveAllergy event,
    Emitter<AllergyState> emit,
  ) async {
    try {
      await _repository.saveAllergy(event.allergy);
      add(LoadAllergies());
    } catch (e) {
      emit(AllergyError(e.toString()));
    }
  }

  Future<void> _onDeleteAllergy(
    DeleteAllergy event,
    Emitter<AllergyState> emit,
  ) async {
    try {
      await _repository.deleteAllergy(event.id);
      add(LoadAllergies());
    } catch (e) {
      emit(AllergyError(e.toString()));
    }
  }
}
