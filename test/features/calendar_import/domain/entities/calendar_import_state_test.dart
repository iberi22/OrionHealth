import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/calendar_import/domain/entities/calendar_import_state.dart';
import 'package:orionhealth_health/features/calendar_import/domain/entities/calendar_appointment.dart';

void main() {
  group('CalendarImportState', () {
    test('CalendarImportLoaded should hold found appointments', () {
      final appointments = [
        CalendarAppointment(
          doctorName: 'Dr. Smith',
          specialty: 'Cardiology',
          dateTime: DateTime.now(),
        ),
      ];
      final state = CalendarImportLoaded(appointments);
      expect(state.foundAppointments, appointments);
    });

    test('CalendarImportSuccess should hold imported count', () {
      const state = CalendarImportSuccess(5);
      expect(state.importedCount, 5);
    });

    test('CalendarImportError should hold error message', () {
      const state = CalendarImportError('Error message');
      expect(state.message, 'Error message');
    });
  });
}
