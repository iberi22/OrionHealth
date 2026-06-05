import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../entities/appointment.dart';

@lazySingleton
class AppointmentService {
  /// Checks if [newApp] conflicts with any of the [existingApps].
  /// A conflict is defined as an overlap in time for the same doctor or same patient.
  /// (In this context, we assume all existingApps belong to the same patient).
  /// Cancelled appointments are ignored.
  bool hasConflict(Appointment newApp, List<Appointment> existingApps) {
    if (newApp.status == AppointmentStatus.cancelled) return false;

    final newStart = newApp.dateTime;
    final newEnd = newStart.add(Duration(minutes: newApp.durationInMinutes));

    for (final existing in existingApps) {
      if (existing.id == newApp.id) continue;
      if (existing.status == AppointmentStatus.cancelled) continue;

      final existingStart = existing.dateTime;
      final existingEnd = existingStart.add(Duration(minutes: existing.durationInMinutes));

      // Overlap detection logic: (StartA < EndB) and (EndA > StartB)
      if (newStart.isBefore(existingEnd) && newEnd.isAfter(existingStart)) {
        return true;
      }
    }
    return false;
  }

  /// Generates recurring instances of an appointment based on its [recurrenceRule].
  /// Supported rules: "FREQ=DAILY", "FREQ=WEEKLY".
  /// [count] specifies the number of instances to generate (default 10).
  List<Appointment> generateInstances(Appointment app, {int count = 10}) {
    if (app.recurrenceRule == null || app.recurrenceRule!.isEmpty) {
      return [app];
    }

    final List<Appointment> instances = [];
    final rule = app.recurrenceRule!.toUpperCase();

    Duration step;
    if (rule.contains("FREQ=DAILY")) {
      step = const Duration(days: 1);
    } else if (rule.contains("FREQ=WEEKLY")) {
      step = const Duration(days: 7);
    } else {
      return [app];
    }

    for (int i = 0; i < count; i++) {
      instances.add(Appointment(
        id: i == 0 ? app.id : Isar.autoIncrement,
        doctorName: app.doctorName,
        specialty: app.specialty,
        dateTime: app.dateTime.add(step * i),
        durationInMinutes: app.durationInMinutes,
        notes: app.notes,
        source: app.source,
        status: app.status,
        recurrenceRule: app.recurrenceRule,
      ));
    }

    return instances;
  }
}
