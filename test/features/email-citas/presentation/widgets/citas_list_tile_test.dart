import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:orionhealth_health/features/email-citas/presentation/widgets/citas_list_tile.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
  });

  group('CitasListTile', () {
    final appointment = Appointment(
      doctorName: 'Dr. John Doe',
      specialty: 'Cardiología',
      dateTime: DateTime(2025, 5, 20, 10, 30),
      status: AppointmentStatus.upcoming,
    );

    testWidgets('renders appointment information correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CitasListTile(appointment: appointment),
          ),
        ),
      );

      expect(find.text('Dr. John Doe'), findsOneWidget);
      expect(find.text('Cardiología'), findsOneWidget);

      final expectedDate = DateFormat('dd MMM yyyy, hh:mm a', 'es').format(appointment.dateTime);
      expect(find.text(expectedDate), findsOneWidget);
    });

    testWidgets('displays appointment status', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CitasListTile(appointment: appointment),
          ),
        ),
      );

      expect(find.text('UPCOMING'), findsOneWidget);
    });

    testWidgets('renders different statuses with correct colors', (tester) async {
      final completedApp = Appointment(
        doctorName: 'Dr. Done',
        specialty: 'Surgery',
        dateTime: DateTime.now(),
        status: AppointmentStatus.completed,
      );

      final cancelledApp = Appointment(
        doctorName: 'Dr. No',
        specialty: 'Radiology',
        dateTime: DateTime.now(),
        status: AppointmentStatus.cancelled,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CitasListTile(appointment: completedApp),
                CitasListTile(appointment: cancelledApp),
              ],
            ),
          ),
        ),
      );

      expect(find.text('COMPLETED'), findsOneWidget);
      expect(find.text('CANCELLED'), findsOneWidget);

      // Verify colors by finding the Container with the status text
      final completedText = find.text('COMPLETED');
      final completedContainer = find.ancestor(of: completedText, matching: find.byType(Container)).first;
      final cancelledText = find.text('CANCELLED');
      final cancelledContainer = find.ancestor(of: cancelledText, matching: find.byType(Container)).first;

      final completedBoxDecoration = tester.widget<Container>(completedContainer).decoration as BoxDecoration;
      final cancelledBoxDecoration = tester.widget<Container>(cancelledContainer).decoration as BoxDecoration;

      expect((completedBoxDecoration.border as Border).top.color.withOpacity(1), Colors.green.withOpacity(1));
      expect((cancelledBoxDecoration.border as Border).top.color.withOpacity(1), Colors.grey.withOpacity(1));
    });

    testWidgets('renders within a ListView', (tester) async {
      final appointments = [
        appointment,
        Appointment(
          doctorName: 'Dra. Jane Smith',
          specialty: 'Pediatría',
          dateTime: DateTime(2025, 5, 21, 15, 00),
          status: AppointmentStatus.completed,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) => CitasListTile(
                appointment: appointments[index],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CitasListTile), findsNWidgets(2));
      expect(find.text('Dr. John Doe'), findsOneWidget);
      expect(find.text('Dra. Jane Smith'), findsOneWidget);
      expect(find.text('COMPLETED'), findsOneWidget);
    });

    testWidgets('triggers onTap callback', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CitasListTile(
              appointment: appointment,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CitasListTile));
      expect(tapped, isTrue);
    });
  });
}
