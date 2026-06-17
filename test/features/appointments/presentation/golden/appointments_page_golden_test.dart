import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:orionhealth_health/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:orionhealth_health/features/appointments/presentation/pages/appointments_page.dart';
import '../../../../core/golden_test_utils.dart';

class MockAppointmentRepository extends Mock implements AppointmentRepository {}

void main() {
  late MockAppointmentRepository mockRepository;

  setUpAll(() {
    initializeDateFormatting('es', null);
  });

  setUp(() async {
    mockRepository = MockAppointmentRepository();
    await GetIt.I.reset();
    GetIt.I.registerSingleton<AppointmentRepository>(mockRepository);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('Appointments Page Golden Tests', () {
    testWidgets('Appointments Page - Empty State', (tester) async {
      setupGoldenTest(tester);
      when(() => mockRepository.getAllAppointments())
          .thenAnswer((_) async => <Appointment>[]);

      await tester.pumpWidget(wrapWithMaterial(const AppointmentsPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(AppointmentsPage),
        matchesGoldenFile("../../../../../golden/reference/appointments_page_empty.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Appointments Page - With Data', (tester) async {
      setupGoldenTest(tester);

      final now = DateTime(2026, 6, 15, 10, 0); // Fixed date for golden consistency

      final appointments = [
        Appointment(
          id: 1,
          doctorName: 'Dr. House',
          specialty: 'Diagnóstico',
          dateTime: now.add(const Duration(days: 1, hours: 4)),
          status: AppointmentStatus.upcoming,
        ),
        Appointment(
          id: 2,
          doctorName: 'Dra. Cuddy',
          specialty: 'Endocrino',
          dateTime: now.subtract(const Duration(days: 2)),
          status: AppointmentStatus.completed,
          source: 'Google',
        ),
        Appointment(
          id: 3,
          doctorName: 'Dr. Wilson',
          specialty: 'Oncología',
          dateTime: now.add(const Duration(days: 5)),
          status: AppointmentStatus.upcoming,
        ),
      ];

      when(() => mockRepository.getAllAppointments())
          .thenAnswer((_) async => appointments);

      await tester.pumpWidget(wrapWithMaterial(const AppointmentsPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(AppointmentsPage),
        matchesGoldenFile("../../../../../golden/reference/appointments_page_with_data.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
