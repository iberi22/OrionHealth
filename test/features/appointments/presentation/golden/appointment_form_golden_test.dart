import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:orionhealth_health/features/appointments/presentation/widgets/appointment_form.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  setUpAll(() {
    initializeDateFormatting('es', null);
  });

  group('AppointmentForm Golden Tests', () {
    testWidgets('AppointmentForm - New Appointment', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(wrapWithMaterial(
        Scaffold(
          body: AppointmentForm(
            onSave: (_) {},
            onDelete: (_) {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(AppointmentForm),
        matchesGoldenFile("../../../../../golden/reference/appointment_form_new.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('AppointmentForm - Edit Appointment', (tester) async {
      setupGoldenTest(tester);
      final appointment = Appointment(
        id: 1,
        doctorName: 'Dr. Strange',
        specialty: 'Surgery',
        dateTime: DateTime(2026, 8, 20, 11, 0),
        status: AppointmentStatus.upcoming,
        notes: 'Check mystic arts level',
      );

      await tester.pumpWidget(wrapWithMaterial(
        Scaffold(
          body: AppointmentForm(
            appointment: appointment,
            onSave: (_) {},
            onDelete: (_) {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(AppointmentForm),
        matchesGoldenFile("../../../../../golden/reference/appointment_form_edit.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
