import 'package:injectable/injectable.dart';
import 'package:device_calendar/device_calendar.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/repositories/calendar_repository.dart';

@LazySingleton(as: CalendarRepository)
class CalendarRepositoryImpl implements CalendarRepository {
  final DeviceCalendarPlugin _deviceCalendarPlugin;

  CalendarRepositoryImpl(this._deviceCalendarPlugin);

  @override
  Future<bool> hasPermissions() async {
    final permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
    return permissionsGranted.isSuccess && (permissionsGranted.data ?? false);
  }

  @override
  Future<bool> requestPermissions() async {
    final permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
    return permissionsGranted.isSuccess && (permissionsGranted.data ?? false);
  }

  @override
  Future<List<CalendarEvent>> fetchMedicalEvents({int lookbackDays = 30}) async {
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    if (!calendarsResult.isSuccess || calendarsResult.data == null) {
      return [];
    }

    final List<CalendarEvent> allEvents = [];
    final startDate = DateTime.now().subtract(Duration(days: lookbackDays));
    final endDate = DateTime.now().add(const Duration(days: 90));

    for (final calendar in calendarsResult.data!) {
      final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
        calendar.id,
        RetrieveEventsParams(startDate: startDate, endDate: endDate),
      );

      if (eventsResult.isSuccess && eventsResult.data != null) {
        for (final event in eventsResult.data!) {
          if (_isMedicalEvent(event)) {
            allEvents.add(CalendarEvent(
              title: event.title ?? '',
              startDateTime: event.start ?? DateTime.now(),
              description: event.description,
              source: CalendarEventSource.deviceCalendar,
            ));
          }
        }
      }
    }

    return allEvents;
  }

  bool _isMedicalEvent(Event event) {
    final title = (event.title ?? '').toLowerCase();
    final description = (event.description ?? '').toLowerCase();

    final keywords = [
      'cita', 'médico', 'consulta', 'EPS', 'Sura', 'Comfama',
      'Sanitas', 'doctor', 'especialista', 'control', 'examen',
      'procedimiento', 'odontología', 'terapia', 'laboratorio', 'vacuna',
    ];

    return keywords.any((kw) => title.contains(kw) || description.contains(kw));
  }
}
