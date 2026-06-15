import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_local_datasource.dart';
import '../datasources/appointment_remote_datasource.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentLocalDataSource _localDataSource;
  final AppointmentRemoteDataSource _remoteDataSource;
  AppointmentRepositoryImpl(this._localDataSource, this._remoteDataSource);

  @override
  Future<List<Appointment>> getAllAppointments() => _localDataSource.getAllAppointments();

  @override
  Future<List<Appointment>> getUpcomingAppointments() => _localDataSource.getUpcomingAppointments();

  @override
  Future<void> saveAppointment(Appointment appointment) => _localDataSource.saveAppointment(appointment);

  @override
  Future<void> deleteAppointment(int id) => _localDataSource.deleteAppointment(id);
}
