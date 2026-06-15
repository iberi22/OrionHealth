import 'package:device_calendar/device_calendar.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../../appointments/domain/entities/appointment.dart';
import '../../domain/repositories/email_repository.dart';
import '../datasources/email_remote_datasource.dart';

/// Data-layer implementation of [EmailRepository].
///
/// Delegates OAuth flows to [EmailRemoteDataSource] and manages
/// native calendar sync via [DeviceCalendarPlugin].
class EmailRepositoryImpl implements EmailRepository {
  final EmailRemoteDataSource _remoteDataSource;
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  EmailRepositoryImpl(this._remoteDataSource);

  @override
  Future<bool> connectGmail() => _remoteDataSource.connectGmail();

  @override
  Future<bool> connectOutlook() => _remoteDataSource.connectOutlook();

  @override
  Future<List<Appointment>> fetchParsedAppointments(
    String provider,
    String code,
  ) async {
    final raw = await _remoteDataSource.fetchParsedAppointments(provider, code);
    if (raw == null) return [];

    return raw.map((json) => Appointment(
      doctorName: json['doctorName'] as String? ?? 'Desconocido',
      specialty: json['specialty'] as String? ?? 'Medicina',
      dateTime: json['dateStr'] != null
          ? DateTime.parse(json['dateStr'] as String)
          : DateTime.now(),
      status: AppointmentStatus.upcoming,
      source: provider,
      notes: "Clínica: ${json['location'] ?? 'N/A'}. EPS: ${json['insurer'] ?? 'N/A'}",
    )).toList();
  }

  @override
  Future<void> syncToNativeCalendar(Appointment appointment) async {
    var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
    if (permissionsGranted.isSuccess && !(permissionsGranted.data ?? false)) {
      permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
      if (!permissionsGranted.isSuccess || !(permissionsGranted.data ?? false)) {
        return;
      }
    }

    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    if (calendarsResult.isSuccess && (calendarsResult.data ?? []).isNotEmpty) {
      final calendarId = calendarsResult.data!.first.id;

      final event = Event(
        calendarId,
        title: "Cita: ${appointment.specialty} - ${appointment.doctorName}",
        description: appointment.notes ?? "Sincronizado desde OrionHealth",
        start: tz.TZDateTime.from(appointment.dateTime, tz.local),
        end: tz.TZDateTime.from(
          appointment.dateTime.add(const Duration(hours: 1)),
          tz.local,
        ),
      );

      await _deviceCalendarPlugin.createOrUpdateEvent(event);
    }
  }
}
