import 'package:injectable/injectable.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/entities/calendar_source.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../datasources/calendar_api_datasource.dart';
import '../models/calendar_event_dto.dart';
import '../models/calendar_source_dto.dart';

@LazySingleton(as: CalendarRepository)
class CalendarRepositoryImpl implements CalendarRepository {
  final CalendarApiDatasource _datasource;

  CalendarRepositoryImpl(this._datasource);

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
  Future<List<CalendarEvent>> fetchMedicalEvents({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final calendars = await _datasource.getCalendars();
    final List<CalendarEvent> allMedicalEvents = [];

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

  bool _isMedicalEvent(String title, String description) {
    final text = '$title $description'.toLowerCase();
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
}
