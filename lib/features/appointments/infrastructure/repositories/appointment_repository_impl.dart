import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';

@LazySingleton(as: AppointmentRepository)
class AppointmentRepositoryImpl implements AppointmentRepository {
  final Isar _isar;

  AppointmentRepositoryImpl(this._isar);

  @override
  Future<List<Appointment>> getAllAppointments() async {
    return await _isar.appointments.where().sortByDateTimeDesc().findAll();
  }

  @override
  Future<List<Appointment>> getUpcomingAppointments() async {
    final now = DateTime.now();
    return await _isar.appointments
        .filter()
        .dateTimeGreaterThan(now)
        .and()
        .not()
        .statusEqualTo(AppointmentStatus.cancelled)
        .sortByDateTime()
        .findAll();
  }

  @override
  Future<List<Appointment>> getPastAppointments() async {
    final now = DateTime.now();
    return await _isar.appointments
        .filter()
        .dateTimeLessThan(now)
        .sortByDateTimeDesc()
        .findAll();
  }

  @override
  Future<Appointment?> getNextAppointment() async {
    final now = DateTime.now();
    return await _isar.appointments
        .filter()
        .dateTimeGreaterThan(now)
        .and()
        .not()
        .statusEqualTo(AppointmentStatus.cancelled)
        .sortByDateTime()
        .findFirst();
  }

  @override
  Future<Appointment?> getLastCompletedAppointment() async {
    return await _isar.appointments
        .filter()
        .statusEqualTo(AppointmentStatus.completed)
        .sortByDateTimeDesc()
        .findFirst();
  }

  @override
  Future<Appointment?> getAppointmentById(int id) async {
    return await _isar.appointments.get(id);
  }

  @override
  Future<void> saveAppointment(Appointment appointment) async {
    await _isar.writeTxn(() async {
      await _isar.appointments.put(appointment);
    });
  }

  @override
  Future<void> updateAppointmentStatus(int id, AppointmentStatus status) async {
    await _isar.writeTxn(() async {
      final appointment = await _isar.appointments.get(id);
      if (appointment != null) {
        final updated = appointment.copyWith(status: status);
        await _isar.appointments.put(updated);
      }
    });
  }

  @override
  Future<void> deleteAppointment(int id) async {
    await _isar.writeTxn(() async {
      await _isar.appointments.delete(id);
    });
  }
}
