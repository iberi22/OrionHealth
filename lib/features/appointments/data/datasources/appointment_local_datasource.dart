import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/appointment.dart';

@lazySingleton
class AppointmentLocalDataSource {
  final Isar _isar;

  AppointmentLocalDataSource(this._isar);

  Future<List<Appointment>> getAppointments() async {
    return await _isar.appointments.where().findAll();
  }

  Future<void> saveAppointment(Appointment appointment) async {
    await _isar.writeTxn(() async {
      await _isar.appointments.put(appointment);
    });
  }

  Future<void> deleteAppointment(Id id) async {
    await _isar.writeTxn(() async {
      await _isar.appointments.delete(id);
    });
  }

  Future<Appointment?> getAppointmentById(Id id) async {
    return await _isar.appointments.get(id);
  }
}
