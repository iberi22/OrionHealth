import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:medical_standards/medical_standards.dart';
import '../../appointments/domain/entities/appointment.dart';
import '../../appointments/domain/repositories/appointment_repository.dart';
import '../../user_profile/domain/repositories/user_profile_repository.dart';
import '../data/calendar_repository.dart';

abstract class CalendarImportState {}

class CalendarImportInitial extends CalendarImportState {}

class CalendarImportLoading extends CalendarImportState {}

class CalendarImportLoaded extends CalendarImportState {
  final List<Appointment> foundAppointments;
  CalendarImportLoaded(this.foundAppointments);
}

class CalendarImportSuccess extends CalendarImportState {
  final int importedCount;
  CalendarImportSuccess(this.importedCount);
}

class CalendarImportError extends CalendarImportState {
  final String message;
  CalendarImportError(this.message);
}

class CalendarImportPermissionDenied extends CalendarImportState {}

@injectable
class CalendarImportCubit extends Cubit<CalendarImportState> {
  final CalendarRepository _calendarRepository;
  final AppointmentRepository _appointmentRepository;
  final UserProfileRepository _userProfileRepository;

  CalendarImportCubit(
    this._calendarRepository,
    this._appointmentRepository,
    this._userProfileRepository,
  ) : super(CalendarImportInitial());

  Future<void> scanCalendar() async {
    emit(CalendarImportLoading());
    try {
      final hasPermission = await _calendarRepository.hasPermissions();
      if (!hasPermission) {
        final granted = await _calendarRepository.requestPermissions();
        if (!granted) {
          emit(CalendarImportPermissionDenied());
          return;
        }
      }

      final appointments = await _calendarRepository.fetchMedicalEvents();
      emit(CalendarImportLoaded(appointments));
    } catch (e) {
      emit(CalendarImportError(e.toString()));
    }
  }

  Future<void> importAppointments(List<Appointment> appointments) async {
    emit(CalendarImportLoading());
    try {
      int count = 0;
      final profile = await _userProfileRepository.getUserProfile();
      final isConnected = profile?.uniqueId != null;

      for (final app in appointments) {
        await _appointmentRepository.saveAppointment(app);
        count++;

        if (isConnected) {
          _syncWithFhir(app, profile!.uniqueId!);
        }
      }
      emit(CalendarImportSuccess(count));
    } catch (e) {
      emit(CalendarImportError(e.toString()));
    }
  }

  void _syncWithFhir(Appointment appointment, String patientId) {
    // In a real application, this would call a FHIR API.
    // Here we use the FhirAppointment builder from medical_standards to prepare the data.
    final fhirAppointment = FhirAppointment(
      id: 'app-${appointment.id}',
      status: 'booked',
      start: appointment.dateTime,
      description: '${appointment.specialty} con ${appointment.doctorName}',
      participantActorDisplay: 'Patient/$patientId',
    );

    // Mock FHIR sync log
    // ignore: avoid_print
    print('Syncing to FHIR: ${fhirAppointment.toJson()}');
  }
}
