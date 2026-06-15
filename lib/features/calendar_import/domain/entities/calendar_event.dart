/// Represents a calendar event imported from an external source.
///
/// This is a pure domain entity with no framework or platform dependencies.
/// It is the internal representation before mapping to an [Appointment].
class CalendarEvent {
  final String title;
  final DateTime startDateTime;
  final DateTime? endDateTime;
  final String? description;
  final String? location;
  final CalendarEventSource source;

  const CalendarEvent({
    required this.title,
    required this.startDateTime,
    this.endDateTime,
    this.description,
    this.location,
    this.source = CalendarEventSource.unknown,
  });

  /// Creates a unique deduplication key for this event.
  String get dedupKey =>
      '${startDateTime.millisecondsSinceEpoch}_${title.trim().toLowerCase()}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarEvent &&
          runtimeType == other.runtimeType &&
          startDateTime == other.startDateTime &&
          title == other.title &&
          description == other.description &&
          location == other.location &&
          source == other.source;

  @override
  int get hashCode =>
      startDateTime.hashCode ^
      title.hashCode ^
      description.hashCode ^
      location.hashCode ^
      source.hashCode;

  @override
  String toString() =>
      'CalendarEvent(title: $title, start: $startDateTime, source: $source)';
}

/// Identifies the external origin of a calendar event.
enum CalendarEventSource {
  /// Imported from the device's native calendar (iOS/Android).
  deviceCalendar,

  /// Parsed from an ICS / iCalendar file.
  icsFile,

  /// Parsed from a CSV file.
  csvFile,

  /// Manually entered by the user.
  manual,

  /// Source could not be determined.
  unknown,
}
