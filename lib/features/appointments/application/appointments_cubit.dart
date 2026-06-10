import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../domain/entities/appointment.dart';
import '../domain/repositories/appointment_repository.dart';
import 'appointments_state.dart';

@injectable
class AppointmentsCubit extends Cubit<AppointmentsState> {
  final AppointmentRepository _repository;

  AppointmentsCubit(this._repository) : super(AppointmentsInitial());

  Future<void> loadAppointments() async {
    emit(AppointmentsLoading());
    try {
      final appointments = await _repository.getAllAppointments();
      emit(AppointmentsLoaded(appointments));
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  Future<void> saveAppointment(Appointment appointment) async {
    try {
      await _repository.saveAppointment(appointment);
      await loadAppointments();
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  Future<void> deleteAppointment(int id) async {
    try {
      await _repository.deleteAppointment(id);
      await loadAppointments();
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }
}
