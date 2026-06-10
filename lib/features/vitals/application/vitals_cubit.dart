import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../domain/entities/vital_sign.dart';
import '../domain/repositories/vital_sign_repository.dart';
import 'vitals_state.dart';

@injectable
class VitalsCubit extends Cubit<VitalsState> {
  final VitalSignRepository _repository;

  VitalsCubit(this._repository) : super(VitalsInitial());

  Future<void> loadVitals() async {
    emit(VitalsLoading());
    try {
      final vitals = await _repository.getAllVitalSigns();
      emit(VitalsLoaded(vitals));
    } catch (e) {
      emit(VitalsError(e.toString()));
    }
  }

  Future<void> loadLatestVitals() async {
    emit(VitalsLoading());
    try {
      final latest = await _repository.getLatestVitals();
      emit(VitalsLatestLoaded(latest));
    } catch (e) {
      emit(VitalsError(e.toString()));
    }
  }

  Future<void> saveVitalSign(VitalSign vitalSign) async {
    try {
      await _repository.saveVitalSign(vitalSign);
      await loadVitals();
    } catch (e) {
      emit(VitalsError(e.toString()));
    }
  }

  Future<void> saveVitalSigns(List<VitalSign> vitalSigns) async {
    try {
      await _repository.saveVitalSigns(vitalSigns);
      await loadVitals();
    } catch (e) {
      emit(VitalsError(e.toString()));
    }
  }
}
