part of 'appointment_bloc.dart';

abstract class AppointmentEvent {}

class LoadAppointments extends AppointmentEvent {}

class SaveAppointment extends AppointmentEvent {
  final Appointment appointment;
  SaveAppointment(this.appointment);
}

class DeleteAppointment extends AppointmentEvent {
  final int id;
  DeleteAppointment(this.id);
}
