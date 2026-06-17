import 'package:device_calendar/device_calendar.dart';
import '../../domain/entities/calendar_event.dart';

class CalendarEventDto {
  final String title;
  final DateTime startDateTime;
  final DateTime? endDateTime;
  final String? description;
  final String? location;

  const CalendarEventDto({
    required this.title,
    required this.startDateTime,
    this.endDateTime,
    this.description,
    this.location,
  });

  factory CalendarEventDto.fromDeviceCalendar(Event event) {
    return CalendarEventDto(
      title: event.title ?? '',
      startDateTime: event.start != null
          ? DateTime.fromMillisecondsSinceEpoch(event.start!.millisecondsSinceEpoch)
          : DateTime.now(),
      endDateTime: event.end != null
          ? DateTime.fromMillisecondsSinceEpoch(event.end!.millisecondsSinceEpoch)
          : null,
      description: event.description,
      location: event.location,
    );
  }

  CalendarEvent toEntity({CalendarEventSource source = CalendarEventSource.deviceCalendar}) {
    return CalendarEvent(
      title: title,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      description: description,
      location: location,
      source: source,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'startDateTime': startDateTime.toIso8601String(),
        'endDateTime': endDateTime?.toIso8601String(),
        'description': description,
        'location': location,
      };

  factory CalendarEventDto.fromJson(Map<String, dynamic> json) =>
      CalendarEventDto(
        title: json['title'] as String,
        startDateTime: DateTime.parse(json['startDateTime'] as String),
        endDateTime: json['endDateTime'] != null
            ? DateTime.parse(json['endDateTime'] as String)
            : null,
        description: json['description'] as String?,
        location: json['location'] as String?,
      );
}
