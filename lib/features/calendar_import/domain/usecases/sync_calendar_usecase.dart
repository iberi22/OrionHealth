import '../entities/calendar_event.dart';
import '../repositories/calendar_repository.dart';

/// Parameters for the sync calendar use case.
class SyncCalendarParams {
  /// The time window (in days) to scan for recent events.
  final int lookBackDays;

  const SyncCalendarParams({this.lookBackDays = 7});
}

/// Result of synchronizing calendar events.
class SyncCalendarResult {
  final int newEventsFound;
  final int totalEvents;

  const SyncCalendarResult({
    required this.newEventsFound,
    required this.totalEvents,
  });
}

/// Use case: periodically scan the device calendar for new or updated
/// medical events that may have been added by external apps.
///
/// This is designed to be called by a background worker or on app resume.
class SyncCalendarUseCase {
  final CalendarRepository _calendarRepository;

  SyncCalendarUseCase(this._calendarRepository);

  /// Scans the device calendar for medical events added or modified
  /// within the configured look-back window.
  Future<SyncCalendarResult> execute(SyncCalendarParams params) async {
    final hasPermission = await _calendarRepository.hasPermissions();
    if (!hasPermission) {
      final granted = await _calendarRepository.requestPermissions();
      if (!granted) {
        return const SyncCalendarResult(
          newEventsFound: 0,
          totalEvents: 0,
        );
      }
    }

    final now = DateTime.now();
    final events = await _calendarRepository.fetchMedicalEvents(
      startDate: now.subtract(Duration(days: params.lookBackDays)),
      endDate: now.add(const Duration(days: 90)),
    );

    // Deduplicate by title + start time
    final seen = <String>{};
    final uniqueEvents = <CalendarEvent>[];
    for (final event in events) {
      if (seen.add(event.dedupKey)) {
        uniqueEvents.add(event);
      }
    }

    return SyncCalendarResult(
      newEventsFound: uniqueEvents.length,
      totalEvents: events.length,
    );
  }
}
