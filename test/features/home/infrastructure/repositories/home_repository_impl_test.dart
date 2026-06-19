import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/home/infrastructure/repositories/home_repository_impl.dart';
import 'package:orionhealth_health/features/vitals/domain/repositories/vital_sign_repository.dart';
import 'package:orionhealth_health/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:orionhealth_health/features/medications/domain/repositories/medication_repository.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';

class MockVitalSignRepository extends Mock implements VitalSignRepository {}
class MockAppointmentRepository extends Mock implements AppointmentRepository {}
class MockMedicationRepository extends Mock implements MedicationRepository {}

void main() {
  late HomeRepositoryImpl repository;
  late MockVitalSignRepository mockVitalSignRepository;
  late MockAppointmentRepository mockAppointmentRepository;
  late MockMedicationRepository mockMedicationRepository;

  setUp(() {
    mockVitalSignRepository = MockVitalSignRepository();
    mockAppointmentRepository = MockAppointmentRepository();
    mockMedicationRepository = MockMedicationRepository();
    repository = HomeRepositoryImpl(
      mockVitalSignRepository,
      mockAppointmentRepository,
      mockMedicationRepository,
    );
  });

  group('getHealthSummary', () {
    final tVital = VitalSign(
      type: VitalSignType.heartRate,
      value: 70,
      dateTime: DateTime.now(),
    );
    final tAppointment = Appointment(
      doctorName: 'Dr. Smith',
      specialty: 'Cardiology',
      dateTime: DateTime.now().add(const Duration(days: 1)),
      status: AppointmentStatus.upcoming,
    );
    final tPastAppointment = Appointment(
      doctorName: 'Dr. Jones',
      specialty: 'General',
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
      status: AppointmentStatus.completed,
    );

    test('should return health summary with correct data', () async {
      // arrange
      when(() => mockVitalSignRepository.getLatestVitals())
          .thenAnswer((_) async => {VitalSignType.heartRate: tVital});
      when(() => mockAppointmentRepository.getAllAppointments())
          .thenAnswer((_) async => [tAppointment, tPastAppointment]);
      when(() => mockMedicationRepository.getAllMedications())
          .thenAnswer((_) async => []);

      // act
      final result = await repository.getHealthSummary();

      // assert
      expect(result.latestVitals, contains(tVital));
      expect(result.upcomingAppointments, contains(tAppointment));
      expect(result.upcomingAppointments, isNot(contains(tPastAppointment)));
      expect(result.medicationCount, 0);
    });
  });

  group('getHomeModules', () {
    test('should return list of modules', () async {
      // act
      final result = await repository.getHomeModules();

      // assert
      expect(result, isNotEmpty);
      expect(result.any((m) => m.title == 'AI Assistant'), isTrue);
    });
  });
}
