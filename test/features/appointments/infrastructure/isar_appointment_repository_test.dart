import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:orionhealth_health/features/appointments/infrastructure/repositories/isar_appointment_repository.dart';
import 'package:path/path.dart' as p;

void main() {
  late Isar isar;
  late IsarAppointmentRepository repository;
  late String testDir;

  setUpAll(() async {
    testDir = p.join(Directory.current.path, 'test_db_appointments');
    await Directory(testDir).create(recursive: true);

    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open(
      [AppointmentSchema],
      directory: testDir,
    );
    repository = IsarAppointmentRepository(isar);
  });

  tearDownAll(() async {
    await isar.close();
    if (await Directory(testDir).exists()) {
      await Directory(testDir).delete(recursive: true);
    }
  });

  setUp(() async {
    await isar.writeTxn(() => isar.appointments.clear());
  });

  group('IsarAppointmentRepository', () {
    test('getAllAppointments returns an empty list initially', () async {
      final results = await repository.getAllAppointments();
      expect(results, isEmpty);
    });

    test('saveAppointment and getAllAppointments', () async {
      final appointment = Appointment(
        doctorName: 'Dr. House',
        specialty: 'Diagnostician',
        dateTime: DateTime.now(),
        status: AppointmentStatus.upcoming,
      );

      await repository.saveAppointment(appointment);

      final results = await repository.getAllAppointments();
      expect(results.length, 1);
      expect(results.first.doctorName, 'Dr. House');
      expect(results.first.specialty, 'Diagnostician');
    });

    test('deleteAppointment removes the appointment', () async {
      final appointment = Appointment(
        doctorName: 'Dr. House',
        specialty: 'Diagnostician',
        dateTime: DateTime.now(),
        status: AppointmentStatus.upcoming,
      );

      await repository.saveAppointment(appointment);

      final savedAppointments = await repository.getAllAppointments();
      expect(savedAppointments.length, 1);
      final idToDelete = savedAppointments.first.id;

      await repository.deleteAppointment(idToDelete);

      final resultsAfterDelete = await repository.getAllAppointments();
      expect(resultsAfterDelete, isEmpty);
    });

    test('deleteAppointment with non-existent ID does not throw', () async {
      await expectLater(repository.deleteAppointment(999), completes);
    });

    test('save multiple appointments and verify all', () async {
      final a1 = Appointment(doctorName: 'A', specialty: 'S', dateTime: DateTime.now(), status: AppointmentStatus.upcoming);
      final a2 = Appointment(doctorName: 'B', specialty: 'S', dateTime: DateTime.now(), status: AppointmentStatus.upcoming);

      await repository.saveAppointment(a1);
      await repository.saveAppointment(a2);

      final results = await repository.getAllAppointments();
      expect(results.length, 2);
    });

    test('saveAppointment updates existing appointment when ID is provided', () async {
      final appointment = Appointment(
        doctorName: 'Dr. House',
        specialty: 'Diagnostics',
        dateTime: DateTime.now(),
        status: AppointmentStatus.upcoming,
      );

      await repository.saveAppointment(appointment);
      final saved = (await repository.getAllAppointments()).first;
      final originalId = saved.id;

      saved.doctorName = 'Dr. Wilson';
      await repository.saveAppointment(saved);

      final results = await repository.getAllAppointments();
      expect(results.length, 1);
      expect(results.first.id, originalId);
      expect(results.first.doctorName, 'Dr. Wilson');
    });
  });
}
