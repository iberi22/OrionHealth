import '../../appointments/domain/entities/appointment.dart';

class CalendarParser {
  static final List<String> _medicalKeywords = [
    "cita",
    "médico",
    "consulta",
    "EPS",
    "Sura",
    "Comfama",
    "Sanitas",
    "doctor",
    "especialista",
    "control",
    "examen",
    "procedimiento",
    "odontología",
    "terapia",
    "laboratorio",
    "vacuna",
  ];

  /// Parses an ICS (iCalendar) string into a list of [Appointment] entities.
  List<Appointment> parseIcs(String icsData) {
    final List<Appointment> appointments = [];
    final lines = icsData.split(RegExp(r'\r\n|\r|\n'));

    Map<String, String>? currentEvent;
    bool inEvent = false;

    for (var line in lines) {
      if (line.startsWith('BEGIN:VEVENT')) {
        inEvent = true;
        currentEvent = {};
        continue;
      }

      if (line.startsWith('END:VEVENT')) {
        inEvent = false;
        if (currentEvent != null) {
          final appointment = _mapIcsToAppointment(currentEvent);
          if (appointment != null && _isMedicalEvent(appointment)) {
            appointments.add(appointment);
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

    return _deduplicate(appointments);
  }

  /// Parses a CSV string into a list of [Appointment] entities.
  /// Expected columns: Subject, Start Date, Start Time, Description
  List<Appointment> parseCsv(String csvData) {
    final List<Appointment> appointments = [];
    final lines = csvData.trim().split('\n');

    if (lines.isEmpty) return [];

    // Simple CSV split (not handling quotes for simplicity here, but could be improved)
    final headers = lines[0].toLowerCase().split(',').map((h) => h.trim()).toList();
    final subjectIdx = headers.indexOf('subject');
    final dateIdx = headers.indexOf('start date');
    final timeIdx = headers.indexOf('start time');
    final descIdx = headers.indexOf('description');

    if (subjectIdx == -1 || dateIdx == -1) return [];

    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      // Handle commas within quotes if needed, but for now simple split
      final parts = line.split(',');

      if (subjectIdx >= parts.length || dateIdx >= parts.length) continue;

      final subject = parts[subjectIdx].trim();
      if (subject.isEmpty) continue;
      final dateStr = parts[dateIdx].trim();
      final timeStr = (timeIdx != -1 && timeIdx < parts.length) ? parts[timeIdx].trim() : "00:00:00";
      final description = (descIdx != -1 && descIdx < parts.length) ? parts[descIdx].trim() : "";

      final dateTime = DateTime.tryParse('$dateStr $timeStr') ?? DateTime.tryParse(dateStr);

      if (dateTime != null) {
        final appointment = Appointment(
          doctorName: _extractDoctorName(subject),
          specialty: _extractSpecialty(subject),
          dateTime: dateTime,
          notes: description,
          source: 'CSV_IMPORT',
          status: AppointmentStatus.upcoming,
        );

        if (_isMedicalEvent(appointment)) {
          appointments.add(appointment);
        }
      }
    }

    return _deduplicate(appointments);
  }

  Appointment? _mapIcsToAppointment(Map<String, String> event) {
    final summary = event['SUMMARY'] ?? 'Cita Médica';
    final description = event['DESCRIPTION'] ?? '';
    final dtStart = event['DTSTART'];

    if (dtStart == null) return null;

    final dateTime = _parseIcsDateTime(dtStart);
    if (dateTime == null) return null;

    return Appointment(
      doctorName: _extractDoctorName(summary),
      specialty: _extractSpecialty(summary),
      dateTime: dateTime,
      notes: 'Importado de ICS: $description',
      source: 'ICS_IMPORT',
      status: AppointmentStatus.upcoming,
    );
  }

  DateTime? _parseIcsDateTime(String dtStart) {
    // 20231027T100000Z or 20231027T100000
    final dateRegExp = RegExp(r'^(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})(Z)?$');
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

  bool _isMedicalEvent(Appointment app) {
    final doctor = app.doctorName.toLowerCase();
    final specialty = app.specialty.toLowerCase();
    final notes = app.notes?.toLowerCase() ?? "";

    // "Médico" and "Consulta General" are default values, don't use them for keyword matching
    // unless they were actually in the original text.
    // But here they are always set if not found.

    return _medicalKeywords.any((keyword) {
      final k = keyword.toLowerCase();
      return (doctor != "médico" && doctor.contains(k)) ||
             (specialty != "consulta general" && specialty.contains(k)) ||
             notes.contains(k);
    });
  }

  String _extractDoctorName(String text) {
    if (text.contains("Dr.") || text.contains("Dra.")) {
      final parts = text.split(" ");
      final drIndex = parts.indexWhere((p) => p.contains("Dr.") || p.contains("Dra."));
      if (drIndex != -1 && drIndex + 1 < parts.length) {
        return parts.sublist(drIndex).join(" ");
      }
    }
    return "Médico";
  }

  String _extractSpecialty(String text) {
    for (var keyword in _medicalKeywords) {
      if (text.toLowerCase().contains(keyword.toLowerCase())) {
        return keyword;
      }
    }
    return "Consulta General";
  }

  List<Appointment> _deduplicate(List<Appointment> appointments) {
    final seen = <String>{};
    final List<Appointment> results = [];

    for (final app in appointments) {
      final key = '${app.dateTime.millisecondsSinceEpoch}_${app.specialty}_${app.doctorName}';
      if (!seen.contains(key)) {
        seen.add(key);
        results.add(app);
      }
    }
    return results;
  }
}
