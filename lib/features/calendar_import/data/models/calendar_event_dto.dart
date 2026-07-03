import '../../domain/entities/calendar_event.dart';

class CalendarEventDto {
  final String title;
  final DateTime startDateTime;
  final DateTime? endDateTime;
  final String? description;
  final String? location;
  final String source;

  const CalendarEventDto({
    required this.title,
    required this.startDateTime,
    this.endDateTime,
    this.description,
    this.location,
    required this.source,
  });

  factory CalendarEventDto.fromEntity(CalendarEvent entity) {
    return CalendarEventDto(
      title: entity.title,
      startDateTime: entity.startDateTime,
      endDateTime: entity.endDateTime,
      description: entity.description,
      location: entity.location,
      source: entity.source.name,
    );
  }

  CalendarEvent toEntity() {
    return CalendarEvent(
      title: title,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      description: description,
      location: location,
      source: CalendarEventSource.values.firstWhere(
        (e) => e.name == source,
        orElse: () => CalendarEventSource.unknown,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'startDateTime': startDateTime.toIso8601String(),
      'endDateTime': endDateTime?.toIso8601String(),
      'description': description,
      'location': location,
      'source': source,
    };
  }

  factory CalendarEventDto.fromJson(Map<String, dynamic> json) {
    return CalendarEventDto(
      title: json['title'] as String,
      startDateTime: DateTime.parse(json['startDateTime'] as String),
      endDateTime: json['endDateTime'] != null
          ? DateTime.parse(json['endDateTime'] as String)
          : null,
      description: json['description'] as String?,
      location: json['location'] as String?,
      source: json['source'] as String? ?? 'unknown',
    );
  }
}
