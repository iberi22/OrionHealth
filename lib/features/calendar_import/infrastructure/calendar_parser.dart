import '../domain/entities/calendar_event.dart';

/// Parses calendar data from external file formats (ICS, CSV) into
/// domain [CalendarEvent] entities.
///
/// This class is stateless and can be instantiated freely or injected.
class CalendarParser {
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

  /// Parses an ICS (iCalendar) string into a list of [CalendarEvent] entities.
  List<CalendarEvent> parseIcs(String icsData) {
    final List<CalendarEvent> events = [];
    final lines = icsData.split(RegExp(r'\r\n|\r|\n'));

    Map<String, String>? currentEvent;
    bool inEvent = false;

    for (final line in lines) {
      if (line.startsWith('BEGIN:VEVENT')) {
        inEvent = true;
        currentEvent = {};
        continue;
      }

      if (line.startsWith('END:VEVENT')) {
        inEvent = false;
        if (currentEvent != null) {
          final event = _mapIcsToCalendarEvent(currentEvent);
          if (event != null && _isMedicalEvent(event)) {
            events.add(event);
          }
        }
        currentEvent = null;
        continue;
      }

      if (inEvent && currentEvent != null) {
        final parts = line.split(':');
        if (parts.length >= 2) {
          final key = parts[0].split(';')[0]; // Handle parameters like DTSTART;TZID=...
          final value = parts.sublist(1).join(':');
          currentEvent[key] = value;
        }
      }
    }

    return _deduplicate(events);
  }

  /// Parses a CSV string into a list of [CalendarEvent] entities.
  /// Expected columns: Subject, Start Date, Start Time, Description
  List<CalendarEvent> parseCsv(String csvData) {
    final List<CalendarEvent> events = [];
    final lines = csvData.trim().split('\n');

    if (lines.isEmpty) return [];

    final headers =
        lines[0].toLowerCase().split(',').map((h) => h.trim()).toList();
    final subjectIdx = headers.indexOf('subject');
    final dateIdx = headers.indexOf('start date');
    final timeIdx = headers.indexOf('start time');
    final descIdx = headers.indexOf('description');
    final locationIdx = headers.indexOf('location');

    if (subjectIdx == -1 || dateIdx == -1) return [];

    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final parts = line.split(',');
      if (subjectIdx >= parts.length || dateIdx >= parts.length) continue;

      final subject = parts[subjectIdx].trim();
      if (subject.isEmpty) continue;

      final dateStr = parts[dateIdx].trim();
      final timeStr = (timeIdx != -1 && timeIdx < parts.length)
          ? parts[timeIdx].trim()
          : '00:00:00';
      final description = (descIdx != -1 && descIdx < parts.length)
          ? parts[descIdx].trim()
          : '';
      final location = (locationIdx != -1 && locationIdx < parts.length)
          ? parts[locationIdx].trim()
          : null;

      final dateTime =
          DateTime.tryParse('$dateStr $timeStr') ?? DateTime.tryParse(dateStr);

      if (dateTime != null) {
        final event = CalendarEvent(
          title: subject,
          startDateTime: dateTime,
          description: description,
          location: location,
          source: CalendarEventSource.csvFile,
        );

        if (_isMedicalEvent(event)) {
          events.add(event);
        }
      }
    }

    return _deduplicate(events);
  }

  CalendarEvent? _mapIcsToCalendarEvent(Map<String, String> icsEvent) {
    final summary = icsEvent['SUMMARY'] ?? 'Cita Médica';
    final description = icsEvent['DESCRIPTION'];
    final location = icsEvent['LOCATION'];
    final dtStart = icsEvent['DTSTART'];

    if (dtStart == null) return null;

    final dateTime = _parseIcsDateTime(dtStart);
    if (dateTime == null) return null;

    return CalendarEvent(
      title: summary,
      startDateTime: dateTime,
      description: description,
      location: location,
      source: CalendarEventSource.icsFile,
    );
  }

  DateTime? _parseIcsDateTime(String dtStart) {
    // 20231027T100000Z or 20231027T100000
    final dateRegExp =
        RegExp(r'^(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})(Z)?$');
    final match = dateRegExp.firstMatch(dtStart);

    if (match != null) {
      final year = int.parse(match.group(1)!);
      final month = int.parse(match.group(2)!);
      final day = int.parse(match.group(3)!);
      final hour = int.parse(match.group(4)!);
      final minute = int.parse(match.group(5)!);
      final second = int.parse(match.group(6)!);
      final isUtc = match.group(7) == 'Z';

      if (isUtc) {
        return DateTime.utc(year, month, day, hour, minute, second).toLocal();
      } else {
        return DateTime(year, month, day, hour, minute, second);
      }
    }

    // Fallback for YYYYMMDD
    if (dtStart.length >= 8) {
      final year = int.tryParse(dtStart.substring(0, 4));
      final month = int.tryParse(dtStart.substring(4, 6));
      final day = int.tryParse(dtStart.substring(6, 8));
      if (year != null && month != null && day != null) {
        return DateTime(year, month, day);
      }
    }

    return DateTime.tryParse(dtStart);
  }

  bool _isMedicalEvent(CalendarEvent event) {
    // Only check if the title/description contains medical keywords
    final title = event.title.toLowerCase();
    final description = event.description?.toLowerCase() ?? '';

    return _medicalKeywords.any((keyword) {
      final k = keyword.toLowerCase();
      return title.contains(k) || description.contains(k);
    });
  }

  List<CalendarEvent> _deduplicate(List<CalendarEvent> events) {
    final seen = <String>{};
    final List<CalendarEvent> results = [];

    for (final event in events) {
      final key = event.dedupKey;
      if (!seen.contains(key)) {
        seen.add(key);
        results.add(event);
      }
    }
    return results;
  }
}
