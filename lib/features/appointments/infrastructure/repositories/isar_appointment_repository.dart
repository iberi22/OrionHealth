import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';

@LazySingleton(as: AppointmentRepository)
class IsarAppointmentRepository implements AppointmentRepository {
  final Isar _isar;

  IsarAppointmentRepository(this._isar);

  @override
  Future<List<Appointment>> getAllAppointments() async {
    return await _isar.appointments.where().findAll();
  }

  @override
  Future<void> saveAppointment(Appointment appointment) async {
    await _isar.writeTxn(() async {
      await _isar.appointments.put(appointment);
    });
  }

  @override
  Future<void> deleteAppointment(int id) async {
    await _isar.writeTxn(() async {
      await _isar.appointments.delete(id);
    });
  }
}
