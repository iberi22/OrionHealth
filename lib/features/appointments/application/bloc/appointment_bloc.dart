import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';

part 'appointment_event.dart';
part 'appointment_state.dart';
part 'appointment_bloc.freezed.dart';

@injectable
class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final AppointmentRepository _repository;

  AppointmentBloc(this._repository) : super(const AppointmentInitial()) {
    on<LoadAppointments>(_onLoadAppointments);
    on<SaveAppointment>(_onSaveAppointment);
    on<DeleteAppointment>(_onDeleteAppointment);
  }

  Future<void> _onLoadAppointments(
    LoadAppointments event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(const AppointmentLoading());
    try {
      final appointments = await _repository.getAllAppointments();
      emit(AppointmentLoaded(appointments));
    } catch (e) {
      emit(AppointmentError(e.toString()));
    }
  }

  Future<void> _onSaveAppointment(
    SaveAppointment event,
    Emitter<AppointmentState> emit,
  ) async {
    try {
      await _repository.saveAppointment(event.appointment);
      add(LoadAppointments());
    } catch (e) {
      emit(AppointmentError(e.toString()));
    }
  }

  Future<void> _onDeleteAppointment(
    DeleteAppointment event,
    Emitter<AppointmentState> emit,
  ) async {
    try {
      await _repository.deleteAppointment(event.id);
      add(LoadAppointments());
    } catch (e) {
      emit(AppointmentError(e.toString()));
    }
  }
}
