part of 'appointment_bloc.dart';

@freezed
class AppointmentState with _$AppointmentState {
  const factory AppointmentState.initial() = AppointmentInitial;
  const factory AppointmentState.loading() = AppointmentLoading;
  const factory AppointmentState.loaded(List<Appointment> appointments) = AppointmentLoaded;
  const factory AppointmentState.error(String message) = AppointmentError;
}
