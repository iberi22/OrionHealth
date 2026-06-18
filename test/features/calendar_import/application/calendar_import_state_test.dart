import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/calendar_import/application/calendar_import_cubit.dart';
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
        final apps = [Appointment(id: 1, title: 'Test')];
        expect(const CalendarImportLoaded(apps).foundAppointments, apps);
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
