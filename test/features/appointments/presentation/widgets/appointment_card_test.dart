import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:orionhealth_health/features/appointments/presentation/widgets/appointment_card.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
  });

  testWidgets('AppointmentCard displays information correctly', (tester) async {
    final appointment = Appointment(
      id: 1,
      doctorName: 'Dr. House',
      specialty: 'Diagnostics',
      dateTime: DateTime(2023, 10, 10, 10, 30),
      status: AppointmentStatus.upcoming,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppointmentCard(
            appointment: appointment,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Dr. House'), findsOneWidget);
    expect(find.text('Diagnostics'), findsOneWidget);
    expect(find.text('UPCOMING'), findsOneWidget);
  });

  testWidgets('AppointmentCard triggers onTap', (tester) async {
    bool tapped = false;
    final appointment = Appointment(
      id: 1,
      doctorName: 'Dr. House',
      specialty: 'Diagnostics',
      dateTime: DateTime.now(),
      status: AppointmentStatus.upcoming,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppointmentCard(
            appointment: appointment,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    // Use tap on a specific child to ensure hit test passes
    await tester.tap(find.text('Dr. House'));
    expect(tapped, isTrue);
  });
}
