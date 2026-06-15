import 'package:device_calendar/device_calendar.dart';
import 'package:injectable/injectable.dart';

import '../domain/entities/calendar_event.dart';
import '../domain/entities/calendar_source.dart';
import '../domain/repositories/calendar_repository.dart';

/// Infrastructure implementation of [CalendarRepository].
///
/// Uses the native device calendar plugin to access the device's calendars,
/// fetches events, and filters those that appear to be medical in nature.
@LazySingleton(as: CalendarRepository)
class DeviceCalendarRepository implements CalendarRepository {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  static const List<String> _medicalKeywords = [
    'cita',
    'médico',
    'consulta',
    'EPS',
    'Sura',
    'Comfama',
    'Sanitas',
    'doctor',
    'especialista',
    'control',
    'examen',
    'procedimiento',
    'odontología',
    'terapia',
    'laboratorio',
    'vacuna',
  ];

  @override
  Future<bool> hasPermissions() async {
    final permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
    return permissionsGranted.isSuccess && permissionsGranted.data == true;
  }

  @override
  Future<bool> requestPermissions() async {
    final permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
    return permissionsGranted.isSuccess && permissionsGranted.data == true;
  }

  @override
  Future<List<CalendarSource>> getCalendarSources() async {
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    if (!calendarsResult.isSuccess || calendarsResult.data == null) {
      return [];
    }

    return calendarsResult.data!.map((cal) {
      return CalendarSource(
        id: cal.id,
        name: cal.name ?? 'Unknown',
        isReadOnly: cal.isReadOnly,
        isPrimary: cal.isPrimary,
      );
    }).toList();
  }

  @override
  Future<List<CalendarEvent>> fetchMedicalEvents({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final now = DateTime.now();
    final effectiveStart = startDate ?? now.subtract(const Duration(days: 30));
    final effectiveEnd = endDate ?? now.add(const Duration(days: 90));

    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    if (!calendarsResult.isSuccess || calendarsResult.data == null) {
      return [];
    }

    final List<CalendarEvent> medicalEvents = [];

    for (final calendar in calendarsResult.data!) {
      final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
        calendar.id,
        RetrieveEventsParams(
          startDate: effectiveStart,
          endDate: effectiveEnd,
        ),
      );

      if (eventsResult.isSuccess && eventsResult.data != null) {
        for (final event in eventsResult.data!) {
          if (_isMedicalEvent(event)) {
            medicalEvents.add(_mapEventToCalendarEvent(event));
          }
        }
      }
    }

    return medicalEvents;
  }

  bool _isMedicalEvent(Event event) {
    final title = event.title?.toLowerCase() ?? '';
    final description = event.description?.toLowerCase() ?? '';

    return _medicalKeywords.any((keyword) {
      final k = keyword.toLowerCase();
      return title.contains(k) || description.contains(k);
    });
  }

  CalendarEvent _mapEventToCalendarEvent(Event event) {
    return CalendarEvent(
      title: event.title ?? 'Cita Médica',
      startDateTime: event.start ?? DateTime.now(),
      endDateTime: event.end,
      description: event.description,
      location: event.location,
      source: CalendarEventSource.deviceCalendar,
    );
  }
}
