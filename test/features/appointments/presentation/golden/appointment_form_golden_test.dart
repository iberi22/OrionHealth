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

      await tester.pumpWidget(
        wrapWithMaterial(
          Scaffold(
            body: AppointmentForm(
              onSave: (_) {},
              onDelete: (_) {},
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(AppointmentForm),
        matchesGoldenFile("goldens/appointment_form_new.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('AppointmentForm - Edit Appointment', (tester) async {
      setupGoldenTest(tester);

      final appointment = Appointment(
        id: 1,
        doctorName: 'Dr. James Wilson',
        specialty: 'Oncología',
        dateTime: DateTime(2026, 7, 10, 11, 0),
        status: AppointmentStatus.upcoming,
        notes: 'Consulta de seguimiento',
      );

      await tester.pumpWidget(
        wrapWithMaterial(
          Scaffold(
            body: AppointmentForm(
              appointment: appointment,
              onSave: (_) {},
              onDelete: (_) {},
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(AppointmentForm),
        matchesGoldenFile("goldens/appointment_form_edit.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
