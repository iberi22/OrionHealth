import 'package:injectable/injectable.dart';
import 'package:medical_standards/medical_standards.dart';

import '../../../appointments/domain/entities/appointment.dart';
import '../../../appointments/domain/repositories/appointment_repository.dart';
import '../../../user_profile/domain/repositories/user_profile_repository.dart';
import '../entities/calendar_appointment.dart';
import '../entities/calendar_event.dart';
import '../repositories/calendar_import_repository.dart';

/// Parameters for the import calendar use case.
class ImportCalendarParams {
  final List<CalendarAppointment> appointments;

  const ImportCalendarParams({required this.appointments});
}

/// Result returned after importing calendar events.
class ImportCalendarResult {
  final int importedCount;
  final List<Appointment> appointments;
  final int syncedToFhirCount;

  const ImportCalendarResult({
    required this.importedCount,
    required this.appointments,
    this.syncedToFhirCount = 0,
  });
}

/// Use case: scan device calendars and import medical events as [Appointment]s.
///
/// Orchestrates:
/// 1. Checking / requesting calendar permissions
/// 2. Fetching medical events from the device calendar
/// 3. Mapping [CalendarAppointment]s to [Appointment]s
/// 4. Saving each appointment via [AppointmentRepository]
/// 5. Optionally syncing to FHIR if the user is connected
@injectable
class ImportCalendarUseCase {
  final CalendarImportRepository _calendarRepository;
  final AppointmentRepository _appointmentRepository;
  final UserProfileRepository _userProfileRepository;

  ImportCalendarUseCase(
    this._calendarRepository,
    this._appointmentRepository,
    this._userProfileRepository,
  );

  /// Checks and requests calendar permissions.
  /// Returns `true` if permissions are available.
  Future<bool> ensurePermissions() async {
    final has = await _calendarRepository.hasPermissions();
    if (has) return true;
    return await _calendarRepository.requestPermissions();
  }

  /// Scans the device calendar for medical events.
  /// Returns a list of [CalendarAppointment]s.
  Future<List<CalendarAppointment>> scanForMedicalEvents() async {
    return await _calendarRepository.fetchMedicalAppointments();
  }

  /// Imports the given [CalendarAppointment]s by converting them to [Appointment]s
  /// and persisting them. Returns a result with the import count.
  Future<ImportCalendarResult> execute(ImportCalendarParams params) async {
    final profile = await _userProfileRepository.getUserProfile();
    final isConnected = profile?.uniqueId != null;

    final List<Appointment> appointments = [];
    int syncedToFhirCount = 0;

    for (final calendarApp in params.appointments) {
      final appointment = _mapToAppointment(calendarApp);
      await _appointmentRepository.saveAppointment(appointment);
      appointments.add(appointment);

      if (isConnected) {
        _syncToFhir(appointment, profile!.uniqueId!);
        syncedToFhirCount++;
      }
    }

    return ImportCalendarResult(
      importedCount: appointments.length,
      appointments: appointments,
      syncedToFhirCount: syncedToFhirCount,
    );
  }

  /// Maps a [CalendarAppointment] domain entity to the [Appointment] entity.
  Appointment _mapToAppointment(CalendarAppointment calendarApp) {
    return Appointment(
      doctorName: calendarApp.doctorName,
      specialty: calendarApp.specialty,
      dateTime: calendarApp.dateTime,
      notes: calendarApp.notes,
      source: _sourceToImportTag(calendarApp.source),
      status: AppointmentStatus.upcoming,
    );
  }

  String _sourceToImportTag(CalendarEventSource source) {
    switch (source) {
      case CalendarEventSource.deviceCalendar:
        return 'DEVICE_CALENDAR';
      case CalendarEventSource.icsFile:
        return 'ICS_IMPORT';
      case CalendarEventSource.csvFile:
        return 'CSV_IMPORT';
      case CalendarEventSource.manual:
        return 'MANUAL_IMPORT';
      case CalendarEventSource.unknown:
        return 'UNKNOWN_IMPORT';
    }
  }

  void _syncToFhir(Appointment appointment, String patientId) {
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
