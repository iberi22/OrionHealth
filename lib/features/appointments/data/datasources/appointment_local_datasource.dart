import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/appointment.dart';

@lazySingleton
class AppointmentLocalDataSource {
  final Isar _isar;
  AppointmentLocalDataSource(this._isar);

  Future<List<Appointment>> getAllAppointments() =>
      _isar.appointments.where().findAll();

  Future<void> saveAppointment(Appointment a) =>
      _isar.writeTxn(() async => _isar.appointments.put(a));

  Future<void> deleteAppointment(int id) =>
      _isar.writeTxn(() async => _isar.appointments.delete(id));
}
