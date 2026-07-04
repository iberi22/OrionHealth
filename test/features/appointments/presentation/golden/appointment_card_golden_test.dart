import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:orionhealth_health/features/appointments/presentation/widgets/appointment_card.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  setUpAll(() {
    initializeDateFormatting('es', null);
  });

  group('AppointmentCard Golden Tests', () {
    testWidgets('AppointmentCard - Upcoming Status', (tester) async {
      setupGoldenTest(tester);

      final appointment = Appointment(
        id: 1,
        doctorName: 'Dr. Gregory House',
        specialty: 'Medicina de Diagnóstico',
        dateTime: DateTime(2026, 7, 5, 14, 30),
        status: AppointmentStatus.upcoming,
      );

      await tester.pumpWidget(
        wrapWithMaterial(
          Scaffold(
            body: Center(
              child: AppointmentCard(
                appointment: appointment,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(AppointmentCard),
        matchesGoldenFile("goldens/appointment_card_upcoming.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('AppointmentCard - Completed Status with Source', (tester) async {
      setupGoldenTest(tester);

      final appointment = Appointment(
        id: 2,
        doctorName: 'Dra. Lisa Cuddy',
        specialty: 'Endocrinología',
        dateTime: DateTime(2026, 7, 1, 9, 0),
        status: AppointmentStatus.completed,
        source: 'Google Calendar',
      );

      await tester.pumpWidget(
        wrapWithMaterial(
          Scaffold(
            body: Center(
              child: AppointmentCard(
                appointment: appointment,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(AppointmentCard),
        matchesGoldenFile("goldens/appointment_card_completed.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
