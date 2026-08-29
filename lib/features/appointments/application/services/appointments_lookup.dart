import '../../domain/entities/appointment.dart';

/// Pre-computes and provides O(1) date lookups for appointments.
///
/// **What:** Converts a list of appointments into a Map indexed by normalized date keys (year, month, day).
/// **Why:** Eliminates O(N) iterative `.any()` or `.where()` lookups on every calendar grid cell build.
/// **Impact:** Reduces calendar grid cell lookup complexity from O(N) to O(1) per frame/cell.
class AppointmentsLookup {
  final Map<DateTime, List<Appointment>> _byDay;

  AppointmentsLookup._(this._byDay);

  /// Factory constructor that indexes a list of appointments by date normalized to year, month, day.
  factory AppointmentsLookup.fromList(List<Appointment> appointments) {
    final map = <DateTime, List<Appointment>>{};
    for (final appointment in appointments) {
      final key = DateTime(
        appointment.dateTime.year,
        appointment.dateTime.month,
        appointment.dateTime.day,
      );
      map.putIfAbsent(key, () => []).add(appointment);
    }
    return AppointmentsLookup._(map);
  }

  /// Creates an empty lookup instance.
  factory AppointmentsLookup.empty() => AppointmentsLookup._({});

  /// Returns true if there is at least one appointment on the specified [date].
  bool hasAppointmentsOn(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return _byDay.containsKey(key) && _byDay[key]!.isNotEmpty;
  }

  /// Returns the list of appointments on the specified [date], or an empty list if none.
  List<Appointment> getAppointmentsOn(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return _byDay[key] ?? const [];
  }
}
