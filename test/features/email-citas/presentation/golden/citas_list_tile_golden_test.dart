import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:orionhealth_health/features/email-citas/presentation/widgets/citas_list_tile.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  setUpAll(() {
    initializeDateFormatting('es', null);
  });

  group('CitasListTile Golden Tests', () {
    testWidgets('CitasListTile - Upcoming Status', (tester) async {
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
              child: CitasListTile(
                appointment: appointment,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(CitasListTile),
        matchesGoldenFile("goldens/citas_list_tile_upcoming.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('CitasListTile - Completed Status', (tester) async {
      setupGoldenTest(tester);

      final appointment = Appointment(
        id: 2,
        doctorName: 'Dra. Lisa Cuddy',
        specialty: 'Endocrinología',
        dateTime: DateTime(2026, 7, 1, 9, 0),
        status: AppointmentStatus.completed,
      );

      await tester.pumpWidget(
        wrapWithMaterial(
          Scaffold(
            body: Center(
              child: CitasListTile(
                appointment: appointment,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(CitasListTile),
        matchesGoldenFile("goldens/citas_list_tile_completed.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('CitasListTile - Cancelled Status', (tester) async {
      setupGoldenTest(tester);

      final appointment = Appointment(
        id: 3,
        doctorName: 'Dr. James Wilson',
        specialty: 'Oncología',
        dateTime: DateTime(2026, 7, 10, 11, 0),
        status: AppointmentStatus.cancelled,
      );

      await tester.pumpWidget(
        wrapWithMaterial(
          Scaffold(
            body: Center(
              child: CitasListTile(
                appointment: appointment,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(CitasListTile),
        matchesGoldenFile("goldens/citas_list_tile_cancelled.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
