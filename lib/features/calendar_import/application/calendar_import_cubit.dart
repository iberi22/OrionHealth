import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../appointments/domain/entities/appointment.dart';
import '../domain/entities/calendar_event.dart';
import '../domain/entities/calendar_import_state.dart';
import '../domain/repositories/calendar_repository.dart';
import '../domain/usecases/import_calendar_usecase.dart';

export '../domain/entities/calendar_import_state.dart';

// ---------------------------------------------------------------------------
// Cubit
// ---------------------------------------------------------------------------

@injectable
class CalendarImportCubit extends Cubit<CalendarImportState> {
  final CalendarRepository _calendarRepository;
  final ImportCalendarUseCase _importCalendarUseCase;

  CalendarImportCubit(
    this._calendarRepository,
    this._importCalendarUseCase,
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

      // Fetch as CalendarEvent domain entities, then map to Appointment for UI
      final calendarEvents = await _calendarRepository.fetchMedicalEvents();
      final appointments = calendarEvents.map(_mapEventToAppointment).toList();
      emit(CalendarImportLoaded(appointments));
    } catch (e) {
      emit(CalendarImportError(e.toString()));
    }
  }

  Future<void> importAppointments(List<Appointment> appointments) async {
    emit(CalendarImportLoading());
    try {
      // Convert Appointment list back to CalendarEvent list for the use case
      final events = appointments.map((app) {
        return CalendarEvent(
          title: '${app.doctorName} - ${app.specialty}',
          startDateTime: app.dateTime,
          description: app.notes ?? app.doctorName,
          source: CalendarEventSource.deviceCalendar,
        );
      }).toList();

      final result = await _importCalendarUseCase.execute(
        ImportCalendarParams(events: events),
      );
      emit(CalendarImportSuccess(result.importedCount));
    } catch (e) {
      emit(CalendarImportError(e.toString()));
    }
  }

  Appointment _mapEventToAppointment(CalendarEvent event) {
    // Simple extraction from event title
    final title = event.title;
    String doctorName = 'Médico';
    String specialty = 'Consulta General';

    if (title.contains('Dr.') || title.contains('Dra.')) {
      final parts = title.split(' ');
      final drIndex =
          parts.indexWhere((p) => p.contains('Dr.') || p.contains('Dra.'));
      if (drIndex != -1 && drIndex + 1 < parts.length) {
        doctorName = parts.sublist(drIndex).join(' ');
      }
    }

    const keywords = [
      'cita', 'médico', 'consulta', 'EPS', 'Sura', 'Comfama',
      'Sanitas', 'doctor', 'especialista', 'control', 'examen',
      'procedimiento', 'odontología', 'terapia', 'laboratorio', 'vacuna',
    ];
    for (final kw in keywords) {
      if (title.toLowerCase().contains(kw)) {
        specialty = kw;
        break;
      }
    }

    return Appointment(
      doctorName: doctorName,
      specialty: specialty,
      dateTime: event.startDateTime,
      notes: 'Importado de calendario: ${event.description ?? ''}',
      status: AppointmentStatus.upcoming,
    );
  }
}
