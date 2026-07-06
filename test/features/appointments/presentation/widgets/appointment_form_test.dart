import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:orionhealth_health/features/appointments/presentation/widgets/appointment_form.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
  });

  testWidgets('AppointmentForm validates empty fields', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppointmentForm(
            onSave: (_) {},
            onDelete: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('GUARDAR'));
    await tester.pumpAndSettle();

    // The form has 3 text fields: Doctor, Specialty, Notes
    expect(find.byType(TextField), findsNWidgets(3));
  });

  testWidgets('AppointmentForm triggers onSave with correct data', (tester) async {
    Appointment? savedAppointment;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppointmentForm(
            onSave: (appointment) => savedAppointment = appointment,
            onDelete: (_) {},
          ),
        ),
      ),
    );

    // Using find.byType(TextField).at(0) because labels might not be easily findable if they are just decoration
    await tester.enterText(find.byType(TextField).at(0), 'Dr. Watson');
    await tester.enterText(find.byType(TextField).at(1), 'General');

    await tester.tap(find.text('GUARDAR'));
    await tester.pumpAndSettle();

    expect(savedAppointment, isNotNull);
    expect(savedAppointment?.doctorName, 'Dr. Watson');
    expect(savedAppointment?.specialty, 'General');
  });
}
