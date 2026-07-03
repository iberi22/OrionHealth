import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_local_datasource.dart';

@LazySingleton(as: AppointmentRepository)
class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentLocalDataSource _localDataSource;

  AppointmentRepositoryImpl(this._localDataSource);

  @override
  Future<List<Appointment>> getAllAppointments() {
    return _localDataSource.getAppointments();
  }

  @override
  Future<void> saveAppointment(Appointment appointment) {
    return _localDataSource.saveAppointment(appointment);
  }

  @override
  Future<void> deleteAppointment(Id id) {
    return _localDataSource.deleteAppointment(id);
  }
}
