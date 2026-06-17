import '../../domain/entities/calendar_event.dart';

/// Utility to parse calendar events from ICS and CSV formats.
///
/// Implements basic medical filtering to only import relevant appointments.
class CalendarParser {
  /// Keywords used to identify medical events.
  static const List<String> _medicalKeywords = [
    'cita', 'médico', 'consulta', 'eps', 'sura', 'comfama',
    'sanitas', 'doctor', 'especialista', 'control', 'examen',
    'procedimiento', 'odontología', 'terapia', 'laboratorio', 'vacuna',
    'hospital', 'clínica', 'salud', 'dra.', 'dr.',
  ];

  /// Parses an ICS (iCalendar) string and returns medical events.
  List<CalendarEvent> parseIcs(String icsContent) {
    final List<CalendarEvent> events = [];
    final lines = icsContent.split('\n');

    String? currentSummary;
    DateTime? currentStart;
    String? currentDescription;

    for (var line in lines) {
      line = line.trim();
      if (line.startsWith('BEGIN:VEVENT')) {
        currentSummary = null;
        currentStart = null;
        currentDescription = null;
      } else if (line.startsWith('SUMMARY:')) {
        currentSummary = line.substring(8);
      } else if (line.startsWith('DTSTART:')) {
        currentStart = _parseIcsDateTime(line.substring(8));
      } else if (line.startsWith('DESCRIPTION:')) {
        currentDescription = line.substring(12);
      } else if (line.startsWith('END:VEVENT')) {
        if (currentSummary != null && currentStart != null) {
          if (_isMedical(currentSummary, currentDescription ?? '')) {
            events.add(CalendarEvent(
              title: currentSummary,
              startDateTime: currentStart,
              description: currentDescription,
              source: CalendarEventSource.icsFile,
            ));
          }
        }
      }
    }

    return _deduplicate(events);
  }

  /// Parses a CSV string and returns medical events.
  /// Expected format: Subject,Start Date,Start Time,Description
  List<CalendarEvent> parseCsv(String csvContent) {
    final List<CalendarEvent> events = [];
    final lines = csvContent.split('\n');

    // Skip header if present
    int startIndex = 0;
    if (lines.isNotEmpty && lines[0].toLowerCase().contains('subject')) {
      startIndex = 1;
    }

    for (int i = startIndex; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final parts = line.split(',');
      if (parts.length < 3) continue;

      final title = parts[0].trim();
      final dateStr = parts[1].trim();
      final timeStr = parts[2].trim();
      final description = parts.length > 3 ? parts[3].trim() : null;

      try {
        final start = DateTime.parse('$dateStr $timeStr');
        if (_isMedical(title, description ?? '')) {
          events.add(CalendarEvent(
            title: title,
            startDateTime: start,
            description: description,
            source: CalendarEventSource.csvFile,
          ));
        }
      } catch (_) {
        // Skip malformed rows
      }
    }

    return _deduplicate(events);
  }

  bool _isMedical(String title, String description) {
    final text = '$title $description'.toLowerCase();
    return _medicalKeywords.any((kw) => text.contains(kw));
  }

  List<CalendarEvent> _deduplicate(List<CalendarEvent> events) {
    final Map<String, CalendarEvent> unique = {};
    for (var e in events) {
      unique[e.dedupKey] = e;
    }
    return unique.values.toList();
  }

  DateTime? _parseIcsDateTime(String value) {
    // Format: 20231027T100000Z
    try {
      final year = int.parse(value.substring(0, 4));
      final month = int.parse(value.substring(4, 6));
      final day = int.parse(value.substring(6, 8));
      final hour = int.parse(value.substring(9, 11));
      final minute = int.parse(value.substring(11, 13));
      final second = int.parse(value.substring(13, 15));

      final isUtc = value.endsWith('Z');
      if (isUtc) {
        return DateTime.utc(year, month, day, hour, minute, second).toLocal();
      }
      return DateTime(year, month, day, hour, minute, second);
    } catch (_) {
      return null;
    }
  }
}
