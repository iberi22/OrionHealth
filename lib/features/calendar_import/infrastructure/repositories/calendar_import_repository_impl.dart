import 'package:injectable/injectable.dart';
import '../../domain/entities/calendar_appointment.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/entities/calendar_source.dart';
import '../../domain/repositories/calendar_import_repository.dart';
import '../datasources/calendar_api_datasource.dart';
import '../models/calendar_event_dto.dart';
import '../models/calendar_source_dto.dart';

@LazySingleton(as: CalendarImportRepository)
class CalendarImportRepositoryImpl implements CalendarImportRepository {
  final CalendarApiDatasource _datasource;

  CalendarImportRepositoryImpl(this._datasource);

  @override
  Future<bool> hasPermissions() async {
    return await _datasource.hasPermissions();
  }

  @override
  Future<bool> requestPermissions() async {
    return await _datasource.requestPermissions();
  }

  @override
  Future<List<CalendarSource>> getCalendarSources() async {
    final calendars = await _datasource.getCalendars();
    return calendars
        .map((c) => CalendarSourceDto.fromDeviceCalendar(c).toEntity())
        .toList();
  }

  @override
  Future<List<CalendarAppointment>> fetchMedicalAppointments({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final calendars = await _datasource.getCalendars();
    final List<CalendarAppointment> allMedicalAppointments = [];

    // Default range if not provided: 3 months back to 6 months forward
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 90));
    final end = endDate ?? DateTime.now().add(const Duration(days: 180));

    for (final calendar in calendars) {
      if (calendar.id == null) continue;

      final events = await _datasource.getEvents(
        calendar.id!,
        startDate: start,
        endDate: end,
      );

      for (final event in events) {
        if (_isMedicalEvent(event.title ?? '', event.description ?? '')) {
          final calendarEvent = CalendarEventDto.fromDeviceCalendar(event).toEntity(
            source: CalendarEventSource.deviceCalendar,
          );

          allMedicalAppointments.add(_mapToCalendarAppointment(calendarEvent));
        }
      }
    }

    return allMedicalAppointments;
  }

  @override
  Future<List<CalendarEvent>> fetchMedicalEvents({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final calendars = await _datasource.getCalendars();
    final List<CalendarEvent> allMedicalEvents = [];

    final start = startDate ?? DateTime.now().subtract(const Duration(days: 90));
    final end = endDate ?? DateTime.now().add(const Duration(days: 180));

    for (final calendar in calendars) {
      if (calendar.id == null) continue;

      final events = await _datasource.getEvents(
        calendar.id!,
        startDate: start,
        endDate: end,
      );

      for (final event in events) {
        if (_isMedicalEvent(event.title ?? '', event.description ?? '')) {
          allMedicalEvents.add(
            CalendarEventDto.fromDeviceCalendar(event).toEntity(
              source: CalendarEventSource.deviceCalendar,
            ),
          );
        }
      }
    }

    return allMedicalEvents;
  }

  bool _isMedicalEvent(String? title, String? description) {
    final text = '${title ?? ''} ${description ?? ''}'.toLowerCase();
    const keywords = [
      'cita',
      'médico',
      'consulta',
      'eps',
      'sura',
      'comfama',
      'sanitas',
      'doctor',
      'especialista',
      'control',
      'examen',
      'procedimiento',
      'odontología',
      'terapia',
      'laboratorio',
      'vacuna',
      'hospital',
      'clínica',
      'salud',
      'pediatría',
      'ginecología',
      'cardiología',
    ];

    return keywords.any((keyword) => text.contains(keyword));
  }

  CalendarAppointment _mapToCalendarAppointment(CalendarEvent event) {
    // Logic migrated from Cubit to Repository implementation
    final title = event.title ?? '';
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
      if (title.toLowerCase().contains(kw.toLowerCase())) {
        specialty = kw;
        break;
      }
    }

    return CalendarAppointment(
      doctorName: doctorName,
      specialty: specialty,
      dateTime: event.startDateTime,
      notes: event.description,
      source: event.source,
    );
  }
}
