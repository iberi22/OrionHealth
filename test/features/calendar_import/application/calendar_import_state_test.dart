import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/calendar_import/domain/entities/calendar_import_state.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';

void main() {
  group('CalendarImportState', () {
    group('CalendarImportInitial', () {
      test('creates correctly', () {
        expect(const CalendarImportInitial(), isA<CalendarImportInitial>());
      });
    });

    group('CalendarImportLoading', () {
      test('creates correctly', () {
        expect(const CalendarImportLoading(), isA<CalendarImportLoading>());
      });
    });

    group('CalendarImportLoaded', () {
      test('creates with appointments', () {
        final now = DateTime.now();
        final apps = <Appointment>[
          Appointment(
            id: 1,
            doctorName: 'Dr. P�rez',
            specialty: 'Cardiolog��a',
            dateTime: now,
            status: AppointmentStatus.upcoming,
          ),
        ];
        expect(CalendarImportLoaded(apps).foundAppointments, apps);
      });
    });

    group('CalendarImportSuccess', () {
      test('creates with imported count', () {
        expect(const CalendarImportSuccess(5).importedCount, 5);
      });
    });

    group('CalendarImportError', () {
      test('creates with message', () {
        expect(const CalendarImportError('err').message, 'err');
      });
    });

    group('CalendarImportPermissionDenied', () {
      test('creates correctly', () {
        expect(
          const CalendarImportPermissionDenied(),
          isA<CalendarImportPermissionDenied>(),
        );
      });
    });
  });
}
