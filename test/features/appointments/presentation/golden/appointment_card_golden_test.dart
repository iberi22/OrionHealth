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
    testWidgets('AppointmentCard - Upcoming', (tester) async {
      setupGoldenTest(tester);
      final appointment = Appointment(
        doctorName: 'Dr. Smith',
        specialty: 'Cardiology',
        dateTime: DateTime(2026, 7, 10, 14, 30),
        status: AppointmentStatus.upcoming,
      );

      await tester.pumpWidget(wrapWithMaterial(
        AppointmentCard(appointment: appointment, onTap: () {}),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(AppointmentCard),
        matchesGoldenFile("../../../../../golden/reference/appointment_card_upcoming.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('AppointmentCard - Completed with Source', (tester) async {
      setupGoldenTest(tester);
      final appointment = Appointment(
        doctorName: 'Dr. House',
        specialty: 'Diagnostics',
        dateTime: DateTime(2026, 6, 15, 10, 0),
        status: AppointmentStatus.completed,
        source: 'Google Calendar',
      );

      await tester.pumpWidget(wrapWithMaterial(
        AppointmentCard(appointment: appointment, onTap: () {}),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(AppointmentCard),
        matchesGoldenFile("../../../../../golden/reference/appointment_card_completed.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
