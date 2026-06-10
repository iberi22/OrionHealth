import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../domain/repositories/email_repository.dart';
import '../../../appointments/domain/entities/appointment.dart';

@LazySingleton(as: EmailRepository)
class EmailRepositoryImpl implements EmailRepository {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
  final http.Client _client;
  static const String _baseUrl = "http://localhost:3000/api";

  // In a real app, these would come from environment variables
  static const String _gmailClientId = "YOUR_GMAIL_CLIENT_ID";
  static const String _outlookClientId = "YOUR_OUTLOOK_CLIENT_ID";

  EmailRepositoryImpl({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<bool> connectGmail() async {
    final url = Uri.parse("https://accounts.google.com/o/oauth2/v2/auth?client_id=$_gmailClientId&response_type=code&scope=https://www.googleapis.com/auth/gmail.readonly&redirect_uri=orionhealth://oauth2redirect");
    return await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Future<bool> connectOutlook() async {
    final url = Uri.parse("https://login.microsoftonline.com/common/oauth2/v2.0/authorize?client_id=$_outlookClientId&response_type=code&scope=Mail.Read&redirect_uri=orionhealth://oauth2redirect");
    return await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Future<List<Appointment>> fetchParsedAppointments(String provider, String code) async {
    final endpoint = provider == "Gmail" ? "/gmail/appointments" : "/outlook/appointments";
    final response = await _client.post(
      Uri.parse("$_baseUrl$endpoint"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'code': code}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Appointment(
        doctorName: json['doctorName'] ?? 'Desconocido',
        specialty: json['specialty'] ?? 'Medicina',
        dateTime: json['dateStr'] != null ? DateTime.parse(json['dateStr']) : DateTime.now(),
        status: AppointmentStatus.upcoming,
        source: provider,
        notes: "Clínica: ${json['location'] ?? 'N/A'}. EPS: ${json['insurer'] ?? 'N/A'}",
      )).toList();
    } else {
      throw Exception('Failed to fetch appointments: ${response.body}');
    }
  }

  @override
  Future<void> syncToNativeCalendar(Appointment appointment) async {
    var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
    if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
      permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
      if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
        return;
      }
    }

    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    if (calendarsResult.isSuccess && calendarsResult.data!.isNotEmpty) {
      final calendarId = calendarsResult.data!.first.id;

      final event = Event(
        calendarId,
        title: "Cita: ${appointment.specialty} - ${appointment.doctorName}",
        description: appointment.notes ?? "Sincronizado desde OrionHealth",
        start: tz.TZDateTime.from(appointment.dateTime, tz.local),
        end: tz.TZDateTime.from(appointment.dateTime.add(const Duration(hours: 1)), tz.local),
      );

      await _deviceCalendarPlugin.createOrUpdateEvent(event);
    }
  }
}
