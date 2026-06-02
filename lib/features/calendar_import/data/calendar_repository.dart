import 'package:device_calendar/device_calendar.dart';
import 'package:injectable/injectable.dart';
import '../../appointments/domain/entities/appointment.dart';

@lazySingleton
class CalendarRepository {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  final List<String> _medicalKeywords = [
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

  Future<bool> hasPermissions() async {
    var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
    if (permissionsGranted.isSuccess && permissionsGranted.data!) {
      return true;
    }
    return false;
  }

  Future<bool> requestPermissions() async {
    var permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
    return permissionsGranted.isSuccess && permissionsGranted.data!;
  }

  Future<List<Appointment>> fetchMedicalEvents() async {
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    if (!calendarsResult.isSuccess || calendarsResult.data == null) {
      return [];
    }

    final List<Appointment> medicalAppointments = [];
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 30));
    final endDate = now.add(const Duration(days: 90));

    for (var calendar in calendarsResult.data!) {
      final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
        calendar.id,
        RetrieveEventsParams(startDate: startDate, endDate: endDate),
      );

      if (eventsResult.isSuccess && eventsResult.data != null) {
        for (var event in eventsResult.data!) {
          if (_isMedicalEvent(event)) {
            medicalAppointments.add(_mapEventToAppointment(event));
          }
        }
      }
    }

    return medicalAppointments;
  }

  bool _isMedicalEvent(Event event) {
    final title = event.title?.toLowerCase() ?? "";
    final description = event.description?.toLowerCase() ?? "";

    return _medicalKeywords.any((keyword) {
      final k = keyword.toLowerCase();
      return title.contains(k) || description.contains(k);
    });
  }

  Appointment _mapEventToAppointment(Event event) {
    // Simple parsing logic: use title as doctor name or specialty if recognizable
    String doctorName = "Médico";
    String specialty = "Consulta General";

    final title = event.title ?? "Cita Médica";
    if (title.contains("Dr.") || title.contains("Dra.")) {
      final parts = title.split(" ");
      final drIndex = parts.indexWhere((p) => p.contains("Dr.") || p.contains("Dra."));
      if (drIndex != -1 && drIndex + 1 < parts.length) {
        doctorName = parts.sublist(drIndex).join(" ");
      }
    }

    // Try to guess specialty
    for (var keyword in _medicalKeywords) {
      if (title.toLowerCase().contains(keyword.toLowerCase())) {
        specialty = keyword;
        break;
      }
    }

    return Appointment(
      doctorName: doctorName,
      specialty: specialty,
      dateTime: event.start ?? DateTime.now(),
      notes: "Importado de calendario: ${event.description ?? ''}",
      status: AppointmentStatus.upcoming,
    );
  }
}
