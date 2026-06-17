import 'package:device_calendar/device_calendar.dart';
import 'package:injectable/injectable.dart';

/// Data source that interacts with the device's native calendar API.
/// Wraps [DeviceCalendarPlugin] to provide a cleaner interface for the repository.
@injectable
class CalendarApiDatasource {
  final DeviceCalendarPlugin _deviceCalendarPlugin;

  CalendarApiDatasource({DeviceCalendarPlugin? deviceCalendarPlugin})
      : _deviceCalendarPlugin = deviceCalendarPlugin ?? DeviceCalendarPlugin();

  /// Checks if calendar permissions have been granted.
  Future<bool> hasPermissions() async {
    final permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
    return permissionsGranted.isSuccess && (permissionsGranted.data ?? false);
  }

  /// Requests calendar permissions from the user.
  Future<bool> requestPermissions() async {
    final permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
    return permissionsGranted.isSuccess && (permissionsGranted.data ?? false);
  }

  /// Retrieves all available calendars on the device.
  Future<List<Calendar>> getCalendars() async {
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    if (calendarsResult.isSuccess && calendarsResult.data != null) {
      return calendarsResult.data!;
    }
    return [];
  }

  /// Retrieves events from a specific calendar within a date range.
  Future<List<Event>> getEvents(
    String calendarId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final retrieveEventsParams = RetrieveEventsParams(
      startDate: startDate,
      endDate: endDate,
    );
    final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
      calendarId,
      retrieveEventsParams,
    );
    if (eventsResult.isSuccess && eventsResult.data != null) {
      return eventsResult.data!;
    }
    return [];
  }
}
