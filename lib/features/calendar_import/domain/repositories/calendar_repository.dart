import '../entities/calendar_event.dart';
import '../entities/calendar_source.dart';

/// Abstract repository interface for calendar operations.
///
/// Defines the contract that any calendar import implementation must fulfill.
/// This keeps the domain layer decoupled from platform-specific APIs.
abstract class CalendarRepository {
  /// Returns whether calendar permissions have been granted.
  Future<bool> hasPermissions();

  /// Requests calendar permissions from the user.
  /// Returns `true` if permissions were granted.
  Future<bool> requestPermissions();

  /// Retrieves all available calendar sources on the device.
  Future<List<CalendarSource>> getCalendarSources();

  /// Fetches medical-related calendar events from all available calendars
  /// within the given [startDate] to [endDate] range.
  ///
  /// Returns a list of raw [CalendarEvent]s; filtering for medical content
  /// is handled by the repository implementation.
  Future<List<CalendarEvent>> fetchMedicalEvents({
    DateTime? startDate,
    DateTime? endDate,
  });
}
