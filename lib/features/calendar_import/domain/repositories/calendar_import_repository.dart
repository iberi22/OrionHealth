import '../entities/calendar_appointment.dart';
import '../entities/calendar_event.dart';
import '../entities/calendar_source.dart';

/// Abstract repository interface for calendar import operations.
///
/// Defines the contract for discovering and importing medical events from
/// various calendar sources.
abstract class CalendarImportRepository {
  /// Returns whether calendar permissions have been granted.
  Future<bool> hasPermissions();

  /// Requests calendar permissions from the user.
  /// Returns `true` if permissions were granted.
  Future<bool> requestPermissions();

  /// Retrieves all available calendar sources on the device.
  Future<List<CalendarSource>> getCalendarSources();

  /// Fetches medical-related calendar events and maps them to [CalendarAppointment]s.
  ///
  /// The implementation is responsible for filtering for medical content
  /// and performing the initial mapping from platform-specific events.
  Future<List<CalendarAppointment>> fetchMedicalAppointments({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Fetches medical-related calendar events as raw [CalendarEvent]s.
  Future<List<CalendarEvent>> fetchMedicalEvents({
    DateTime? startDate,
    DateTime? endDate,
  });
}
